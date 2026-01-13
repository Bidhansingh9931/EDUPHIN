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
    if (!_formKey.currentState!.validate() ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
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
        title: const Text("Create New Exam",
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.primaryColor,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Name of Exam *",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "e.g., Mid-Term Examination 2025",
                        filled: true,
                        fillColor: const Color(0xff101820),
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xff2D9CFF)),
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
                              const Text("Type *",
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff101820),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white24),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: examType,
                                    dropdownColor: const Color(0xff101820),
                                    style: const TextStyle(color: Colors.white),
                                    isExpanded: true,
                                    items: examTypes
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => examType = v!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Exam Code *",
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: codeController,
                                validator: (v) => v!.isEmpty ? "Required" : null,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "e.g., MTE-2025-01",
                                  filled: true,
                                  fillColor: const Color(0xff101820),
                                  hintStyle: const TextStyle(color: Colors.white38),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xff2D9CFF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                onTap: () => pickDate(startDateController, true),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "DD/MM/YYYY",
                                  filled: true,
                                  fillColor: const Color(0xff101820),
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  suffixIcon: const Icon(Icons.calendar_today,
                                      color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xff2D9CFF)),
                                  ),
                                ),
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
                                onTap: () => pickDate(endDateController, false),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "DD/MM/YYYY",
                                  filled: true,
                                  fillColor: const Color(0xff101820),
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  suffixIcon: const Icon(Icons.calendar_today,
                                      color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xff2D9CFF)),
                                  ),
                                ),
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
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          dropdownColor: const Color(0xff101820),
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: statuses
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
                        hintText: "Add a description for the exam...",
                        filled: true,
                        fillColor: const Color(0xff101820),
                        hintStyle: const TextStyle(color: Colors.white38),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xff2D9CFF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
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
                              backgroundColor: const Color(0xff2D9CFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Create Exam",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
