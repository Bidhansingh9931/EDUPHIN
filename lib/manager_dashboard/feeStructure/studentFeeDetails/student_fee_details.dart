import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: "Class",
                          value: _selectedClassId,
                          items: _classList.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: "Section",
                          value: _selectedSectionId,
                          items: _sectionList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                          onChanged: (value) {
                             if (value == null || value == _selectedSectionId) return;
                            setState(() => _selectedSectionId = value);
                            _fetchStudents();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isFetchingStudents
                        ? const Center(child: CircularProgressIndicator())
                        : _studentFeeDetails.isEmpty
                            ? const Center(child: Text("No students found for this section."))
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 600) {
                                    return GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 500,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 2.5,
                                      ),
                                      itemCount: _studentFeeDetails.length,
                                      itemBuilder: (context, index) {
                                        final student = _studentFeeDetails[index];
                                        return CustomStudentInfoFeeDetailContainerBox(
                                          studentId: student.id,
                                          heading: student.name,
                                          subHeading: "Reg. No: ${student.regNo}, Class: ${student.className}-${student.sectionName}",
                                          isActive: student.status,
                                          imageUrl: student.imageUrl,
                                        );
                                      },
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: _studentFeeDetails.length,
                                      itemBuilder: (context, index) {
                                        final student = _studentFeeDetails[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: CustomStudentInfoFeeDetailContainerBox(
                                            studentId: student.id,
                                            heading: student.name,
                                            subHeading: "Reg. No: ${student.regNo}, Class: ${student.className}-${student.sectionName}",
                                            isActive: student.status,
                                            imageUrl: student.imageUrl,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                  ),
                ],
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
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
    final theme = Theme.of(context);
    final isActiveStatus = isActive.toLowerCase() == "active" || isActive.toLowerCase() == "live";

    ImageProvider<Object> backgroundImage = const AssetImage("assets/images/random_boy.jpg");
    if (imageUrl.startsWith('http')) {
      backgroundImage = NetworkImage(imageUrl);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image(image: backgroundImage, height: 50, width: 50, fit: BoxFit.cover)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                    Text(subHeading, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.6))),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: isActiveStatus ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      isActive,
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ))
            ],
          ),
          const SizedBox(height: 8),
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
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Fee Details",
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSecondary),
                )),
          ),
        ],
      ),
    );
  }
}
