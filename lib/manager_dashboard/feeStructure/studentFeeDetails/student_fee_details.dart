import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';

import 'fee_details.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class ClassInfo {
  final int id;
  final String name;
  final List<SectionInfo> sections;

  ClassInfo({required this.id, required this.name, required this.sections});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List? ?? [];
    final sections = sectionsList
        .whereType<Map<String, dynamic>>()
        .map((i) => SectionInfo.fromJson(i))
        .toList();

    return ClassInfo(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Class',
      sections: sections,
    );
  }
}

class SectionInfo {
  final int id;
  final String name;
  SectionInfo({required this.id, required this.name});

  factory SectionInfo.fromJson(Map<String, dynamic> json) {
    return SectionInfo(
      id: json['id'] ?? 0,
      name: json['section_name']?.toString() ?? 'N/A',
    );
  }
}

class StudentFeeInfo {
  final int id;
  final String name;
  final String regNo;
  final String className;
  final String sectionName;
  final String status;
  final String imageUrl;

  StudentFeeInfo({
    required this.id,
    required this.name,
    required this.regNo,
    required this.className,
    required this.sectionName,
    required this.status,
    required this.imageUrl,
  });

  factory StudentFeeInfo.fromJson(Map<String, dynamic> json) {
    final studentData = json['student'] is Map<String, dynamic> ? json['student'] : {};
    final classData = json['class'] is Map<String, dynamic> ? json['class'] : {};
    final sectionData = json['section'] is Map<String, dynamic> ? json['section'] : {};

    String rawImageUrl = studentData['profile_image']?.toString() ?? '';
    return StudentFeeInfo(
      id: json['student_id'] ?? 0,
      name: studentData['name']?.toString() ?? 'N/A',
      regNo: studentData['registration_no']?.toString() ?? 'N/A',
      className: classData['name']?.toString() ?? 'N/A',
      sectionName: sectionData['section_name']?.toString() ?? 'N/A',
      status: studentData['status']?.toString() ?? 'Inactive',
      imageUrl: rawImageUrl.isNotEmpty ? '${ApiService.baseImageUrl}/storage/$rawImageUrl' : 'assets/images/random_boy.jpg',
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         PAGE WIDGET
// ───────────────────────────────────────────────────────────

class StudentFeeDetailsPage extends StatefulWidget {
  const StudentFeeDetailsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudentFeeDetailsPageState();
}

class _StudentFeeDetailsPageState extends State<StudentFeeDetailsPage> {
  bool _isLoading = true;
  bool _isFetchingStudents = false;

  List<ClassInfo> _classList = [];
  List<SectionInfo> _sectionList = [];
  List<StudentFeeInfo> _studentFeeDetails = [];

  int? _selectedClassId;
  int? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> classData = data['data'] as List? ?? [];
        final List<ClassInfo> fetchedClasses = classData
            .whereType<Map<String, dynamic>>()
            .map((json) => ClassInfo.fromJson(json))
            .toList();

        setState(() {
          _classList = fetchedClasses;
          if (_classList.isNotEmpty) {
            _selectedClassId = _classList.first.id;
            _sectionList = _classList.first.sections;
            if (_sectionList.isNotEmpty) {
              _selectedSectionId = _sectionList.first.id;
            }
          }
        });
        
        if (_selectedClassId != null && _selectedSectionId != null) {
          await _fetchStudents();
        }

      } else {
        throw Exception('Failed to load class data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;

    setState(() => _isFetchingStudents = true);

    try {
      final response = await ApiService.get('manager/fees/students?class_id=$_selectedClassId&section_id=$_selectedSectionId');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentData = data['students'] as List? ?? [];
        setState(() {
          _studentFeeDetails = studentData
              .whereType<Map<String, dynamic>>()
              .map((json) => StudentFeeInfo.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load student data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingStudents = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Student Fee Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: context.pagePadding,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: "Class",
                              value: _selectedClassId,
                              items: _classList.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: TextStyle(fontSize: context.font(14))))).toList(),
                              onChanged: (value) {
                                if (value == null || value == _selectedClassId) return;
                                setState(() {
                                  _selectedClassId = value;
                                  _sectionList = _classList.firstWhere((c) => c.id == value).sections;
                                  _selectedSectionId = _sectionList.isNotEmpty ? _sectionList.first.id : null;
                                });
                                _fetchStudents();
                              },
                            ),
                          ),
                          SizedBox(width: context.spacing),
                          Expanded(
                            child: _buildDropdown(
                              label: "Section",
                              value: _selectedSectionId,
                              items: _sectionList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: TextStyle(fontSize: context.font(14))))).toList(),
                              onChanged: (value) {
                                 if (value == null || value == _selectedSectionId) return;
                                setState(() => _selectedSectionId = value);
                                _fetchStudents();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.spacing),
                      Expanded(
                        child: _isFetchingStudents
                            ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                            : _studentFeeDetails.isEmpty
                                ? Center(child: Text("No students found for this section.", style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)))
                                : context.responsive(
                                    ListView.builder(
                                      itemCount: _studentFeeDetails.length,
                                      itemBuilder: (context, index) {
                                        final student = _studentFeeDetails[index];
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: context.spacing),
                                          child: CustomStudentInfoFeeDetailContainerBox(
                                            studentId: student.id,
                                            heading: student.name,
                                            subHeading: "Reg. No: ${student.regNo}, Class: ${student.className}-${student.sectionName}",
                                            isActive: student.status,
                                            imageUrl: student.imageUrl,
                                          ),
                                        );
                                      },
                                    ),
                                    tablet: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: context.spacing,
                                        crossAxisSpacing: context.spacing,
                                        mainAxisExtent: context.scale(180),
                                      ),
                                      itemCount: _studentFeeDetails.length,
                                      itemBuilder: (context, index) {
                                        final student = _studentFeeDetails[index];
                                        return CustomStudentInfoFeeDetailContainerBox(
                                          studentId: student.id,
                                          heading: student.name,
                                          subHeading: "Reg. No: ${student.regNo}\nClass: ${student.className}-${student.sectionName}",
                                          isActive: student.status,
                                          imageUrl: student.imageUrl,
                                        );
                                      },
                                    ),
                                    desktop: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: context.spacing,
                                        crossAxisSpacing: context.spacing,
                                        mainAxisExtent: context.scale(180),
                                      ),
                                      itemCount: _studentFeeDetails.length,
                                      itemBuilder: (context, index) {
                                        final student = _studentFeeDetails[index];
                                        return CustomStudentInfoFeeDetailContainerBox(
                                          studentId: student.id,
                                          heading: student.name,
                                          subHeading: "Reg. No: ${student.regNo}\nClass: ${student.className}-${student.sectionName}",
                                          isActive: student.status,
                                          imageUrl: student.imageUrl,
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );

  }

  Widget _buildDropdown<T>({ 
    required String label,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          dropdownColor: theme.colorScheme.surface,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.scale(16)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
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
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomStudentInfoFeeDetailContainerBox extends StatelessWidget {
  final int studentId;
  final String heading;
  final String subHeading;
  final String isActive;
  final String imageUrl;

  const CustomStudentInfoFeeDetailContainerBox({
    super.key,
    required this.studentId,
    required this.heading,
    required this.subHeading,
    required this.isActive,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isActiveStatus = isActive.toLowerCase() == "active" || isActive.toLowerCase() == "live";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(12)),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ProfileAvatar(
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                radius: context.scale(25),
                borderWidth: 0,
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        fontSize: context.font(18),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subHeading,
                      style: TextStyle(
                        fontSize: context.font(12),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: isActiveStatus ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                    child: Text(
                      isActive,
                      style: TextStyle(
                        fontSize: context.font(10),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
            ],
          ),
          SizedBox(height: context.scale(12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FeeDetailsPage(studentId: studentId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: context.scale(10)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(20)),
                  ),
                ),
                child: Text(
                  "Fee Details",
                  style: TextStyle(
                    fontSize: context.font(14),
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
