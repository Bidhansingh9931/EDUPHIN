import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class AddNewFine extends StatefulWidget {
  final int studentId;
  const AddNewFine({super.key, required this.studentId});

  @override
  State<StatefulWidget> createState() => _AddNewFineState();
}

class _AddNewFineState extends State<AddNewFine> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  late final TextEditingController _amountController;
  late final TextEditingController _remarksController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _amountController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveFine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        'student_id': widget.studentId.toString(),
        'fine_type': _reasonController.text,
        'amount': _amountController.text,
        'remarks': _remarksController.text,
      };

      final response = await ApiService.post('manager/fees/fine', body);

      if (!mounted) return;
      final theme = context.theme;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Fine added successfully!'), backgroundColor: theme.colorScheme.primary),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        String errorMessage = responseData['message'] ?? 'An unknown error occurred.';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Fine",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: context.pagePadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveFine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(height: context.scale(24), width: context.scale(24), child: CircularProgressIndicator(strokeWidth: 3, color: theme.colorScheme.onPrimary))
                      : Text("Save", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: context.responsive(double.infinity, tablet: 600, desktop: 800)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.scale(16)),
                color: theme.colorScheme.surfaceContainerLow,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              padding: EdgeInsets.all(context.scale(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    theme: theme,
                    label: "Reason",
                    controller: _reasonController,
                    hint: "e.g., Late Fee Payment",
                    validator: (value) => value!.isEmpty ? "Reason cannot be empty" : null,
                  ),
                  SizedBox(height: context.scale(20)),
                  _buildTextField(
                    theme: theme,
                    label: "Amount",
                    controller: _amountController,
                    hint: "200",
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Amount cannot be empty" : null,
                  ),
                  SizedBox(height: context.scale(20)),
                  _buildTextField(
                    theme: theme,
                    label: "Remarks",
                    controller: _remarksController,
                    hint: "Add any additional remarks",
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14)),
        ),
        SizedBox(height: context.scale(8)),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

