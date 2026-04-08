import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
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
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop and indicate success
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create ticket: $e'),
              backgroundColor: Colors.red),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create New Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, 'Title'),
              buildTextField(context, _titleController, 'Enter a title'),
              const SizedBox(height: 16),
              buildLabel(context, 'Description'),
              buildTextField(context, _descriptionController, 'Enter a description'),
              const SizedBox(height: 16),
              buildLabel(context, 'Category (Optional)'),
              buildTextField(context, _categoryController, 'Enter a category'),
              const SizedBox(height: 16),
              buildLabel(context, 'Priority'),
              buildDropdown(context, ['low', 'medium', 'high'], _priority, (newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Ticket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
