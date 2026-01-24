import 'package:flutter/material.dart';

class EditExamPage extends StatefulWidget {
  final String examName;
  final String examType;
  final String examCode;
  final bool isActive;
  final String startEndDate;
  final String? description;

  const EditExamPage({
    super.key,
    required this.examName,
    required this.examType,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
    this.description,
  });

  @override
  State<EditExamPage> createState() => _EditExamPageState();
}

class _EditExamPageState extends State<EditExamPage> {
  late final TextEditingController examNameController;
  late final TextEditingController examCodeController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  late final TextEditingController descriptionController;

  late String examType;
  late String status;
  DateTime? startDate;
  DateTime? endDate;

  final _formKey = GlobalKey<FormState>();

  List<String> examTypes = ["Objective", "Subjective", "Practical"];
  List<String> statusList = ["Active", "Inactive"];

  @override
  void initState() {
    super.initState();
    examNameController = TextEditingController(text: widget.examName);
    examCodeController = TextEditingController(text: widget.examCode);
    descriptionController = TextEditingController(text: widget.description);

    final dateParts = widget.startEndDate.split(' - ');
    final startDateString = dateParts.isNotEmpty ? dateParts[0] : '';
    final endDateString = dateParts.length > 1 ? dateParts[1] : startDateString;

    startDate = _parseDate(startDateString);
    endDate = _parseDate(endDateString);

    startDateController = TextEditingController(text: _formatDate(startDate));
    endDateController = TextEditingController(text: _formatDate(endDate));

    examType = widget.examType;
    status = widget.isActive ? "Active" : "Inactive";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      // Handles "15 Dec 2025" format
      final dateParts = dateStr.split(' ');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        const monthNames = [
          "Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];
        final month = monthNames.indexWhere((m) => m == dateParts[1]) + 1;
        final year = int.parse(dateParts[2]);
        if (month > 0) {
          return DateTime(year, month, day);
        }
      }
      // Handles "DD/MM/YYYY" format
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    examNameController.dispose();
    examCodeController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate(TextEditingController controller, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        controller.text = _formatDate(picked);
      });
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    final updatedData = {
      'examName': examNameController.text,
      'examType': examType,
      'examCode': examCodeController.text,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'description': descriptionController.text,
    };
    Navigator.pop(context, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          "Edit Exam",
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.primaryColor,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: constraints.maxWidth > 600
                      ? _buildWideLayout(theme)
                      : _buildNarrowLayout(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildLeftColumn(theme),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildRightColumn(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftColumn(theme),
        _buildRightColumn(theme),
      ],
    );
  }

  Widget _buildLeftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          theme: theme,
          label: "Exam Name *",
          controller: examNameController,
          validator: (v) => v!.isEmpty ? 'Exam name is required' : null,
        ),
        const SizedBox(height: 18),
        _buildDropdown(
          theme: theme,
          label: "Exam Type *",
          value: examType,
          items: examTypes,
          onChanged: (v) => setState(() => examType = v!),
        ),
        const SizedBox(height: 18),
        _buildTextField(
          theme: theme,
          label: "Exam Code *",
          controller: examCodeController,
          hint: "e.g. MTE-2025",
          validator: (v) => v!.isEmpty ? 'Exam code is required' : null,
        ),
        const SizedBox(height: 18),
        _buildTextField(
          theme: theme,
          label: "Description",
          controller: descriptionController,
          maxLines: 4,
          hint: "Add a description for the exam",
        ),
      ],
    );
  }

  Widget _buildRightColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 18,
          children: [
            _buildDatePicker(theme, "Start Date", startDateController, (v) => v!.isEmpty ? 'Start date is required' : null, () => pickDate(startDateController, true)),
            _buildDatePicker(theme, "End Date", endDateController, (v) => v!.isEmpty ? 'End date is required' : null, () => pickDate(endDateController, false)),
          ],
        ),
        const SizedBox(height: 18),
        _buildDropdown(
          theme: theme,
          label: "Status *",
          value: status,
          items: statusList,
          onChanged: (v) => setState(() => status = v!),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.save,
              color: Colors.white,
              size: 20,
            ),
            label: Text("Save Changes",
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _saveChanges,
          ),
        )
      ],
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    String? hint,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            filled: true,
            fillColor: const Color(0xff101820),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff101820),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xff101820),
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      ThemeData theme,
      String label,
      TextEditingController controller,
      String? Function(String?)? validator,
      VoidCallback onTap,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xff101820),
            hintText: "DD/MM/YYYY",
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            suffixIcon: Icon(Icons.calendar_today, color: theme.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
