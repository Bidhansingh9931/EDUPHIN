import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({super.key});

  @override
  State<CreateSupportTicketPage> createState() => _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
  late ColorScheme _colorScheme;
  String priorityValue = "Low";
  bool _isSubmitting = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.post('counselor/tickets', {
        'title': titleController.text,
        'description': descriptionController.text,
        'category': categoryController.text,
        'priority': priorityValue.toLowerCase(),
      });

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 302) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ticket submitted successfully!")),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final error = jsonDecode(response.body)['message'] ?? "Failed to submit ticket";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Support Ticket"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ticket Details", 
                    style: GoogleFonts.roboto(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: _colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// 🔹 Issue Title
                  _buildLabel("Issue Title *"),
                  _buildTextField(titleController, "Enter a short summary", validator: (v) {
                    if (v == null || v.isEmpty) return "Title is required";
                    return null;
                  }),
                  const SizedBox(height: 20),

                  /// 🔹 Issue Description
                  _buildLabel("Issue Description *"),
                  _buildTextField(descriptionController, "Describe your issue in detail", maxLines: 4, validator: (v) {
                    if (v == null || v.isEmpty) return "Description is required";
                    return null;
                  }),
                  const SizedBox(height: 20),

                  /// 🔹 Priority Dropdown
                  _buildLabel("Priority *"),
                  _buildDropdown(),
                  const SizedBox(height: 20),

                  /// 🔹 Category
                  _buildLabel("Category (Optional)"),
                  _buildTextField(categoryController, "e.g., fee, login, issue"),
                  const SizedBox(height: 32),

                  /// 🔹 Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submitTicket,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("SUBMIT TICKET", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("BACK", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: _colorScheme.onSurface, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priorityValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(color: _colorScheme.onSurface, fontSize: 15),
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
