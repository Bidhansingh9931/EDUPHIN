import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddTestimonialQuickAction extends StatefulWidget {
  const AddTestimonialQuickAction({super.key});

  @override
  State<AddTestimonialQuickAction> createState() => _AddTestimonialQuickActionState();
}

class _AddTestimonialQuickActionState extends State<AddTestimonialQuickAction> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _messageController = TextEditingController();
  File? _imageFile;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final fields = {
        'name': _nameController.text.trim(),
        'designation': _designationController.text.trim(),
        'message': _messageController.text.trim(),
      };

      await ApiService.storeOrUpdateTestimonial(
        fields,
        image: _imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Testimonial added successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Testimonial"),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Card(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            ),
                            child: Column(
                              children: [
                                Text("New Testimonial",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                Text("Add customer feedback to the platform.",
                                    style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, Icons.person, "Full Name *"),
                                TextFormField(
                                  controller: _nameController,
                                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                  decoration: const InputDecoration(hintText: "e.g., John Doe"),
                                ),
                                const SizedBox(height: 20),
                                _buildLabel(context, Icons.business_center, "Designation *"),
                                TextFormField(
                                  controller: _designationController,
                                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                  decoration: const InputDecoration(hintText: "e.g., Happy Customer"),
                                ),
                                const SizedBox(height: 20),
                                _buildLabel(context, Icons.message, "Message *"),
                                TextFormField(
                                  controller: _messageController,
                                  maxLines: 5,
                                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                  decoration: const InputDecoration(hintText: "Write feedback here..."),
                                ),
                                const SizedBox(height: 24),
                                _buildLabel(context, Icons.image, "Profile Photo"),
                                _buildFilePicker(context),
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("CANCEL"),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _save,
                                        child: const Text("SAVE"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                  alignment: Alignment.center,
                  child: Text("Choose Image", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(_imageFile != null ? _imageFile!.path.split('/').last : "No file chosen",
                        style: TextStyle(color: theme.hintColor, fontSize: 13), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text("JPG, PNG, GIF files only.", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}
