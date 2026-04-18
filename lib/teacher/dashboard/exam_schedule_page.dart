import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';

class ExamSchedulePage extends StatefulWidget {
  final int? examId;

  const ExamSchedulePage({super.key, this.examId});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  late Future<ExamScheduleData>? _scheduleFuture;

  @override
  void initState() {
    super.initState();
    if (widget.examId != null) {
      _scheduleFuture = ApiService.getExamSchedule(widget.examId!);
    } else {
      _scheduleFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            const Text("Examination Paper Schedule"),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: widget.examId == null 
            ? _buildPlaceholderContent()
            : FutureBuilder<ExamScheduleData>(
            future: _scheduleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontSize: context.font(14))));
              } else if (!snapshot.hasData) {
                return Center(child: Text("No data found", style: TextStyle(fontSize: context.font(14))));
              }
    
              return ListView(
                padding: context.pagePadding,
                children: [
                  _buildExamScheduleCard("Class: Financial Accounting Basics - Section: A"),
                  SizedBox(height: context.spacing),
                  _buildExamScheduleCard("Class: Cost Analysis and Management - Section: A"),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return ListView(
      padding: context.pagePadding,
      children: [
        _buildExamScheduleCard("Class: Financial Accounting Basics - Section: A"),
        SizedBox(height: context.spacing),
        _buildExamScheduleCard("Class: Cost Analysis and Management - Section: A"),
      ],
    );
  }

  Widget _buildExamScheduleCard(String classTitle) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              children: [
                Icon(Icons.layers_outlined, color: theme.colorScheme.primary, size: context.scale(32)),
                SizedBox(height: context.scale(12)),
                Text(classTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                SizedBox(height: context.scale(12)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text("Total Papers: 1", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _buildScheduleTable(),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: DataTable(
          columnSpacing: context.scale(24),
          headingRowHeight: context.scale(40),
          dataRowMaxHeight: context.scale(48),
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columns: [
            DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text("Principles of Accounting", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
              DataCell(Text("04 Oct 2025", style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text("09:00 AM - 12:00 PM", style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text("Room 101", style: TextStyle(fontSize: context.font(13)))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _headerItem(String label, {int flex = 1}) {
    return Container(
      width: context.scale(flex == 2 ? 150 : 100),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: context.theme.colorScheme.onSurfaceVariant))
    );
  }

  Widget _dataItem(String value, {int flex = 1, bool isBold = false}) {
    return Container(
      width: context.scale(flex == 2 ? 150 : 100),
      child: Text(value, style: TextStyle(fontSize: context.font(11), fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: context.theme.colorScheme.onSurface))
    );
  }
}
