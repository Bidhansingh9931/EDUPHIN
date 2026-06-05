import 'dart:async';
import 'dart:convert';
import 'package:eduphin/manager_dashboard/manageClasses/classList/class_list.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class CreateNewClassPage extends StatefulWidget {
  final Class? classToEdit;
  const CreateNewClassPage({super.key, this.classToEdit});

  @override
  State<StatefulWidget> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;
  late TextEditingController _classCodeController;
  late TextEditingController _descriptionController;
  String? _selectedLevel;
  final List<String> _levels = ['Primary', 'Secondary', 'Sr. Sec', 'Graduation'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.classToEdit?.name);
    _classCodeController = TextEditingController(text: widget.classToEdit?.code);
    _descriptionController = TextEditingController(text: widget.classToEdit?.description);
    _selectedLevel = widget.classToEdit?.level;
    if (_selectedLevel != null && !_levels.contains(_selectedLevel)) {
      _selectedLevel = null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final classData = {
        'name': _classNameController.text,
        'code': _classCodeController.text,
        'description': _descriptionController.text,
        'level': _selectedLevel!,
      };

      final response = widget.classToEdit == null
          ? await ApiService.post('manager/classes', classData)
          : await ApiService.put('manager/classes/${widget.classToEdit!.id}', classData);

      final responseData = jsonDecode(response.body);

      if (mounted) {
        final theme = context.theme;
        if ((response.statusCode == 201 || response.statusCode == 200) && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? (widget.classToEdit == null ? 'Class created successfully!' : 'Class updated successfully!')),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
          Navigator.pop(context, true); // Pop with a true result to indicate success
        } else {
          throw Exception(responseData['message'] ?? 'Failed to process request.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _classCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isEditing = widget.classToEdit != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Class" : "Create New Class",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(100)),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.responsive(double.infinity, tablet: 600, desktop: 800)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.scale(16)),
              color: theme.colorScheme.surfaceContainerLow,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: EdgeInsets.all(context.scale(20)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    theme: theme,
                    controller: _classNameController,
                    label: "Class Name",
                    hint: "e.g., Class X",
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a class name' : null,
                  ),
                  SizedBox(height: context.scale(16)),
                  _buildTextField(
                    theme: theme,
                    controller: _classCodeController,
                    label: "Class Code",
                    hint: "e.g., C-X",
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a class code' : null,
                  ),
                  SizedBox(height: context.scale(16)),
                  _buildTextField(
                    theme: theme,
                    controller: _descriptionController,
                    label: "Description (Optional)",
                    hint: "Enter a short description for the class",
                    maxLines: 5,
                  ),
                  SizedBox(height: context.scale(16)),
                  _buildDropdownField(theme),
                  SizedBox(height: context.scale(32)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                            ),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: context.scale(16)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: context.scale(24),
                                  width: context.scale(24),
                                  child: CircularProgressIndicator(strokeWidth: 3, color: theme.colorScheme.onPrimary),
                                )
                              : Text(isEditing ? "Update Class" : "Create Class", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14))),
        SizedBox(height: context.scale(8)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Level", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14))),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<String>(
          value: _selectedLevel,
          dropdownColor: theme.colorScheme.surface,
          hint: Text("Select Level", style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14))),
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLevel = newValue;
            });
          },
          items: _levels.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select a level' : null,
        ),
      ],
    );
  }
}
