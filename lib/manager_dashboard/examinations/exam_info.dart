import 'dart:convert';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:intl/intl.dart';

import 'package:eduphin/manager_dashboard/examinations/create_new_exam.dart';
import 'package:eduphin/manager_dashboard/examinations/edit_exam.dart';
import 'package:eduphin/manager_dashboard/examinations/manage_schedule.dart';
import 'package:flutter/material.dart';

// Data model from API
class Exam {
  final int id;
  final String name;
  final String? type;
  final String examCode;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final String? description;

  Exam({
    required this.id,
    required this.name,
    this.type,
    required this.examCode,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? 'Unnamed Exam',
      type: json['type'] as String?,
      examCode: json['code'] as String? ?? 'N/A',
      isActive: json['status'] == 'active',
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      description: json['description'] as String?,
    );
  }
}

class ExamInfoPage extends StatefulWidget {
  const ExamInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamInfoPageState();
}

class _ExamInfoPageState extends State<ExamInfoPage> {
  bool _isLoading = true;
  List<Exam> _exams = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CacheService.getCache('manager_exams');
    if (cachedData != null && mounted) {
      final List<dynamic> examJson = cachedData;
      setState(() {
        _exams = examJson.map((json) => Exam.fromJson(json)).toList();
        _isLoading = _exams.isEmpty;
      });
    }
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _exams.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/exams');
      final body = json.decode(response.body);
      if (body['status'] == true) {
        final List<dynamic> examJson = body['data'];
        await CacheService.setCache('manager_exams', examJson);
        if (mounted) {
          setState(() {
            _exams = examJson.map((json) => Exam.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load exams: ${body['message']}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  void _refreshExams() {
    _fetchExams();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Exam Inventory", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Manage examination schedules and results", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LoadingWrapper(
            isLoading: _isLoading,
            hasData: _exams.isNotEmpty,
            error: _error,
            onRetry: _refreshExams,
            skeleton: _buildSkeleton(),
            child: RefreshIndicator(
              onRefresh: () async => _refreshExams(),
              child: _exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          SizedBox(height: context.scale(16)),
                          Text('No exams found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                        ],
                      ),
                    )
                  : context.responsive(
                      _buildListView(_exams),
                      tablet: _buildGridView(_exams, crossAxisCount: 2),
                      desktop: _buildGridView(_exams, crossAxisCount: 3),
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateExamScreen()));
          if (result == true) {
            _refreshExams();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        label: Text("CREATE NEW EXAM", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSkeleton() {
    return context.responsive(
      ListView.separated(
        padding: context.pagePadding,
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
        itemBuilder: (context, index) => SkeletonBox(height: context.scale(220), borderRadius: context.scale(16)),
      ),
      tablet: GridView.builder(
        padding: context.pagePadding,
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: context.scale(16),
          crossAxisSpacing: context.scale(16),
          mainAxisExtent: context.scale(220),
        ),
        itemBuilder: (context, index) => SkeletonBox(height: context.scale(220), borderRadius: context.scale(16)),
      ),
      desktop: GridView.builder(
        padding: context.pagePadding,
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: context.scale(16),
          crossAxisSpacing: context.scale(16),
          mainAxisExtent: context.scale(220),
        ),
        itemBuilder: (context, index) => SkeletonBox(height: context.scale(220), borderRadius: context.scale(16)),
      ),
    );
  }

  Widget _buildListView(List<Exam> exams) {
    return ListView.separated(
      padding: context.pagePadding.copyWith(bottom: context.scale(80)),
      itemCount: exams.length,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildGridView(List<Exam> exams, {required int crossAxisCount}) {
    return GridView.builder(
      padding: context.pagePadding.copyWith(bottom: context.scale(80)),
      itemCount: exams.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.scale(16),
        crossAxisSpacing: context.scale(16),
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final exam = exams[index];
        return _buildExamCard(exam);
      },
    );
  }

  Widget _buildExamCard(Exam exam) {
    String formattedStartDate = 'N/A';
    if (exam.startDate != null && exam.startDate!.isNotEmpty) {
      try {
        formattedStartDate = DateFormat('dd MMM yyyy').format(DateTime.parse(exam.startDate!));
      } catch (e) {
        formattedStartDate = 'Invalid Date';
      }
    }

    String formattedEndDate = 'N/A';
    if (exam.endDate != null && exam.endDate!.isNotEmpty) {
      try {
        formattedEndDate = DateFormat('dd MMM yyyy').format(DateTime.parse(exam.endDate!));
      } catch (e) {
        formattedEndDate = 'Invalid Date';
      }
    }

    final startEndDate = '$formattedStartDate - $formattedEndDate';

    return CustomExamListContainerBox(
      heading: '#${exam.id}',
      subHeading: exam.name,
      type: exam.type ?? 'N/A',
      examCode: exam.examCode,
      isActive: exam.isActive ? 'Active' : 'Inactive',
      startEndDate: startEndDate,
      onEdit: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditExamPage(
              examId: exam.id,
              examName: exam.name,
              examType: exam.type ?? 'N/A',
              examCode: exam.examCode,
              isActive: exam.isActive,
              startEndDate: startEndDate,
              description: exam.description,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshExams();
          }
        });
      },
      onManageSchedule: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageSchedulePage(
              examId: exam.id,
              examName: exam.name,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshExams();
          }
        });
      },
    );
  }
}

class CustomExamListContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String type;
  final String examCode;
  final String isActive;
  final String startEndDate;
  final VoidCallback onEdit;
  final VoidCallback onManageSchedule;

  const CustomExamListContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.type,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
    required this.onEdit,
    required this.onManageSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isActiveStatus = isActive == "Active";
    final statusColor = isActiveStatus ? theme.colorScheme.primary : theme.colorScheme.error;

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
            children: [
              Text(heading,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.scale(8)),
                  color: statusColor.withValues(alpha: 0.1),
                ),
                child: Text(
                  isActive,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: context.font(12)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.scale(8)),
          Text(subHeading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18))),
          SizedBox(height: context.scale(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(context, "Type", type),
              _buildInfoColumn(context, "Exam Code", examCode, crossAxisAlignment: CrossAxisAlignment.center),
              _buildInfoColumn(context, "Dates", startEndDate, crossAxisAlignment: CrossAxisAlignment.end),
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
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
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
                child: ElevatedButton(
                  onPressed: onManageSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                    padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                  ),
                  child: Text("Manage Schedule", textAlign: TextAlign.center, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
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
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10), fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          SizedBox(height: context.scale(2)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(13), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

