import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

// Model for Class data from API
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

  String _applyTo = "institute";
  String _isOptional = "Yes";
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_applyTo == 'class' && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String cleanedAmount = _amountController.text.replaceAll(RegExp(r'[₹,]'), '');
      final int amount = (double.tryParse(cleanedAmount) ?? 0).toInt();

      final body = {
        'fee_name': _feeNameController.text,
        'amount': amount.toString(),
        'description': _descriptionController.text,
        'is_optional': _isOptional == 'Yes',
        if (_applyTo == 'class') 'class_id': _selectedClassId.toString(),
      };

      final response = await ApiService.post('manager/fees', body);

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Fee created successfully!')),
        );
        Navigator.pop(context, true); // Pop with success
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create fee.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.add, color: Colors.white),
                label: _isSaving
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      )
                    : Text("Add Fee",
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Colors.white)),
                onPressed: _isSaving ? null : _saveFee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Text("Cancel",
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onSurface)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create New Fee"),
      ),
      body: _isLoadingClasses
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return SingleChildScrollView(
                        child: isWide
                            ? _buildWideLayout(theme)
                            : _buildNarrowLayout(theme),
                      );
                    }),
                  ),
                ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildApplyToCard(theme),
        const SizedBox(height: 16),
        _buildFeeDetailsCard(theme),
        const SizedBox(height: 16),
        _buildIsOptionalCard(theme),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildFeeDetailsCard(theme),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildApplyToCard(theme),
              const SizedBox(height: 16),
              _buildIsOptionalCard(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplyToCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Apply fee to:",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleButton(
                  theme,
                  "Entire\nInstitute",
                  "institute",
                  _applyTo == "institute",
                  () => setState(() => _applyTo = "institute")),
              const SizedBox(width: 12),
              _buildToggleButton(theme, "Class\nSpecific", "class",
                  _applyTo == "class", () => setState(() => _applyTo = "class")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeDetailsCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
              theme,
              "Fee Name",
              _feeNameController,
              "e.g., Annual Tuition Fee",
              (value) => value!.isEmpty ? 'Fee name cannot be empty' : null),
          const SizedBox(height: 16),
          if (_applyTo == 'class') ...[
            Text(
              "Select Class",
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedClassId,
              items: _classes.map((apiClass) {
                return DropdownMenuItem<int>(
                  value: apiClass.id,
                  child: Text(apiClass.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
              hint: const Text("Select a Class"),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (_applyTo == 'class' && value == null) {
                  return 'Please select a class';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
              theme, "Amount", _amountController, "75,000",
              (value) => value!.isEmpty ? 'Amount cannot be empty' : null,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(theme, "Description", _descriptionController,
              "Enter a brief description", null,
              maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildIsOptionalCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Is Optional?",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleButton(theme, "Yes", "Yes", _isOptional == "Yes",
                  () => setState(() => _isOptional = "Yes")),
              const SizedBox(width: 12),
              _buildToggleButton(theme, "No", "No", _isOptional == "No",
                  () => setState(() => _isOptional = "No")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ThemeData theme, String text, String value,
      bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primaryContainer, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, TextEditingController controller, String hintText,
      String? Function(String?)? validator,
      {int? maxLines = 1,
      TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }
}
