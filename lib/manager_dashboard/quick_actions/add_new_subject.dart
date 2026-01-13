import 'dart:async';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewSubject {
  String subjectName = '';
  String subjectCode = '';
  String description = '';
  String credit = '';
  String? type;
  String? status;
}

class SubjectFormData {
  final List<String> types;
  final List<String> statuses;

  SubjectFormData({required this.types, required this.statuses});
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockSubjectApiService {
  Future<SubjectFormData> fetchSubjectFormData() async {
    // Simulate fetching data for dropdowns from an API
    await Future.delayed(const Duration(milliseconds: 500));
    return SubjectFormData(
      types: ['Theory', 'Practical', 'Project'],
      statuses: ['Active', 'Inactive'],
    );
  }

  Future<bool> addSubject(NewSubject subject) async {
    // Simulate sending data to an API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint(
        'Submitting to API: Name: ${subject.subjectName}, Code: ${subject.subjectCode}, Credit: ${subject.credit}, Type: ${subject.type}, Status: ${subject.status}');
    // Simulate a successful API call
    return true;
  }
}

// ───────────────────────────────────────────────────────────
//                      ADD NEW SUBJECT PAGE
// ───────────────────────────────────────────────────────────

class AddNewSubject extends StatefulWidget {
  const AddNewSubject({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSubjectState();
}

class _AddNewSubjectState extends State<AddNewSubject> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Subject', style: TextStyle(color: theme.colorScheme.onPrimary)),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
          child: CustomAddSubjectBox(),
        ),
      ),
    );
  }
}

class CustomAddSubjectBox extends StatefulWidget {
  const CustomAddSubjectBox({super.key});

  @override
  State<CustomAddSubjectBox> createState() => _CustomAddSubjectBoxState();
}

class _CustomAddSubjectBoxState extends State<CustomAddSubjectBox> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockSubjectApiService();
  late Future<SubjectFormData> _formDataFuture;

  final _newSubject = NewSubject();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formDataFuture = _apiService.fetchSubjectFormData();
  }

  Future<void> _submitForm() async {
    if (_newSubject.subjectName.isEmpty ||
        _newSubject.subjectCode.isEmpty ||
        _newSubject.credit.isEmpty ||
        _newSubject.type == null ||
        _newSubject.status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.addSubject(_newSubject);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Subject added successfully!' : 'Failed to add subject.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<SubjectFormData>(
      future: _formDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading data: ${snapshot.error}"));
        }
        if (snapshot.hasData) {
          final formData = snapshot.data!;
          _newSubject.type ??= formData.types.first;
          _newSubject.status ??= formData.statuses.first;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subject Name", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _newSubject.subjectName,
                    onChanged: (val) => _newSubject.subjectName = val,
                    decoration: InputDecoration(
                        hintText: "Enter Subject Name",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 16),
                  Text("Subject Code", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _newSubject.subjectCode,
                    onChanged: (val) => _newSubject.subjectCode = val,
                    decoration: InputDecoration(
                        hintText: "Enter Subject Code",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 16),
                  Text("Description (Optional)", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _newSubject.description,
                    onChanged: (val) => _newSubject.description = val,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: "Enter a brief description of the class...",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 16),
                  Text("Credit", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _newSubject.credit,
                    onChanged: (val) => _newSubject.credit = val,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Enter Subject Credit",
                        hintStyle: TextStyle(color: theme.hintColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 16),
                  Text("Type", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _newSubject.type,
                    items: formData.types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _newSubject.type = val),
                    decoration: InputDecoration(
                        hintText: "Select Type",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 16),
                  Text("Status", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _newSubject.status,
                    items: formData.statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _newSubject.status = val),
                    decoration: InputDecoration(
                        hintText: "Select Status",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.onPrimary.withAlpha(25),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                          child: Text("Cancel", style: TextStyle(fontSize: 18, color: theme.colorScheme.onPrimary,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // A distinct color for the primary action
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                          child: _isSubmitting
                              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : Text("Add Subject", style: TextStyle(fontSize: 18, color: theme.colorScheme.onPrimary,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('No form data available.'));
      },
    );
  }
}
