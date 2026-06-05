import 'dart:async';
import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/remarks.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/view_attendence.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// Data model for a Student
class Student {
  final int id;
  final String name;
  final String regNo;
  final String? photo;

  const Student({required this.id, required this.name, required this.regNo, this.photo});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      name: "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim(),
      regNo: json['registration_no'] ?? 'N/A',
      photo: json['photo'],
    );
  }
}

class StudentListPage extends StatefulWidget {
  final int sectionId;
  final String sectionName;

  const StudentListPage({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  bool _isLoading = true;
  List<Student> _students = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cacheKey = 'section_students_${widget.sectionId}';
    final cachedData = await CacheService.getCache(cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _students = (cachedData as List).map((studentJson) => Student.fromJson(studentJson)).toList();
      });
    }
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _students.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/sections/${widget.sectionId}/students');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final fetchedStudents = (data['data'] as List).map((studentJson) => Student.fromJson(studentJson)).toList();

          final cacheKey = 'section_students_${widget.sectionId}';
          await CacheService.setCache(cacheKey, data['data']);

          if (mounted) {
            setState(() {
              _students = fetchedStudents;
              _isLoading = false;
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to load students');
        }
      } else {
        throw Exception('Failed to load students. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Students in ${widget.sectionName}"),
        actions: [
          IconButton(
            onPressed: _fetchStudents,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
          SizedBox(width: context.xs),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _students.isNotEmpty,
        error: _error,
        onRetry: _fetchStudents,
        skeleton: _buildSkeleton(),
        child: _students.isEmpty ? _buildEmptyState(theme) : _buildContent(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: 8,
      separatorBuilder: (context, index) => SizedBox(height: context.md),
      itemBuilder: (context, index) => SkeletonBox(
        height: context.scale(150),
        borderRadius: context.scale(10),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: context.scale(64), color: theme.colorScheme.outlineVariant),
          SizedBox(height: context.md),
          Text("No students found in this section.", style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchStudents,
      child: Padding(
        padding: context.pagePadding.copyWith(bottom: 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: context.md,
                  mainAxisSpacing: context.md,
                  childAspectRatio: 2.2,
                ),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  return StudentCard(student: _students[index]);
                },
              );
            } else {
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _students.length,
                separatorBuilder: (context, index) => SizedBox(height: context.md),
                itemBuilder: (context, index) {
                  return StudentCard(student: _students[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ProfileAvatar(
                imageUrl: ApiService.getStorageUrl(student.photo),
                radius: context.scale(24),
                borderWidth: 1,
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: context.font(18),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Reg No: ${student.regNo}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                        fontSize: context.font(14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.scale(12)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAttendancePage(studentId: student.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View Attendance"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RemarksPage(
                          studentId: student.id,
                          studentName: student.name,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add Remark"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
