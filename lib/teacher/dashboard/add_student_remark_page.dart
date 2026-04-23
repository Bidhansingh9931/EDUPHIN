import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'common_widgets.dart';

class AddStudentRemarkPage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const AddStudentRemarkPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<AddStudentRemarkPage> createState() => _AddStudentRemarkPageState();
}

class _AddStudentRemarkPageState extends State<AddStudentRemarkPage> {
  final _formKey = GlobalKey<FormState>();
  String _remarkType = 'Positive';
  final _remarkController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _remarkController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveRemark() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.post('teacher/student/remarks', {
        'student_id': widget.studentId,
        'remarks_type': _remarkType,
        'remarks': _remarkController.text,
        'from_date': _fromDateController.text,
        'to_date': _toDateController.text.isNotEmpty ? _toDateController.text : null,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remark added successfully")));
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? "Failed to save remark");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Remark")),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add remark for ${widget.studentName}", 
                    style: TextStyle(
                      fontSize: context.font(16), 
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    )
                  ),
                  SizedBox(height: context.scale(24)),
                  
                  buildLabel(context, "Remark Type"),
                  buildDropdown<String>(
                    context, 
                    ['Positive', 'Negative'], 
                    _remarkType, 
                    (val) => setState(() => _remarkType = val!),
                  ),
                  
                  SizedBox(height: context.scale(16)),
                  buildLabel(context, "Remark Description"),
                  buildTextField(
                    context, 
                    _remarkController, 
                    "Enter remark description...", 
                    maxLines: 4,
                  ),
                  
                  SizedBox(height: context.scale(16)),
                  buildResponsiveRow(context, [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel(context, "From Date"),
                        buildDateField(context, _fromDateController, "Select start date"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel(context, "To Date (Optional)"),
                        buildDateField(context, _toDateController, "Select end date"),
                      ],
                    ),
                  ]),
                  
                  SizedBox(height: context.scale(32)),
                  buildActionButton(
                    context, 
                    "SAVE REMARK", 
                    _saveRemark,
                  ),
                  if (_isSaving) ...[
                    SizedBox(height: context.scale(16)),
                    const Center(child: CircularProgressIndicator()),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
