import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'common_widgets.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  String _priority = 'medium'; // Default priority

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.createTicket(
          _titleController.text,
          _descriptionController.text,
          _priority,
          category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ticket created successfully!'),
              backgroundColor: Color(0xFF10B981)),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create ticket: $e'),
              backgroundColor: Color(0xFFEF4444)),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Ticket'),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scale(16)),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.spacing),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel(context, 'Title'),
                      buildTextField(context, _titleController, 'Enter a title'),
                      SizedBox(height: context.spacing),
                      buildLabel(context, 'Description'),
                      buildTextField(context, _descriptionController, 'Enter a description', maxLines: 4),
                      SizedBox(height: context.spacing),
                      buildLabel(context, 'Category (Optional)'),
                      buildTextField(context, _categoryController, 'Enter a category'),
                      SizedBox(height: context.spacing),
                      buildLabel(context, 'Priority'),
                      buildDropdown(
                        context,
                        ['low', 'medium', 'high'],
                        _priority,
                        (newValue) {
                          setState(() {
                            _priority = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: context.scale(32)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitTicket,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: context.scale(20),
                                  width: context.scale(20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'Submit Ticket',
                                  style: TextStyle(
                                    fontSize: context.font(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
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
