import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class CreateNewSectionPage extends StatefulWidget {
  final int classId;
  const CreateNewSectionPage({super.key, required this.classId});

  @override
  State<CreateNewSectionPage> createState() => _CreateNewSectionPageState();
}

class _CreateNewSectionPageState extends State<CreateNewSectionPage> {
  final _formKey = GlobalKey<FormState>(); // Add a form key for validation
  final _sectionNameController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isLoading = false;
  bool _isFetchingMentors = true;

  List<Map<String, dynamic>> _mentors = [];
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    setState(() {
      _isFetchingMentors = true;
    });
    try {
      // CORRECTED: Use the 'meta' endpoint to get teachers and other related data.
      final response = await ApiService.get('manager/class-schedules/meta');
      if (mounted) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
          // CORRECTED: The list of teachers is under the 'teachers' key.
          final List<dynamic> teachersList = responseData['teachers'];
          // Safely process the list to handle potential nulls in names
          final processedMentors = teachersList.map((teacher) {
            final firstName = teacher['first_name'] ?? '';
            final lastName = teacher['last_name'] ?? '';
            final fullName = '$firstName $lastName'.trim();
            return {
              'id': teacher['id'],
              'name': fullName.isNotEmpty ? fullName : 'Unnamed Mentor',
            };
          }).where((mentor) => mentor['id'] != null).toList(); // Filter out invalid entries

          setState(() {
            _mentors = processedMentors;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to load mentors.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An error occurred while fetching mentors: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingMentors = false;
        });
      }
    }
  }

  Future<void> _createSection() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('manager/sections', {
        'class_id': widget.classId,
        'section_name': _sectionNameController.text,
        'section_limit': int.tryParse(_limitController.text) ?? 0,
        'mentor_id':
            _selectedMentorId != null ? int.parse(_selectedMentorId!) : null,
      });

      if (mounted) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 201 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Section created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Pop with true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Failed to create section.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
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
    _sectionNameController.dispose();
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
            constraints:
                const BoxConstraints(maxWidth: 500), // Limits width on large screens
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a section name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildMentorDropdown(theme),
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _limitController,
                      label: "Class Limit",
                      hint: "e.g., 40",
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please set a class limit'
                          : null,
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
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3),
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

  Widget _buildMentorDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mentor Teacher",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMentorId, // Use value instead of initialValue
          hint: _isFetchingMentors
              ? const Text('Loading Mentors...')
              : const Text('Select a Mentor'),
          isExpanded: true,
          decoration: InputDecoration(
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
          items: _mentors.map<DropdownMenuItem<String>>((mentor) {
            return DropdownMenuItem<String>(
              value: mentor['id'].toString(),
              child: Text(mentor['name']),
            );
          }).toList(),
          onChanged: _isFetchingMentors
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedMentorId = newValue;
                  });
                },
          validator: (value) => value == null ? 'Please select a mentor' : null,
        ),
      ],
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
