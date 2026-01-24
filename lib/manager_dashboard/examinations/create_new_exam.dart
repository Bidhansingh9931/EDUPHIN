import 'package:flutter/material.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  String examType = "Objective";
  String status = "Active";

  DateTime? startDate;
  DateTime? endDate;

  final _formKey = GlobalKey<FormState>();

  List<String> examTypes = ["Objective", "Subjective", "Practical"];
  List<String> statuses = ["Active", "Inactive"];

  Future<void> pickDate(TextEditingController controller, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void createExam() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates.")),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("End date cannot be earlier than the start date.")),
      );
      return;
    }

    final data = {
      "examName": nameController.text,
      "examType": examType,
      "examCode": codeController.text,
      "status": status,
      "startDate": startDate!.toIso8601String(),
      "endDate": endDate!.toIso8601String(),
      "description": descriptionController.text,
    };

    /// 🔹 Send this to API later
    debugPrint("Exam Created: $data");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exam Created (Simulation)")),
    );
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text("Create New Exam",
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.primaryColor,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: constraints.maxWidth > 600
                      ? _buildWideLayout(theme)
                      : _buildNarrowLayout(theme),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(theme, "Name of Exam *", nameController,
            hint: "e.g., Mid-Term Examination 2025",
            validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdownField(
                  theme, "Type *", examType, examTypes, (v) => setState(() => examType = v!)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(theme, "Exam Code *", codeController,
                  hint: "e.g., MTE-2025-01",
                  validator: (v) => v!.isEmpty ? "Required" : null),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDateField(
                  theme, "Start Date", startDateController, () => pickDate(startDateController, true),
                  validator: (v) => v!.isEmpty ? "Please select a start date" : null),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                  theme, "End Date", endDateController, () => pickDate(endDateController, false),
                  validator: (v) => v!.isEmpty ? "Please select an end date" : null),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildDropdownField(theme, "Status *", status, statuses, (v) => setState(() => status = v!)),
        const SizedBox(height: 18),
        _buildTextField(
            theme, "Description", descriptionController, maxLines: 4, hint: "Add a description for the exam..."),
        const SizedBox(height: 28),
        _buildActionButtons(theme),
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildTextField(theme, "Name of Exam *", nameController, validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 18),
                  _buildDropdownField(theme, "Type *", examType, examTypes, (v) => setState(() => examType = v!)),
                  const SizedBox(height: 18),
                   _buildDateField(theme, "Start Date", startDateController, () => pickDate(startDateController, true),
                      validator: (v) => v!.isEmpty ? "Please select a start date" : null),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildTextField(theme, "Exam Code *", codeController, validator: (v) => v!.isEmpty ? "Required" : null),
                  const SizedBox(height: 18),
                   _buildDropdownField(theme, "Status *", status, statuses, (v) => setState(() => status = v!)),
                   const SizedBox(height: 18),
                  _buildDateField(theme, "End Date", endDateController, () => pickDate(endDateController, false),
                      validator: (v) => v!.isEmpty ? "Please select an end date" : null),
                ],
              ),
            ),
          ],
        ),
         const SizedBox(height: 18),
        _buildTextField(theme, "Description", descriptionController, maxLines: 4, hint: "Add a description for the exam..."),
        const SizedBox(height: 28),
        _buildActionButtons(theme),
      ],
    );
  }

  Widget _buildTextField(ThemeData theme, String label, TextEditingController controller,
      {String? hint, int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.cardColor,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      ThemeData theme, String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: theme.cardColor,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(ThemeData theme, String label, TextEditingController controller, VoidCallback onTap,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          onTap: onTap,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: "DD/MM/YYYY",
            filled: true,
            fillColor: theme.cardColor,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            suffixIcon: Icon(Icons.calendar_today, color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: createExam,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Create Exam"),
          ),
        ),
      ],
    );
  }
}
