import 'package:flutter/material.dart';

class EditFeePage extends StatefulWidget {
  final String? feeName;
  final String? amount;
  final String? description;
  final String? applyTo;
  final bool? isOptional;

  const EditFeePage({
    super.key,
    this.feeName,
    this.amount,
    this.description,
    this.applyTo,
    this.isOptional,
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

  @override
  void initState() {
    super.initState();
    _feeNameController = TextEditingController(text: widget.feeName ?? "Annual Tuition Fee");
    _amountController = TextEditingController(text: widget.amount ?? "75000");
    _descriptionController = TextEditingController(
        text: widget.description ?? "Standard annual fee for all academic programs");
    _applyTo = widget.applyTo ?? "institute";
    _isOptional = (widget.isOptional ?? true) ? "Yes" : "No";
  }

  @override
  void dispose() {
    _feeNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveFee() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'feeName': _feeNameController.text,
        'amount': _amountController.text,
        'description': _descriptionController.text,
        'applyTo': _applyTo,
        'isOptional': _isOptional == 'Yes',
      };
      Navigator.pop(context, result);
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
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text("Update Fee", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                onPressed: _saveFee,
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Fee"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              child: isWide ? _buildWideLayout(theme) : _buildNarrowLayout(theme),
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
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleButton(theme, "Entire\nInstitute", "institute", _applyTo == "institute",
                  () => setState(() => _applyTo = "institute")),
              const SizedBox(width: 12),
              _buildToggleButton(theme, "Class\nSpecific", "class", _applyTo == "class",
                  () => setState(() => _applyTo = "class")),
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
          _buildTextField(theme, "Fee Name", _feeNameController, "e.g., Annual Tuition Fee",
              (value) => value!.isEmpty ? 'Fee name is required' : null),
          const SizedBox(height: 16),
          _buildTextField(theme, "Amount", _amountController, "75,000",
              (value) => value!.isEmpty ? 'Amount is required' : null,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(theme, "Description", _descriptionController, "Enter a brief description", null,
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
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToggleButton(theme, "Yes", "Yes", _isOptional == "Yes",
                  () => setState(() => _isOptional = "Yes")),
              const SizedBox(width: 12),
              _buildToggleButton(
                  theme, "No", "No", _isOptional == "No", () => setState(() => _isOptional = "No")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      ThemeData theme, String text, String value, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
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
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, TextEditingController controller, String hintText,
      String? Function(String?)? validator, {int? maxLines = 1, TextInputType? keyboardType}) {
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
