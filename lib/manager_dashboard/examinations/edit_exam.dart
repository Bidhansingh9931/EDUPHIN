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

    startDateController = TextEditingController(text: startDateString);
    endDateController = TextEditingController(text: endDateString);

    examType = widget.examType;
    status = widget.isActive ? "Active" : "Inactive";
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
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
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Edit Exam",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Exam Name *",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: examNameController,
                        validator: (v) => v!.isEmpty ? 'Exam name is required' : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xff101820),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text("Exam Type *",
                          style: TextStyle(color: Colors.white70)),
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
                            value: examType,
                            dropdownColor: const Color(0xff101820),
                            style: const TextStyle(color: Colors.white),
                            items: examTypes
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => examType = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text("Exam Code *",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: examCodeController,
                        validator: (v) => v!.isEmpty ? 'Exam code is required' : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g. MTE-2025",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xff101820),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Start Date",
                                    style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  validator: (v) =>
                                  v!.isEmpty ? 'Start date is required' : null,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xff101820),
                                    hintText: "DD/MM/YYYY",
                                    hintStyle:
                                    const TextStyle(color: Colors.white70),
                                    suffixIcon: const Icon(Icons.calendar_today,
                                        color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onTap: () => pickDate(startDateController, true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("End Date",
                                    style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: endDateController,
                                  readOnly: true,
                                  validator: (v) =>
                                  v!.isEmpty ? 'End date is required' : null,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xff101820),
                                    hintText: "DD/MM/YYYY",
                                    hintStyle:
                                    const TextStyle(color: Colors.white70),
                                    suffixIcon: const Icon(Icons.calendar_today,
                                        color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onTap: () => pickDate(endDateController, false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text("Status *",
                          style: TextStyle(color: Colors.white70)),
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
                            value: status,
                            dropdownColor: const Color(0xff101820),
                            style: const TextStyle(color: Colors.white),
                            items: statusList
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => status = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text("Description",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a description for the exam",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xff101820),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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
                          label: const Text("Save Changes",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _saveChanges,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
