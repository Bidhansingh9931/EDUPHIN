import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
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
//                         API SERVICE
// ───────────────────────────────────────────────────────────

class SubjectApiService {
  Future<SubjectFormData> fetchSubjectFormData() async {
    // The API doesn't provide an endpoint for this, so we use static data
    // that matches the API's validation rules.
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate a tiny delay
    return SubjectFormData(
      types: ['Theory', 'Practical', 'Applied'], // Changed 'Project' to 'Applied'
      statuses: ['Active', 'Inactive'],
    );
  }

  Future<Map<String, dynamic>> addSubject(NewSubject subject) async {
    final body = {
      'subject_name': subject.subjectName,
      'code': subject.subjectCode,
      'description': subject.description,
      'credit': subject.credit,
      'type': subject.type,
      'status': subject.status?.toLowerCase(), // API expects lowercase
    };

    final response = await ApiService.post('manager/subjects', body);
    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['status'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add subject.');
      }
    } else {
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        throw Exception(errors.values.first[0]); // Throw first validation error
      }
      throw Exception(responseData['message'] ?? 'An error occurred.');
    }
  }
}

// ───────────────────────────────────────────────────────────
//                      ADD NEW SUBJECT PAGE
// ───────────────────────────────────────────────────────────

class AddNewSubjectPage extends StatefulWidget {
  const AddNewSubjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSubjectPageState();
}

class _AddNewSubjectPageState extends State<AddNewSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = SubjectApiService();
  late Future<SubjectFormData> _formDataFuture;

  final _newSubject = NewSubject();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formDataFuture = _apiService.fetchSubjectFormData();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final responseData = await _apiService.addSubject(_newSubject);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Subject added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Pop with success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add New Subject'),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<SubjectFormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildActionButtons(theme);
          }
          return const SizedBox.shrink();
        },
      ),
      body: FutureBuilder<SubjectFormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final formData = snapshot.data!;
            // Set default values if not already set
            _newSubject.type ??= formData.types.first;
            _newSubject.status ??= formData.statuses.first;

            return LayoutBuilder(builder: (context, constraints) {
              return _buildForm(theme, formData, constraints.maxWidth > 700);
            });
          } else {
            return const Center(child: Text('No form data available.'));
          }
        },
      ),
    );
  }

  Widget _buildForm(ThemeData theme, SubjectFormData formData, bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Limit form width
          child: Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isWide
                  ? _buildWideLayout(theme, formData)
                  : _buildNarrowLayout(theme, formData),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme, SubjectFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(theme, "Subject Name",
            (val) => _newSubject.subjectName = val),
        _buildTextField(theme, "Subject Code",
            (val) => _newSubject.subjectCode = val),
        _buildTextField(theme, "Description (Optional)",
            (val) => _newSubject.description = val,
            isOptional: true, maxLines: 4),
        _buildTextField(theme, "Credit", (val) => _newSubject.credit = val,
            keyboardType: TextInputType.number),
        _buildDropdown(theme, "Type", _newSubject.type, formData.types,
            (val) => setState(() => _newSubject.type = val)),
        _buildDropdown(theme, "Status", _newSubject.status, formData.statuses,
            (val) => setState(() => _newSubject.status = val)),
        const SizedBox(height: 80), // Padding for the FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme, SubjectFormData formData) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildTextField(theme, "Subject Name",
                    (val) => _newSubject.subjectName = val)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField(theme, "Subject Code",
                    (val) => _newSubject.subjectCode = val)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(theme, "Description (Optional)",
            (val) => _newSubject.description = val,
            isOptional: true, maxLines: 3),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildTextField(
                    theme, "Credit", (val) => _newSubject.credit = val,
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDropdown(theme, "Type", _newSubject.type,
                    formData.types, (val) => setState(() => _newSubject.type = val))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDropdown(theme, "Status", _newSubject.status,
                    formData.statuses, (val) => setState(() => _newSubject.status = val))),
          ],
        ),
        const SizedBox(height: 80), // Padding for the FAB
      ],
    );
  }

  Widget _buildTextField(ThemeData theme, String label,
      ValueChanged<String> onChanged,
      {bool isOptional = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            validator: isOptional
                ? null
                : (value) => value!.isEmpty ? '$label is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value,
      List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: "Select $label",
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) => value == null ? 'Please select a $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.dividerColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text("Cancel",
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurface)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              icon: _isSubmitting ? Container() : const Icon(Icons.add),
              label: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text("Add Subject",
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
