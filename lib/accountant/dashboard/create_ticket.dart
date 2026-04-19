import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  String _priority = "low";
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.createAccountantTicket({
        'title': _titleController.text,
        'description': _descController.text,
        'priority': _priority,
        'category': _categoryController.text.isEmpty ? null : _categoryController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket created successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit New Ticket", style: TextStyle(fontSize: context.font(20))),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          context,
                          title: "Basic Information",
                          children: [
                            _buildTextField(
                              context,
                              label: "Issue Title *",
                              hintText: "Briefly describe the issue",
                              controller: _titleController,
                              icon: Icons.title,
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Required";
                                if (!RegExp(r'^[a-zA-Z0-9\s,.\-/#()]+$').hasMatch(val)) {
                                  return "Special characters not allowed";
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              context,
                              label: "Description *",
                              hintText: "Provide details about your issue...",
                              controller: _descController,
                              maxLines: 5,
                              icon: Icons.description,
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Required";
                                if (!RegExp(r'^[a-zA-Z0-9\s,.\-/#()]+$').hasMatch(val)) {
                                  return "Special characters not allowed";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Classification",
                          children: [
                            _buildResponsiveRow(context, [
                              _buildPriorityDropdown(context),
                              _buildTextField(
                                context,
                                label: "Category",
                                hintText: "e.g., IT, Finance",
                                controller: _categoryController,
                                icon: Icons.category,
                                validator: (val) {
                                  if (val != null && val.isNotEmpty && !RegExp(r'^[a-zA-Z0-9\s,.\-/#()]+$').hasMatch(val)) {
                                    return "Special characters not allowed";
                                  }
                                  return null;
                                },
                              ),
                            ]),
                          ],
                        ),
                        SizedBox(height: context.xl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitTicket,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                            ),
                            child: Text("SUBMIT TICKET", style: TextStyle(fontSize: context.font(14))),
                          ),
                        ),
                        SizedBox(height: context.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.only(bottom: context.md),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), 
                topRight: Radius.circular(16)
              ),
            ),
            child: Text(
              title, 
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(15))
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: context.md), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required String hintText, required TextEditingController controller, int maxLines = 1, IconData? icon, String? Function(String?)? validator}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(fontSize: context.font(14)),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon, size: context.scale(18)) : null,
              contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Priority", style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _priority,
            items: ['low', 'medium', 'high'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val.toUpperCase(), style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _priority = val!),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.priority_high, size: context.scale(18)),
              contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
            ),
          ),
        ],
      ),
    );
  }
}
