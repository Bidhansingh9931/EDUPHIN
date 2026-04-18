import 'dart:async';
import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/remarks.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/view_attendence.dart';
import 'package:eduphin/services/api_service.dart';
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
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/sections/${widget.sectionId}/students');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final fetchedStudents = (data['data'] as List)
              .map((studentJson) => Student.fromJson(studentJson))
              .toList();

          if (mounted) {
            setState(() {
              _students = fetchedStudents;
            });
          }
        } else {
          throw Exception('API response format is incorrect or status is false.');
        }
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = "The connection timed out. Please try again.";
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text("Students in ${widget.sectionName}"),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }
    if (_students.isEmpty) {
      return const Center(child: Text("No students found in this section."));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return StudentCard(student: student);
              },
            );
          } else {
            return ListView.separated(
              itemCount: _students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final student = _students[index];
                return StudentCard(student: student);
              },
            );
          }
        },
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
