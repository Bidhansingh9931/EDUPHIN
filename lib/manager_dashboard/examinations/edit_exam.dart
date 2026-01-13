import 'package:flutter/material.dart';

class EditExamPage extends StatefulWidget {
  const EditExamPage({super.key});

  @override
  State<EditExamPage> createState() => _EditExamPageState();
}

class _EditExamPageState extends State<EditExamPage> {
  final TextEditingController examNameController =
  TextEditingController(text: "Mid-Term Examination 2025");
  final TextEditingController examCodeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String examType = "Objective";
  String status = "Active";

  List<String> examTypes = ["Objective", "Subjective", "Practical"];
  List<String> statusList = ["Active", "Inactive"];

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
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
                    TextField(
                      controller: examNameController,
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
                          items: examTypes.map((e) =>
                              DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => examType = v!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text("Exam Code *",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: examCodeController,
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
                              TextField(
                                controller: startDateController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xff101820),
                                  hintText: "DD/MM/YYYY",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onTap: () => pickDate(startDateController),
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
                              TextField(
                                controller: endDateController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xff101820),
                                  hintText: "DD/MM/YYYY",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onTap: () => pickDate(endDateController),
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
                          items: statusList.map((e) =>
                              DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => status = v!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text("Description",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    TextField(
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
                        icon: const Icon(Icons.save,color: Colors.white,size: 20,),
                        label: const Text("Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {},
                      ),
                    )
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
