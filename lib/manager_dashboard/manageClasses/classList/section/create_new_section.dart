import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class CreateNewSectionPage extends StatefulWidget {
  final int classId;
  const CreateNewSectionPage({super.key, required this.classId});

  @override
  State<CreateNewSectionPage> createState() => _CreateNewSectionPageState();
}

class _CreateNewSectionPageState extends State<CreateNewSectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  bool _isLoading = false;
  bool _isFetchingMentors = true;

  List<Map<String, dynamic>> _mentors = [];
  String? _selectedMentorId;
  String? _selectedSectionName;
  final List<String> _sectionNames = ['A', 'B', 'C', 'D'];


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
      final response = await ApiService.get('manager/class-schedules/meta');
      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
          final List<dynamic> teachersList = responseData['teachers'];
          final processedMentors = teachersList.map((teacher) {
            String fullName = teacher['name'] ?? '';
            if (fullName.isEmpty) {
                final firstName = teacher['first_name'] ?? '';
                final lastName = teacher['last_name'] ?? '';
                fullName = '$firstName $lastName'.trim();
            }
            
            return {
                'id': teacher['id'],
                'name': fullName.isNotEmpty ? fullName : 'Unnamed Mentor',
            };
          }).where((mentor) => mentor['id'] != null).toList();

          setState(() {
            _mentors = processedMentors;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to load mentors.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = context.theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An error occurred while fetching mentors: $e'), backgroundColor: theme.colorScheme.error),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('manager/sections', {
        'class_id': widget.classId,
        'section_name': _selectedSectionName,
        'section_limit': int.tryParse(_limitController.text) ?? 0,
        'mentor_id':
            _selectedMentorId != null ? int.parse(_selectedMentorId!) : null,
      });

      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 201 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Section created successfully!'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Failed to create section.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = context.theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: theme.colorScheme.error),
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
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New Section",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(100)),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.responsive(double.infinity, tablet: 600, desktop: 800)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.scale(16)),
              color: theme.colorScheme.surfaceContainerLow,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: EdgeInsets.all(context.scale(20)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionDropdown(theme),
                  SizedBox(height: context.scale(20)),
                  _buildMentorDropdown(theme),
                  SizedBox(height: context.scale(20)),
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
                  SizedBox(height: context.scale(32)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                            ),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: context.scale(16)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createSection,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: context.scale(24),
                                  width: context.scale(24),
                                  child: CircularProgressIndicator(strokeWidth: 3, color: theme.colorScheme.onPrimary),
                                )
                              : Text("Create Section", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildSectionDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Section Name", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14))),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<String>(
          value: _selectedSectionName,
          dropdownColor: theme.colorScheme.surface,
          hint: Text('Select a Section', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14))),
          isExpanded: true,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
          ),
          items: _sectionNames.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSectionName = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a section' : null,
        ),
      ],
    );
  }

  Widget _buildMentorDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mentor Teacher", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14))),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<String>(
          value: _selectedMentorId,
          dropdownColor: theme.colorScheme.surface,
          hint: Text(_isFetchingMentors ? 'Loading Mentors...' : 'Select a Mentor', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14))),
          isExpanded: true,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(10)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
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
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14))),
        SizedBox(height: context.scale(8)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            isDense: true,
            contentPadding: EdgeInsets.all(context.scale(14)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

