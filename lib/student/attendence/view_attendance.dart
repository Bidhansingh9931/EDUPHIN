import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:intl/intl.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _attendanceData;
  final Map<int, bool> _subjectOpenStates = {};
  static const String _cacheKey = 'student_attendance';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchAttendance();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _attendanceData = cachedData as Map<String, dynamic>;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAttendance() async {
    if (_attendanceData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getStudentAttendance();
      if (mounted) {
        setState(() {
          _attendanceData = data;
          _isLoading = false;
        });
        await CacheService.saveData(_cacheKey, data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Report"),
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _attendanceData != null,
        skeleton: const _AttendanceSkeleton(),
        onRefresh: _fetchAttendance,
        child: _attendanceData == null
            ? Center(child: Text("No data found", style: TextStyle(color: colorScheme.onSurfaceVariant)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudentHeader(),
                        SizedBox(height: context.lg),
                        _buildStatsGrid(),
                        SizedBox(height: context.xl),
                        Row(
                          children: [
                            Icon(Icons.list_alt, color: colorScheme.primary, size: 22),
                            SizedBox(width: context.sm),
                            Text(
                              "Subject-wise Records",
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: context.xs),
                        Text(
                          "Detailed attendance log, grouped by subject.",
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        SizedBox(height: context.lg),
                        _buildSubjectWiseList(),
                        SizedBox(height: context.xl),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final student = _attendanceData!['student'];
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: colorScheme.primary, size: 28),
            ),
            SizedBox(width: context.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['user']?['name'] ?? "Student",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: context.xs),
                  Text(
                    "Roll No: ${student['roll_no'] ?? 'N/A'} • Class: ${student['class_id'] ?? 'N/A'}",
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final percentage = _attendanceData!['attendance_percentage'];
    final presentCount = _attendanceData!['present_count'];
    final totalCount = _attendanceData!['total_count'];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _statsCard("Total Days", totalCount.toString(), Icons.calendar_month, const Color(0xFF3B82F6))),
                SizedBox(width: isWide ? context.md : context.sm),
                Expanded(child: _statsCard("Present", presentCount.toString(), Icons.check_circle_outline, const Color(0xFF10B981))),
              ],
            );
          },
        ),
        SizedBox(height: context.md),
        _statsCard(
          "Overall Percentage",
          "$percentage%",
          Icons.analytics_outlined,
          colorScheme.primary,
          isWide: true,
          progress: (double.tryParse(percentage.toString()) ?? 0) / 100,
        ),
      ],
    );
  }

  Widget _statsCard(String label, String value, IconData icon, Color color, {bool isWide = false, double? progress}) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color.withValues(alpha: 0.8), size: 18),
                SizedBox(width: context.sm),
                Text(label, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: context.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
            ),
            if (progress != null) ...[
              SizedBox(height: context.md),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectWiseList() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final subjectWiseData = _attendanceData!['subject_wise_attendance'];
    if (subjectWiseData == null) return const SizedBox();
    
    final Map<String, dynamic> subjectWise = Map<String, dynamic>.from(subjectWiseData);
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjectWise.length,
      itemBuilder: (context, index) {
        final entry = subjectWise.entries.elementAt(index);
        final subjectId = int.tryParse(entry.key) ?? 0;
        final List<dynamic> records = entry.value;
        final subjectName = records.isNotEmpty ? (records.first['subject']?['name'] ?? 'Subject $subjectId') : 'Subject $subjectId';

        final int sPresent = records.where((r) => r['status'].toString().toLowerCase() == 'present').length;
        final int sTotal = records.length;
        final double sPercent = sTotal > 0 ? (sPresent / sTotal) * 100 : 0;
        final bool isOpen = _subjectOpenStates[subjectId] ?? false;

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: context.md),
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isOpen ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _subjectOpenStates[subjectId] = !isOpen),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.all(context.md),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "${sPercent.toInt()}%",
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subjectName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(height: context.xs),
                            Text("$sPresent / $sTotal sessions attended", style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              if (isOpen) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.md),
                  child: Divider(color: colorScheme.outlineVariant, height: 1),
                ),
                if (records.isEmpty)
                   Padding(
                     padding: EdgeInsets.all(context.lg),
                     child: Text("No records available", style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                   )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    padding: EdgeInsets.all(context.md),
                    separatorBuilder: (context, i) => Padding(
                      padding: EdgeInsets.symmetric(vertical: context.sm),
                      child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
                    ),
                    itemBuilder: (context, rIndex) {
                      final r = records[rIndex];
                      return _buildAttendanceRecordRow(r, rIndex + 1);
                    },
                  ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceRecordRow(dynamic r, int index) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final status = (r['status'] ?? "N/A").toString().toLowerCase();
    Color statusColor = colorScheme.error;
    if (status == 'present') statusColor = const Color(0xFF10B981);
    if (status == 'leave') statusColor = const Color(0xFFF59E0B);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(index.toString(), style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(width: context.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(r['date']), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: context.xs),
              Text(r['time_slot'] ?? "N/A", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              if (r['remarks'] != null && r['remarks'].toString().isNotEmpty && r['remarks'] != "-")
                 Padding(
                   padding: EdgeInsets.only(top: context.xs),
                   child: Text(r['remarks'], style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
                 ),
            ],
          ),
        ),
        _statusBadge(status.toUpperCase(), statusColor),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Skeleton
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.md),
                  child: Row(
                    children: [
                      SkeletonBox(width: 44, height: 44, borderRadius: BorderRadius.circular(22)),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: context.scale(150), height: context.scale(20)),
                            SizedBox(height: context.xs),
                            SkeletonBox(width: context.scale(200), height: context.scale(14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.lg),
              // Stats Grid Skeleton
              Row(
                children: [
                  Expanded(child: _skeletonStatsCard(context)),
                  SizedBox(width: context.md),
                  Expanded(child: _skeletonStatsCard(context)),
                ],
              ),
              SizedBox(height: context.md),
              _skeletonStatsCard(context, isWide: true),
              SizedBox(height: context.xl),
              // List Skeleton
              SkeletonBox(width: context.scale(180), height: context.scale(24)),
              SizedBox(height: context.md),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) => Card(
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: context.md),
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.md),
                    child: Row(
                      children: [
                        SkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(12)),
                        SizedBox(width: context.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: context.scale(120), height: context.scale(16)),
                              SizedBox(height: context.xs),
                              SkeletonBox(width: context.scale(180), height: context.scale(12)),
                            ],
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: colorScheme.outlineVariant),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeletonStatsCard(BuildContext context, {bool isWide = false}) {
    final colorScheme = context.theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(width: 18, height: 18, borderRadius: BorderRadius.circular(4)),
                SizedBox(width: context.sm),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
            SizedBox(height: context.sm),
            SkeletonBox(width: 60, height: 28),
            if (isWide) ...[
              SizedBox(height: context.md),
              SkeletonBox(width: double.infinity, height: 8, borderRadius: BorderRadius.circular(4)),
            ]
          ],
        ),
      ),
    );
  }
}
