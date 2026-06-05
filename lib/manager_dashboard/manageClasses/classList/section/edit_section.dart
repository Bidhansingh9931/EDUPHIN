import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';

import 'section_model.dart';

class EditSectionPage extends StatefulWidget {
  final Section section;

  const EditSectionPage({super.key, required this.section});

  @override
  State<StatefulWidget> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();

  bool _isSaving = false;
  bool _isFetchingMentors = true;
  List<Map<String, dynamic>> _mentors = [];
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.section.name;
    _limitController.text = widget.section.limit.toString();
    _fetchMentors();
  }

  Future<void> _fetchMentors() async {
    setState(() => _isFetchingMentors = true);
    try {
      final response = await ApiService.get('manager/teachers');
      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> teachersList = responseData['data'] ?? [];
        _mentors = teachersList.where((teacher) => teacher['user'] != null).map((teacher) {
          final user = teacher['user'];
          return {
            'id': user['id'] is int ? user['id'] : int.tryParse(user['id'].toString()) ?? 0,
            'name': '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
          };
        }).toList();

        // Find the mentor whose name matches the section's mentor name.
        final currentMentor = _mentors.firstWhere(
              (m) => m['name'] == widget.section.mentor,
          orElse: () => {'id': null}, // Return a map with a null id if not found
        );

        setState(() {
          if (currentMentor['id'] != null && currentMentor['id'] != 0) {
            _selectedMentorId = currentMentor['id'].toString();
          }
        });
      } else {
        if (mounted) {
          ErrorHandler.showError(context, responseData['message'] ?? 'Failed to load mentors.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingMentors = false);
      }
    }
  }

  Future<void> _updateSection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.put(
        'manager/sections/${widget.section.id}',
        {
          'section_name': _nameController.text,
          'section_limit': int.tryParse(_limitController.text) ?? 0,
          if (_selectedMentorId != null) 'mentor_id': int.parse(_selectedMentorId!),
        },
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      final theme = Theme.of(context);
      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Section updated successfully!'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        Navigator.pop(context, true); // Pop with true to indicate success
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update section.');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Edit Section"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      theme: theme,
                      controller: _nameController,
                      label: "Section Name",
                      validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      theme: theme,
                      controller: _limitController,
                      label: "Class Limit",
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Please set a limit' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildMentorDropdown(theme),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _updateSection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                height: 24, width: 24,
                                child: CircularProgressIndicator(strokeWidth: 3,))
                                : const Text("Update"),
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
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedMentorId,
          hint: _isFetchingMentors ? const Text('Loading...') : const Text('Select Mentor'),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          items: _mentors.map((mentor) {
            return DropdownMenuItem<String>(
              value: mentor['id'].toString(),
              child: Text(mentor['name']),
            );
          }).toList(),
          onChanged: _isFetchingMentors ? null : (v) => setState(() => _selectedMentorId = v),
          validator: (v) => v == null ? 'Please select a mentor' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String label,
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
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          validator: validator,
        ),
      ],
    );
  }
}