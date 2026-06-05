import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/subject_list.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';

class UpdateSubjectPage extends StatefulWidget {
  final Subject subject;
  const UpdateSubjectPage({super.key, required this.subject});

  @override
  State<StatefulWidget> createState() => _UpdateSubjectPageState();
}

class _UpdateSubjectPageState extends State<UpdateSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final subject = widget.subject;
    _nameController.text = subject.name;
    _codeController.text = subject.code;
    _descriptionController.text = subject.description;
    _creditController.text = subject.credit;
    _selectedType = subject.type;
    _selectedStatus = subject.isActive ? 'Active' : 'Inactive';
  }

  Future<void> _updateSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final body = {
        'subject_name': _nameController.text,
        'code': _codeController.text,
        'description': _descriptionController.text,
        'credit': _creditController.text,
        'type': _selectedType,
        'status': _selectedStatus?.toLowerCase(),
      };

      final response = await ApiService.put('manager/subjects/${widget.subject.id}', body);
      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Subject updated successfully!'), backgroundColor: context.theme.colorScheme.primary),
        );
        Navigator.of(context).pop(true);
      } else {
        String errorMessage = responseData['message'] ?? 'An unknown error occurred.';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.map((e) => e[0]).join('\n');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Update Subject",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(8), context.scale(16), context.scale(24)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(width: context.scale(16)),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateSubject,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: _isSaving
                    ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                    : Text("Update Subject", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Subject Details",
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                  ),
                  SizedBox(height: context.scale(4)),
                  Text(
                    "Update the information below for this subject.",
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11)),
                  ),
                  SizedBox(height: context.scale(24)),
                  buildFilterCard(
                    context,
                    children: [
                      buildLabel(context, "Subject Name"),
                      buildTextField(context, _nameController, "Enter Subject Name"),
                      buildLabel(context, "Subject Code"),
                      buildTextField(context, _codeController, "Enter Subject Code"),
                      buildLabel(context, "Description (Optional)"),
                      buildTextField(context, _descriptionController, "Enter a brief description...", maxLines: 4),
                      buildLabel(context, "Credit"),
                      buildTextField(context, _creditController, "Enter Subject Credit"),
                      buildLabel(context, "Type"),
                      buildDropdown(context, ['Theory', 'Practical', 'Applied'], _selectedType, (val) => setState(() => _selectedType = val)),
                      buildLabel(context, "Status"),
                      buildDropdown(context, ['Active', 'Inactive'], _selectedStatus, (val) => setState(() => _selectedStatus = val)),
                      SizedBox(height: context.scale(16)),
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
}
