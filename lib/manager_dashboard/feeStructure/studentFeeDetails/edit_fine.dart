import 'package:flutter/material.dart';

class EditFinePage extends StatefulWidget {
  final String? reason;
  final String? amount;
  final String? remarks;

  const EditFinePage({
    super.key,
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

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.reason ?? "Late Fee Payment");
    _amountController = TextEditingController(text: widget.amount ?? "200");
    _remarksController =
        TextEditingController(text: widget.remarks ?? "Add any additional remarks");
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _updateFine() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'reason': _reasonController.text,
        'amount': _amountController.text,
        'remarks': _remarksController.text,
      };
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Fine"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _updateFine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Update Fine", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.primaryColor,
              ),
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    theme: theme,
                    label: "Amount",
                    controller: _amountController,
                    hint: "200",
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? "Amount cannot be empty" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    theme: theme,
                    label: "Remarks",
                    controller: _remarksController,
                    hint: "Add any additional remarks",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 80), // Padding for FAB
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
          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
