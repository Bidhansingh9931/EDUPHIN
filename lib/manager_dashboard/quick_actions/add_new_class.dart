import 'dart:async';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewClass {
  String className = '';
  String classCode = '';
  String description = '';
  String? level;
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockClassApiService {
  Future<List<String>> fetchClassLevels() async {
    // Simulate fetching data for dropdowns from an API
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Primary',
      'Secondary',
      'Higher Secondary',
      'Undergraduate',
      'Postgraduate'
    ];
  }

  Future<bool> addClass(NewClass newClass) async {
    // Simulate sending data to an API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Submitting to API:");
    debugPrint(
        'ClassName: ${newClass.className}, ClassCode: ${newClass.classCode}, Level: ${newClass.level}, Description: ${newClass.description}');
    // Simulate a successful API call
    return true;
  }
}

class AddNewClassPage extends StatefulWidget {
  const AddNewClassPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewClassPageState();
}

class _AddNewClassPageState extends State<AddNewClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockClassApiService();
  late Future<List<String>> _levelsFuture;

  // Model to hold all form data
  final _newClass = NewClass();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _levelsFuture = _apiService.fetchClassLevels();
  }

  Future<void> _submitForm() async {
    // Use form validation before submitting
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.addClass(_newClass);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Class added successfully!' : 'Failed to add class.'),
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Class"),
        centerTitle: true,
      ),
      // Using a responsive FAB for actions
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<List<String>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          // Only show button if data has loaded to prevent premature submission
          if (snapshot.hasData) {
            return _buildActionButtons(theme);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      body: FutureBuilder<List<String>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final levels = snapshot.data!;
            return _buildForm(theme, levels);
          } else {
            return const Center(child: Text('No levels data available'));
          }
        },
      ),
    );
  }

  // Builds the main form content
  Widget _buildForm(ThemeData theme, List<String> levels) {
    return SingleChildScrollView(
      // Added responsive padding, including 50 at the bottom
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Limit width on large screens
          child: Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    theme: theme,
                    label: "Class Name",
                    hint: "Enter Class Name",
                    onChanged: (value) => _newClass.className = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Class name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    theme: theme,
                    label: "Class Code",
                    hint: "Enter Class Code",
                    onChanged: (value) => _newClass.classCode = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Class code is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    theme: theme,
                    label: "Description (Optional)",
                    hint: "Enter a brief description of the class...",
                    onChanged: (value) => _newClass.description = value,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(theme, levels),
                  const SizedBox(height: 80), // Padding for the FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Refactored TextField for reusability and consistency
  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Refactored Dropdown for reusability and consistency
  Widget _buildDropdown(ThemeData theme, List<String> levels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Level",
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _newClass.level,
          hint: Text("Select Level", style: TextStyle(color: theme.hintColor)),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          items: levels.map((String level) {
            return DropdownMenuItem<String>(value: level, child: Text(level));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _newClass.level = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a level' : null,
        ),
      ],
    );
  }

  // Responsive action buttons, now in the FAB
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
                  : Text("Add Class", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
