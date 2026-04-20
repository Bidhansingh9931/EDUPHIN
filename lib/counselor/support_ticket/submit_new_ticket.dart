import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({super.key});

  @override
  State<CreateSupportTicketPage> createState() => _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
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
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Create Support Ticket", style: TextStyle(fontSize: context.font(20))),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(20)),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.scale(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ticket Details",
                        style: GoogleFonts.roboto(
                          fontSize: context.font(18),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.scale(24)),

                      /// 🔹 Issue Title
                      _buildLabel("Issue Title *"),
                      _buildTextField(titleController, "Enter a short summary", validator: (v) {
                        if (v == null || v.isEmpty) return "Title is required";
                        return null;
                      }),
                      SizedBox(height: context.scale(20)),

                      /// 🔹 Issue Description
                      _buildLabel("Issue Description *"),
                      _buildTextField(descriptionController, "Describe your issue in detail", maxLines: 4, validator: (v) {
                        if (v == null || v.isEmpty) return "Description is required";
                        return null;
                      }),
                      SizedBox(height: context.scale(20)),

                      /// 🔹 Priority Dropdown
                      _buildLabel("Priority *"),
                      _buildDropdown(),
                      SizedBox(height: context.scale(20)),

                      /// 🔹 Category
                      _buildLabel("Category (Optional)"),
                      _buildTextField(categoryController, "e.g., fee, login, issue"),
                      SizedBox(height: context.scale(32)),

                      /// 🔹 Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: context.scale(50),
                              child: FilledButton(
                                onPressed: _isSubmitting ? null : _submitTicket,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: context.scale(20),
                                        width: context.scale(20),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                                      )
                                    : Text("SUBMIT TICKET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                              ),
                            ),
                          ),
                          SizedBox(width: context.scale(16)),
                          Expanded(
                            child: SizedBox(
                              height: context.scale(50),
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                ),
                                child: Text("BACK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
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
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8)),
      child: Text(
        label,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, String? Function(String?)? validator}) {
    final colorScheme = context.theme.colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(15)),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(14)),
      ),
    );
  }

  Widget _buildDropdown() {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priorityValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(15)),
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
