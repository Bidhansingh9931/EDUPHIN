import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
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
    // Handle both flat (direct) and nested (json['student']) structures
    final bool isNested = json.containsKey('student') && json['student'] is Map;
    final Map<String, dynamic> student = isNested ? json['student'] : json;
    final Map<String, dynamic> classInfo = (json['class'] is Map) ? json['class'] : {};
    final Map<String, dynamic> sectionInfo = (json['section'] is Map) ? json['section'] : {};

    // Handle name construction
    String name = student['name']?.toString() ?? '';
    if (name.isEmpty) {
      final fName = student['first_name']?.toString() ?? '';
      final mName = student['middle_name']?.toString() ?? '';
      final lName = student['last_name']?.toString() ?? '';
      name = [fName, mName, lName].where((s) => s.isNotEmpty).join(' ').trim();
    }
    if (name.isEmpty) name = 'N/A';

    String rawImageUrl = student['profile_image']?.toString() ?? '';
    return StudentFeeInfo(
      id: student['id'] ?? json['student_id'] ?? 0,
      name: name,
      regNo: student['registration_no']?.toString() ?? student['student_roll_no']?.toString() ?? 'N/A',
      className: classInfo['name']?.toString() ?? 'N/A',
      sectionName: sectionInfo['section_name']?.toString() ?? 'N/A',
      status: student['student_status']?.toString() ?? student['status']?.toString() ?? 'Inactive',
      imageUrl: rawImageUrl.isNotEmpty ? ApiService.getStorageUrl(rawImageUrl) : '',
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
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    // 1. Load cached classes
    final cachedClassData = await CacheService.getCache('manager_classes_fee');
    if (cachedClassData != null && mounted) {
      final List<dynamic> classData = cachedClassData as List? ?? [];
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

      // 2. Load cached students for the first class/section
      if (_selectedClassId != null && _selectedSectionId != null) {
        final cachedStudents = await CacheService.getCache('students_fee_${_selectedClassId}_$_selectedSectionId');
        if (cachedStudents != null && mounted) {
          setState(() {
            _studentFeeDetails = (cachedStudents as List)
                .map((json) => StudentFeeInfo.fromJson(json))
                .toList();
          });
        }
      }
    }
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _classList.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> classData = data['data'] as List? ?? [];
        await CacheService.setCache('manager_classes_fee', classData);

        final List<ClassInfo> fetchedClasses = classData
            .whereType<Map<String, dynamic>>()
            .map((json) => ClassInfo.fromJson(json))
            .toList();

        setState(() {
          _classList = fetchedClasses;
          if (_classList.isNotEmpty) {
            // Keep current selection if valid, otherwise reset
            final currentClass = _classList.any((c) => c.id == _selectedClassId) 
                ? _classList.firstWhere((c) => c.id == _selectedClassId)
                : _classList.first;
            
            _selectedClassId = currentClass.id;
            _sectionList = currentClass.sections;
            
            if (_sectionList.isNotEmpty) {
              _selectedSectionId = _sectionList.any((s) => s.id == _selectedSectionId)
                  ? _selectedSectionId
                  : _sectionList.first.id;
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
        setState(() => _error = e);
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClassId == null || _selectedSectionId == null) return;

    if (mounted) setState(() => _isFetchingStudents = true);

    try {
      final response = await ApiService.get('manager/fees/students?class_id=$_selectedClassId&section_id=$_selectedSectionId');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentData = (data['data'] ?? data['students']) as List? ?? [];
        
        await CacheService.setCache('students_fee_${_selectedClassId}_$_selectedSectionId', studentData);

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
        ErrorHandler.showError(context, e);
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _classList.isNotEmpty,
        error: _error,
        onRetry: _fetchInitialData,
        skeleton: _buildSkeleton(),
        child: Center(
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
                    child: _isFetchingStudents && _studentFeeDetails.isEmpty
                        ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                        : _studentFeeDetails.isEmpty
                            ? Center(child: Text("No students found for this section.", style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)))
                            : RefreshIndicator(
                                onRefresh: _fetchStudents,
                                child: context.responsive(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(height: context.scale(60))),
              SizedBox(width: context.spacing),
              Expanded(child: SkeletonBox(height: context.scale(60))),
            ],
          ),
          SizedBox(height: context.spacing),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: context.spacing),
                child: SkeletonBox(height: context.scale(150), borderRadius: context.scale(12)),
              ),
            ),
          ),
        ],
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
