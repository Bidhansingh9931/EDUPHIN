import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Remark")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add remark for ${widget.studentName}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _remarkType,
                decoration: const InputDecoration(labelText: "Remark Type", border: OutlineInputBorder()),
                items: ['Positive', 'Negative'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _remarkType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarkController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Remark Description", border: OutlineInputBorder(), alignLabelWithHint: true),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromDateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "From Date", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () => _selectDate(context, _fromDateController),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _toDateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: "To Date (Optional)", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      onTap: () => _selectDate(context, _toDateController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRemark,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSaving ? const CircularProgressIndicator() : const Text("SAVE REMARK"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
