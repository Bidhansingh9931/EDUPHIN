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

class CreateNewFeePage extends StatefulWidget {
  const CreateNewFeePage({super.key});

  @override
  State<CreateNewFeePage> createState() => _CreateNewFeePageState();
}

class _CreateNewFeePageState extends State<CreateNewFeePage> {
  final _formKey = GlobalKey<FormState>();
  final _feeNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _applyTo = "Entire Institute";
  String _isOptional = "No";
  int? _selectedClassId;

  bool _isSaving = false;
  bool _isLoadingClasses = true;
  String _error = '';

  List<ApiClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
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

  Future<void> _saveFee() async {
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
        if (_applyTo == 'Class Specific') 'class_id': _selectedClassId.toString(),
      };

      final response = await ApiService.post('manager/fees', body);
      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Fee created successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create fee.');
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
        title: Text("Create New Fee", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      padding: context.pagePadding,
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
                              "Configure the details for the new fee structure",
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
                                  (val) => setState(() => _applyTo = val!),
                                ),

                                if (_applyTo == "Class Specific") ...[
                                  buildLabel(context, "Select Class"),
                                  DropdownButtonFormField<int>(
                                    value: _selectedClassId,
                                    decoration: InputDecoration(
                                      hintText: "Select a Class",
                                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: context.scale(24), color: theme.colorScheme.primary),
                                    dropdownColor: theme.colorScheme.surfaceContainerHigh,
                                    items: _classes.map((apiClass) {
                                      return DropdownMenuItem<int>(
                                        value: apiClass.id,
                                        child: Text(apiClass.name, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() => _selectedClassId = value),
                                    validator: (value) => (_applyTo == 'Class Specific' && value == null) ? 'Please select a class' : null,
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
                            SizedBox(height: context.lg),
                            if (_isSaving)
                              const Center(child: CircularProgressIndicator())
                            else
                              buildActionButton(
                                context,
                                "Add Fee",
                                _saveFee,
                              ),
                            SizedBox(height: context.md),
                            buildActionButton(
                              context,
                              "Cancel",
                              () => Navigator.pop(context),
                              isPrimary: false,
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
