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
        title: const Text("Submit New Ticket"),
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
                              validator: (val) => val!.isEmpty ? "Required" : null,
                            ),
                            _buildTextField(
                              context,
                              label: "Description *",
                              hintText: "Provide details about your issue...",
                              controller: _descController,
                              maxLines: 5,
                              icon: Icons.description,
                              validator: (val) => val!.isEmpty ? "Required" : null,
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
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitTicket,
                            child: const Text("SUBMIT TICKET"),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required String hintText, required TextEditingController controller, int maxLines = 1, IconData? icon, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Priority", style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _priority,
            items: ['low', 'medium', 'high'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _priority = val!),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.priority_high, size: 18)),
          ),
        ],
      ),
    );
  }
}
