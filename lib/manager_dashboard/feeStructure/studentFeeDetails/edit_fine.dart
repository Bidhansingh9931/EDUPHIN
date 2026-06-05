import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class EditFinePage extends StatefulWidget {
  final int fineId;
  final String? reason;
  final String? amount;
  final String? remarks;

  const EditFinePage({
    super.key,
    required this.fineId,
    this.reason,
    this.amount,
    this.remarks,
  });

  @override
  State<StatefulWidget> createState() => _EditFinePageState();
}

class _EditFinePageState extends State<EditFinePage> {
  late TextEditingController _reasonController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.reason ?? "");
    _amountController = TextEditingController(text: widget.amount ?? "");
    _remarksController =
        TextEditingController(text: widget.remarks ?? "");
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _updateFine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        'fine_id': widget.fineId.toString(),
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
          SnackBar(content: Text(responseData['message'] ?? 'Fine updated successfully!'), backgroundColor: theme.colorScheme.primary),
        );
        Navigator.pop(context, true); // Return true to indicate success and trigger a refresh
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update fine');
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
          "Edit Fine",
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
                  onPressed: _isSaving ? null : _updateFine,
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
                      : Text("Update Fine", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
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

