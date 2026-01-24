import 'package:flutter/material.dart';

class CreateNewClassPage extends StatefulWidget {
  const CreateNewClassPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _classCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedLevel;
  final List<String> _levels = ['Primary', 'Secondary', 'Sr. Sec', 'Graduation'];
  bool _isLoading = false;

  Future<void> _createClass() async {
    // Use form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final classData = {
      'name': _classNameController.text,
      'code': _classCodeController.text,
      'description': _descriptionController.text,
      'level': _selectedLevel,
    };

    print('Creating class: $classData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class created successfully!')),
      );
      Navigator.pop(context);
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create New Class"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Limit form width
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primaryColor,
                ),
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _classCodeController,
                      label: "Class Code",
                      hint: "e.g., C-X",
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a class code' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _descriptionController,
                      label: "Description (Optional)",
                      hint: "Enter a short description for the class",
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(theme),
                    const SizedBox(height: 24),
                    // --- Responsive Button Row ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: theme.colorScheme.onPrimary,
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createClass,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 3),
                                  )
                                : const Text("Create Class"),
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
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
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
        Text("Level", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedLevel,
          hint: Text("Select Level", style: TextStyle(color: theme.hintColor)),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
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
