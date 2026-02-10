import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class AddNewRemarksPage extends StatefulWidget {
  final int studentId;
  const AddNewRemarksPage({super.key, required this.studentId});

  @override
  State<AddNewRemarksPage> createState() => _AddNewRemarksPageState();
}

class _AddNewRemarksPageState extends State<AddNewRemarksPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRemarkType = 'Positive';
  final _descriptionController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addRemark() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final remarkData = {
        'student_id': widget.studentId,
        'remarks_type': _selectedRemarkType,
        'remarks': _descriptionController.text,
        'from_date': _fromDateController.text,
        'to_date': _toDateController.text,
      };

      final response = await ApiService.post('manager/students/remarks', remarkData);

      if (mounted) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 201 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Remark added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to add remark');
        }
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The connection timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Remark"),
      ),
      // Using a responsive FAB for the primary action
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _addRemark,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("Add Remark"),
          ),
        ),
      ),
      body: Padding(
        // Added bottom padding as requested
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
        child: Form(
          key: _formKey,
          // Using LayoutBuilder for a responsive layout
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: isWide ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
              );
            },
          ),
        ),
      ),
    );
  }

  // Layout for narrow screens (e.g., phones)
  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(theme),
        const SizedBox(height: 16),
        _buildDescriptionField(theme),
        const SizedBox(height: 16),
        _buildDateField(theme, "From Date", _fromDateController),
        const SizedBox(height: 16),
        _buildDateField(theme, "To Date", _toDateController),
        const SizedBox(height: 80), // Extra padding for the FAB
      ],
    );
  }

  // Layout for wide screens (e.g., tablets)
  Widget _buildWideLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(theme),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(theme, "From Date", _fromDateController),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(theme, "To Date", _toDateController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDescriptionField(theme),
        const SizedBox(height: 80), // Extra padding for the FAB
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Remark Type", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedRemarkType,
          items: ['Positive', 'Negative'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedRemarkType = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value == null ? 'Please select a remark type' : null,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Enter remark description...",
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a description' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(ThemeData theme, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            hintText: "Select Date",
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(Icons.calendar_today, color: theme.hintColor),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select a date' : null,
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        // Format date to YYYY-MM-DD for the API
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
