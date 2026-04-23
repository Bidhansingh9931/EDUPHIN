import 'dart:async';
import 'dart:convert';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Data Model for a Student
class Student {
  final String name;
  final String grade;
  final String section;
  final String id;
  final String? imageUrl;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    this.imageUrl,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? 'N/A',
      name: json['name'] ?? 'No Name',
      grade: json['grade'] ?? 'No Grade',
      section: json['section'] ?? 'No Section',
      imageUrl: ApiService.getStorageUrl(json['photo']),
    );
  }
}

// 2. Data Provider to fetch student data
class StudentProvider {
  static const String _cacheKeyPrefix = 'students_list_';

  Future<List<Student>> fetchStudents(String instituteId, {bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await getCachedStudents(instituteId);
        if (cached != null) return cached;
      }
      final response = await ApiService.get('moderator/institutes/$instituteId/students');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['success'] == true || data['status'] == true) && data['students'] != null) {
          await CacheHelper.save(_cacheKeyPrefix + instituteId, data);
          final List<dynamic> studentsJson = data['students'];
          return studentsJson.map((json) => Student.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load students.');
        }
      } else {
        throw Exception('Failed to load students. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<List<Student>?> getCachedStudents(String instituteId) async {
    final cached = await CacheHelper.load(_cacheKeyPrefix + instituteId);
    if (cached != null && cached['students'] != null) {
      final List<dynamic> studentsJson = cached['students'];
      return studentsJson.map((json) => Student.fromJson(json)).toList();
    }
    return null;
  }
}

// 3. Updated StatefulWidget to be dynamic
class StudentsPage extends StatefulWidget {
  final String instituteId;
  const StudentsPage({super.key, required this.instituteId});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StudentProvider _provider = StudentProvider();
  late Future<List<Student>> _studentsFuture;
  List<Student>? _cachedStudents;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedStudents = await _provider.getCachedStudents(widget.instituteId);
    _fetchStudents();
  }

  void _fetchStudents({bool bypassCache = false}) {
    if (mounted) {
      setState(() {
        _studentsFuture = _provider.fetchStudents(widget.instituteId, bypassCache: bypassCache);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Students',
          style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<Student>>(
            snapshot: snapshot,
            cachedData: _cachedStudents,
            skeleton: const ListSkeleton(),
            onRefresh: _fetchStudents,
            builder: (students) {
              if (snapshot.hasError && (_cachedStudents == null || _cachedStudents!.isEmpty)) {
                return _buildComingSoon(context);
              }

              if (students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      SizedBox(height: context.md),
                      Text('No students found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _fetchStudents(bypassCache: true),
                color: theme.colorScheme.primary,
                child: GridView.builder(
                  padding: context.pagePadding,
                  itemCount: students.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                    crossAxisSpacing: context.md,
                    mainAxisSpacing: context.md,
                    mainAxisExtent: context.responsive(100, tablet: 110, desktop: 110),
                  ),
                  itemBuilder: (context, index) {
                    return StudentCard(student: students[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(24)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_rounded, size: context.scale(64), color: theme.colorScheme.primary),
            ),
            SizedBox(height: context.lg),
            Text(
              "Coming Soon!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: context.font(28),
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              "We're working hard to bring student records to your dashboard. Stay tuned!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.font(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        leading: ProfileAvatar(
          imageUrl: student.imageUrl,
          radius: context.scale(20),
        ),
        title: Text(
          student.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(15), color: theme.colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${student.grade} - ${student.section}',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: context.scale(24), color: theme.colorScheme.onSurfaceVariant),
        onTap: () {
          // Navigation logic
        },
      ),
    );
  }
}
