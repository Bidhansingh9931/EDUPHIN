import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class Uploadstudymaterial extends StatefulWidget {
  const Uploadstudymaterial({super.key});

  @override
  State<Uploadstudymaterial> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<Uploadstudymaterial> {
  final _formKey = GlobalKey<FormState>();

  String? selectedSchedule;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dueDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Material"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Schedule *",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedSchedule,
                        isExpanded: true,
                        decoration: const InputDecoration(hintText: "Select Schedule"),
                        items: [
                          "Class 10-A",
                          "Class 10-B",
                          "Class 11-A",
                          "Class 12-C"
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSchedule = value;
                          });
                        },
                        validator: (value) =>
                        value == null ? "Please select a schedule" : null,
                      ),

                      const SizedBox(height: 24),

                      Text("Title *",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(hintText: "Enter title"),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Title required" : null,
                      ),

                      const SizedBox(height: 24),

                      Text("Description",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descController,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: "Enter description (optional)"),
                      ),

                      const SizedBox(height: 24),

                      Text("Upload File *",
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          // Logic to pick file
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text("Choose File",
                                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text("No file chosen",
                                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Allowed: PDF, Word, PPT, Images. Max: 20 MB.",
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Material Uploaded Successfully")),
                                  );
                                }
                              },
                              child: const Text("UPLOAD"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CANCEL"),
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
      ),
    );
  }
}
