import 'package:flutter/material.dart';

// Data model for Section
class Section {
  final String name;
  final int limit;
  final String mentor;

  Section({required this.name, required this.limit, required this.mentor});
}

class EditSectionPage extends StatefulWidget {
  const EditSectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _mentorController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSectionDetails();
  }

  Future<void> _fetchSectionDetails() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    final section = Section(name: "Section A", limit: 30, mentor: "Dr. Emily Carter");

    if (mounted) {
      setState(() {
        _nameController.text = section.name;
        _limitController.text = section.limit.toString();
        _mentorController.text = section.mentor;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSection() async {
    // Validate form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final updatedData = {
      'name': _nameController.text,
      'limit': _limitController.text,
      'mentor': _mentorController.text,
    };

    print('Updating section with data: $updatedData');

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section updated successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    _mentorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Section"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            controller: _nameController,
                            label: "Section Name",
                            hint: "e.g., Section A",
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a section name' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            theme: theme,
                            controller: _limitController,
                            label: "Class Limit",
                            hint: "e.g., 30",
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Please set a class limit' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            theme: theme,
                            controller: _mentorController,
                            label: "Mentor Name",
                            hint: "e.g., Dr. Emily Carter",
                            validator: (value) =>
                                value!.isEmpty ? 'Please assign a mentor' : null,
                          ),
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
                                  onPressed: _isSaving ? null : _updateSection,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    foregroundColor:
                                        theme.colorScheme.onPrimaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Text("Update Section"),
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

  // --- Reusable TextField Widget ---
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
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onPrimary)),
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
