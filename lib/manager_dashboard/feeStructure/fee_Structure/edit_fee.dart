import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';

class ApiClass {
  final int id;
  final String name;

  ApiClass({required this.id, required this.name});

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(
      id: json['id'],
      name: json['name'],
    );
  }
}

class EditFeePage extends StatefulWidget {
  final int feeId;
  final String feeName;
  final String amount;
  final String description;
  final String applyTo;
  final bool isOptional;
  final int? classId;

  const EditFeePage({
    super.key,
    required this.feeId,
    required this.feeName,
    required this.amount,
    required this.description,
    required this.applyTo,
    required this.isOptional,
    this.classId,
  });

  @override
  State<EditFeePage> createState() => _EditFeePageState();
}

class _EditFeePageState extends State<EditFeePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feeNameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _applyTo;
  late String _isOptional;
  int? _selectedClassId;

  bool _isSaving = false;
  bool _isLoadingClasses = true;
  String _error = '';

  List<ApiClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _feeNameController = TextEditingController(text: widget.feeName);
    _amountController = TextEditingController(text: widget.amount);
    _descriptionController = TextEditingController(text: widget.description);
    _applyTo = widget.applyTo == 'class' ? "Class Specific" : "Entire Institute";
    _isOptional = widget.isOptional ? "Yes" : "No";
    _selectedClassId = widget.classId;

    if (_applyTo == 'Class Specific') {
      _fetchClasses();
    } else {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoadingClasses = true);
    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final List<dynamic> classData = data['data'];
          setState(() {
            _classes = classData.map((json) => ApiClass.fromJson(json)).toList();
            _isLoadingClasses = false;
          });
        } else {
          throw Exception('Failed to load classes: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load classes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _feeNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateFee() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_applyTo == 'Class Specific' && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String cleanedAmount = _amountController.text.replaceAll(RegExp(r'[₹,]'), '');
      final int amount = (double.tryParse(cleanedAmount) ?? 0).toInt();

      final body = {
        'fee_name': _feeNameController.text,
        'amount': amount.toString(),
        'description': _descriptionController.text,
        'is_optional': _isOptional == 'Yes',
        if (_applyTo == 'Class Specific') 'class_id': _selectedClassId!.toString(),
      };

      final response = await ApiService.put('manager/fees/${widget.feeId}', body);
      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Fee updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update fee.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit Fee", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
            Text("Update existing fee details", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: (_isLoadingClasses || _error.isNotEmpty)
          ? null
          : SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(context.spacing, context.scale(8), context.spacing, context.scale(16)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildActionButton(
                          context,
                          "Cancel",
                          () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ),
                      SizedBox(width: context.spacing),
                      Expanded(
                        child: _isSaving
                            ? const Center(child: CircularProgressIndicator())
                            : buildActionButton(
                                context,
                                "Update Fee",
                                _updateFee,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: _isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fee Information",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: context.font(18),
                              ),
                            ),
                            Text(
                              "Modify the existing fee details below",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: context.font(11),
                              ),
                            ),
                            SizedBox(height: context.md),
                            buildFilterCard(
                              context,
                              children: [
                                buildLabel(context, "Fee Name"),
                                buildTextField(context, _feeNameController, "e.g., Annual Tuition Fee"),
                                
                                buildLabel(context, "Apply Fee To"),
                                buildDropdown(
                                  context,
                                  ["Entire Institute", "Class Specific"],
                                  _applyTo,
                                  (val) {
                                    if (val == 'Class Specific' && _classes.isEmpty) {
                                      _fetchClasses();
                                    }
                                    setState(() => _applyTo = val!);
                                  },
                                ),

                                if (_applyTo == "Class Specific") ...[
                                  buildLabel(context, "Select Class"),
                                  buildDropdown(
                                    context,
                                    _classes.map((c) => c.name).toList(),
                                    _classes.any((c) => c.id == _selectedClassId) ? _classes.firstWhere((c) => c.id == _selectedClassId).name : null,
                                    (val) {
                                      if (val == null) return;
                                      setState(() => _selectedClassId = _classes.firstWhere((c) => c.name == val).id);
                                    },
                                    hint: "Select a Class",
                                  ),
                                ],

                                buildLabel(context, "Amount"),
                                buildTextField(context, _amountController, "75,000"),

                                buildLabel(context, "Is Optional?"),
                                buildDropdown(
                                  context,
                                  ["Yes", "No"],
                                  _isOptional,
                                  (val) => setState(() => _isOptional = val!),
                                ),

                                buildLabel(context, "Description"),
                                buildTextField(context, _descriptionController, "Enter a brief description", maxLines: 3),
                                SizedBox(height: context.md),
                              ],
                            ),
                            SizedBox(height: context.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
