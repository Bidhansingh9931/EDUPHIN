import 'dart:convert';
import 'dart:ui';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/create_new_subject.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/edit_suject.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// Data model for a Subject
class Subject {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final String credit;
  final String type;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    required this.credit,
    required this.type,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? '',
      isActive: json['status'] == 'active',
      code: json['code'] as String? ?? 'N/A',
      credit: (json['credit'] ?? '0').toString(),
      type: json['type'] as String? ?? 'N/A',
    );
  }
}

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({super.key});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  bool _isLoading = true;
  List<Subject> _subjects = [];
  Object? _error;
  static const String _cacheKey = 'manager_subjects_list';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchSubjects();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _subjects = (cachedData as List)
            .map((subjectJson) => Subject.fromJson(subjectJson))
            .toList();
      });
    }
  }

  Future<void> _fetchSubjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/subjects');
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final subjectsData = (data['data'] as List)
              .map((subjectJson) => Subject.fromJson(subjectJson))
              .toList();
          
          await CacheService.setCache(_cacheKey, data['data']);

          setState(() {
            _subjects = subjectsData;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load subjects');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _deleteSubject(int subjectId) async {
    try {
      final response = await ApiService.delete('manager/subjects/$subjectId');
      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject deleted successfully')),
          );
          _fetchSubjects(); // Refresh the list
        } else {
          final responseData = jsonDecode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to delete subject');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNewSubjectPage()),
          );
          if (result == true) {
            _fetchSubjects();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        label: Text("CREATE NEW SUBJECT", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subject Inventory", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Manage academic subjects and credits", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _subjects.isNotEmpty,
        error: _error,
        onRetry: _fetchSubjects,
        skeleton: _buildSkeleton(),
        child: RefreshIndicator(
          onRefresh: _fetchSubjects,
          color: theme.colorScheme.primary,
          child: _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subject_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      SizedBox(height: context.scale(16)),
                      Text('No subjects found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: context.responsive(
                      _buildListView(),
                      tablet: _buildGridView(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(context.scale(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.scale(16)),
          border: Border.all(color: context.theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(height: context.scale(22), width: context.scale(150)),
                SkeletonBox(height: context.scale(24), width: context.scale(60)),
              ],
            ),
            SizedBox(height: context.scale(12)),
            SkeletonBox(height: context.scale(14), width: double.infinity),
            SizedBox(height: context.scale(8)),
            SkeletonBox(height: context.scale(14), width: context.scale(200)),
            SizedBox(height: context.scale(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: context.scale(10), width: context.scale(60)),
                  SizedBox(height: context.scale(4)),
                  SkeletonBox(height: context.scale(14), width: context.scale(40)),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: context.pagePadding.copyWith(bottom: context.scale(80)), // Padding for FAB
      itemCount: _subjects.length,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return SubjectCard(subject: subject, onDelete: () => _deleteSubject(subject.id), onEdit: () => _navigateToEdit(subject));
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: context.pagePadding.copyWith(bottom: context.scale(80)), // Padding for FAB
      itemCount: _subjects.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: context.scale(500),
        mainAxisSpacing: context.scale(16),
        crossAxisSpacing: context.scale(16),
        childAspectRatio: context.responsive(1.5, tablet: 1.8, desktop: 2.0),
      ),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return SubjectCard(subject: subject, onDelete: () => _deleteSubject(subject.id), onEdit: () => _navigateToEdit(subject));
      },
    );
  }
  
  void _navigateToEdit(Subject subject) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateSubjectPage(subject: subject),
        ),
      );
      if (result == true) {
        _fetchSubjects();
      }
  }
}

// Widget for displaying a single subject card
class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SubjectCard({super.key, required this.subject, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statusColor = subject.isActive ? theme.colorScheme.primary : theme.colorScheme.error;
    final statusText = subject.isActive ? "Active" : "Inactive";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(16)),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.scale(8)),
                  color: statusColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: context.font(12)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.scale(8)),
          Text(
            subject.description,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.scale(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(context, "Subject Code", subject.code),
              _buildInfoColumn(context, "Credit", subject.credit, crossAxisAlignment: CrossAxisAlignment.center),
              _buildInfoColumn(context, "Type", subject.type, crossAxisAlignment: CrossAxisAlignment.end),
            ],
          ),
          SizedBox(height: context.scale(16)),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          SizedBox(height: context.scale(16)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                    padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                  ),
                  icon: Icon(Icons.edit_outlined, size: context.scale(16)),
                  label: Text("Edit", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showDeleteDialog(context, subject.name, onDelete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                    padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                  ),
                  icon: Icon(Icons.delete_outline, size: context.scale(16)),
                  label: Text("Delete", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, {CrossAxisAlignment? crossAxisAlignment}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10), fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        SizedBox(height: context.scale(2)),
        Text(
          value,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(13), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

void showDeleteDialog(BuildContext context, String subjectName, VoidCallback onConfirm) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSubjectDialog(
        subjectName: subjectName,
        onConfirm: onConfirm,
      );
    },
  );
}

class DeleteSubjectDialog extends StatelessWidget {
  final String subjectName;
  final VoidCallback onConfirm;

  const DeleteSubjectDialog({
    super.key,
    required this.subjectName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: context.scale(24)),
            padding: EdgeInsets.all(context.scale(20)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(context.scale(20)),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete Subject",
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(20)),
                ),
                SizedBox(height: context.scale(12)),
                Text(
                  "Are you sure you want to delete the subject: '$subjectName'? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                ),
                SizedBox(height: context.scale(24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Text("Yes, Delete", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: context.scale(12)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

