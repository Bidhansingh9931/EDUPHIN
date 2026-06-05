import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';

class StaffCreateTicketPage extends StatefulWidget {
  const StaffCreateTicketPage({super.key});

  @override
  State<StaffCreateTicketPage> createState() => _StaffCreateTicketPageState();
}

class _StaffCreateTicketPageState extends State<StaffCreateTicketPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedPriority = "low";
  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.createStaffTicket({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority,
        'category': _categoryController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Create Ticket"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: context.scale(24)),
                _buildForm(context),
                SizedBox(height: context.scale(32)),
                _buildActions(context),
                SizedBox(height: context.scale(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Submit a Support Request",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(20),
          ),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          "Describe your issue and we'll get back to you as soon as possible.",
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel(context, "Issue Title *"),
            buildTextField(context, _titleController, "What's the problem?", prefixIcon: Icons.title_rounded),

            SizedBox(height: context.scale(20)),
            _buildFieldLabel(context, "Description *"),
            buildTextField(
              context,
              _descriptionController,
              "Provide more details about the issue...",
              maxLines: 5,
              prefixIcon: Icons.description_rounded,
            ),

            SizedBox(height: context.scale(20)),
            context.responsive(
              Column(
                children: [
                  _buildPrioritySelector(context),
                  SizedBox(height: context.scale(20)),
                  _buildCategoryField(context),
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPrioritySelector(context)),
                  SizedBox(width: context.scale(20)),
                  Expanded(child: _buildCategoryField(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8), left: context.scale(4)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: context.font(11),
          fontWeight: FontWeight.bold,
          color: context.theme.colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, "Priority *"),
        buildDropdown(
          context,
          ["low", "medium", "high"],
          _selectedPriority,
          (val) => setState(() => _selectedPriority = val!),
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, "Category"),
        buildTextField(context, _categoryController, "e.g. Technical", prefixIcon: Icons.category_outlined),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _submitTicket,
            icon: _isLoading 
                ? SizedBox(width: context.scale(20), height: context.scale(20), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
            label: Text(_isLoading ? "SUBMITTING..." : "SUBMIT TICKET"),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
          ),
        ),
        SizedBox(height: context.scale(12)),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Discard and Return", style: TextStyle(fontSize: context.font(14))),
          ),
        ),
      ],
    );
  }
}

