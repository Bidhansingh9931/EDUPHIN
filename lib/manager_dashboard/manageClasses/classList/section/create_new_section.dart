import 'package:flutter/material.dart';

class CreateNewSectionPage extends StatefulWidget {
  const CreateNewSectionPage({super.key});

  @override
  State<CreateNewSectionPage> createState() => _CreateNewSectionPageState();
}

class _CreateNewSectionPageState extends State<CreateNewSectionPage> {
  final _formKey = GlobalKey<FormState>(); // Add a form key for validation
  final _sectionNameController = TextEditingController();
  final _mentorController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createSection() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final sectionData = {
      'name': _sectionNameController.text,
      'mentor': _mentorController.text,
      'limit': _limitController.text,
    };

    // In a real app, you would send this to your API
    print('Creating section: $sectionData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section created successfully!')),
      );
      Navigator.pop(context); // Go back after creation
    }
  }

  @override
  void dispose() {
    _sectionNameController.dispose();
    _mentorController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create New Section"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Limits width on large screens
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
                      controller: _sectionNameController,
                      label: "Section Name",
                      hint: "e.g., Section A",
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a section name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _mentorController,
                      label: "Mentor Teacher",
                      hint: "e.g., Mrs. Anjali Sharma",
                      validator: (value) =>
                          value!.isEmpty ? 'Please assign a mentor' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _limitController,
                      label: "Class Limit",
                      hint: "e.g., 40",
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please set a class limit' : null,
                    ),
                    const SizedBox(height: 24),
                    // Responsive button row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: _isLoading ? null : _createSection,
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
                                : const Text("Create Section"),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
}
