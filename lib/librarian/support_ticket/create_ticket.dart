import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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
  String selectedPriority = "Low";
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

    setState(() => _isLoading = true);
    try {
      await ApiService.createLibrarianTicket({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'priority': selectedPriority.toLowerCase(),
        'category': _categoryController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket created successfully")));
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Support Ticket"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(20)),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(context.md),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.support_agent_outlined, size: context.scale(40), color: colorScheme.onPrimaryContainer),
                            ),
                            SizedBox(height: context.md),
                            Text(
                              "New Support Ticket",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: context.sm),
                            Text(
                              "Describe your issue and we'll get back to you.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.xl),
                      _buildInputField(context, "Issue Title *", "Briefly describe the problem", controller: _titleController, validator: (v) => v == null || v.isEmpty ? "Required" : null),
                      _buildInputField(context, "Issue Description *", "Provide more details...", maxLines: 5, controller: _descriptionController, validator: (v) => v == null || v.isEmpty ? "Required" : null),
                      _buildResponsiveRow(context, [
                        _buildDropdownField(context, "Priority *", selectedPriority, ["Low", "Medium", "High"], (val) {
                          setState(() => selectedPriority = val!);
                        }),
                        _buildInputField(context, "Category (Optional)", "e.g. Technical, Login", controller: _categoryController),
                      ]),
                      SizedBox(height: context.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: context.md),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                              ),
                              child: const Text("CANCEL"),
                            ),
                          ),
                          SizedBox(width: context.md),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submitTicket,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: context.md),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: context.scale(20),
                                      width: context.scale(20),
                                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                                    )
                                  : const Text("SUBMIT TICKET"),
                            ),
                          ),
                        ],
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

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) {
      return Column(
        children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.sm), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: entry.key < children.length - 1 ? context.sm : 0),
                  child: entry.value,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String hint, {int maxLines = 1, TextEditingController? controller, String? Function(String?)? validator}) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.xs),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(fontSize: context.font(14)),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.all(context.scale(12)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
