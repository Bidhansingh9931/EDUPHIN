import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'common_widgets.dart';

class CreateSupportTicketPage extends StatefulWidget {
  const CreateSupportTicketPage({super.key});

  @override
  State<CreateSupportTicketPage> createState() => _CreateSupportTicketPageState();
}

class _CreateSupportTicketPageState extends State<CreateSupportTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? _priority = 'low';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and description are required"), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.createTicket(
        _titleController.text,
        _descriptionController.text,
        _priority!,
        category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket created successfully!"), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            const Text("Create New Support Ticket"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final theme = context.theme;
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel(context, "Issue Title *"),
            buildTextField(context, _titleController, "Enter title"),
            SizedBox(height: context.spacing),
            buildLabel(context, "Issue Description *"),
            buildTextField(context, _descriptionController, "Enter description", maxLines: 4),
            SizedBox(height: context.spacing),
            buildLabel(context, "Priority *"),
            buildDropdown(context, ['low', 'medium', 'high'], _priority, (val) => setState(() => _priority = val), hint: "Select Priority"),
            SizedBox(height: context.spacing),
            buildLabel(context, "Category (Optional)"),
            buildTextField(context, _categoryController, "e.g., login, issue"),
            SizedBox(height: context.scale(32)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: _isLoading
                        ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : Text("SUBMIT TICKET", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: context.spacing),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: Text("BACK", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Removed _buildFieldLabel as it's replaced by buildLabel from common_widgets.dart
}
