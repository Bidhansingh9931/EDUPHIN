import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({super.key});

  @override
  State<CreateSupportTicketPage> createState() => _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

  String priorityValue = "Low";
  bool _isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  Future<void> _submitTicket() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Description are required")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.createStudentTicket(
        titleController.text,
        descriptionController.text,
        priorityValue,
        category: categoryController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket created successfully")),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating ticket: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create New Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Ticket Details",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        /// 🔹 Issue Title
                        _label("Issue Title *"),
                        const SizedBox(height: 8),
                        _buildTextField(titleController, hint: "Enter a brief summary of the issue"),

                        const SizedBox(height: 20),

                        /// 🔹 Category
                        _label("Category (Optional)"),
                        const SizedBox(height: 8),
                        _buildTextField(categoryController, hint: "e.g., Fees, Login, Academics"),

                        const SizedBox(height: 20),

                        /// 🔹 Priority Dropdown
                        _label("Priority *"),
                        const SizedBox(height: 8),
                        _buildDropdown(),

                        const SizedBox(height: 20),

                        /// 🔹 Issue Description
                        _label("Issue Description *"),
                        const SizedBox(height: 8),
                        _buildTextField(descriptionController, maxLines: 5, hint: "Describe your issue in detail..."),

                        const SizedBox(height: 32),

                        /// 🔹 Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: _submitTicket,
                            child: const Text(
                              "SUBMIT TICKET",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: _secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priorityValue,
          isExpanded: true,
          dropdownColor: _card,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: ["Low", "Medium", "High"]
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              priorityValue = val!;
            });
          },
        ),
      ),
    );
  }
}
