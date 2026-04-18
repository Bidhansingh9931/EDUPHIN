import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/api_service.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({super.key});

  @override
  State<CreateSupportTicketPage> createState() => _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
  String priorityValue = "Low";
  bool _isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  Future<void> _submitTicket() async {
    final theme = context.theme;
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
        priorityValue.toLowerCase(),
        category: categoryController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ticket created successfully"),
            backgroundColor: Color(0xFF10B981), // Emerald
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating ticket: $e"),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New Ticket",
          style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(context.scale(16)),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.scale(context.isMobile ? 20 : 32)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit_note, color: colorScheme.primary, size: context.scale(24)),
                                  SizedBox(width: context.scale(12)),
                                  Text(
                                    "Ticket Details",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.scale(32)),

                              /// 🔹 Issue Title
                              _label(context, "Issue Title *"),
                              SizedBox(height: context.scale(8)),
                              _buildTextField(context, titleController, hint: "Enter a brief summary of the issue"),

                              SizedBox(height: context.scale(24)),

                              /// 🔹 Category
                              _label(context, "Category (Optional)"),
                              SizedBox(height: context.scale(8)),
                              _buildTextField(context, categoryController, hint: "e.g., Fees, Login, Academics"),

                              SizedBox(height: context.scale(24)),

                              /// 🔹 Priority Dropdown
                              _label(context, "Priority *"),
                              SizedBox(height: context.scale(8)),
                              _buildDropdown(context),

                              SizedBox(height: context.scale(24)),

                              /// 🔹 Issue Description
                              _label(context, "Issue Description *"),
                              SizedBox(height: context.scale(8)),
                              _buildTextField(context, descriptionController, maxLines: 5, hint: "Describe your issue in detail..."),

                              SizedBox(height: context.scale(40)),

                              /// 🔹 Buttons
                              SizedBox(
                                width: double.infinity,
                                height: context.scale(54),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    elevation: 0,
                                  ),
                                  onPressed: _submitTicket,
                                  child: Text(
                                    "SUBMIT TICKET",
                                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.scale(16)),
                              SizedBox(
                                width: double.infinity,
                                height: context.scale(54),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurface,
                                    elevation: 0,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(40)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.font(14),
        fontWeight: FontWeight.w500,
        color: context.theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, {int maxLines = 1, String? hint}) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return DropdownButtonFormField<String>(
      value: priorityValue,
      dropdownColor: colorScheme.surfaceContainerHighest,
      isExpanded: true,
      items: ["Low", "Medium", "High"]
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface)),
              ))
          .toList(),
      onChanged: (val) {
        setState(() {
          priorityValue = val!;
        });
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      ),
    );
  }
}
