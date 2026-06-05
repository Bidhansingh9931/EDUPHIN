import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:intl/intl.dart';

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  List<dynamic> _examResults = [];
  bool _isLoading = true;
  final Map<int, bool> _expandedExams = {};
  static const String _cacheKey = 'student_exam_results';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchResults();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _examResults = cachedData as List? ?? [];
        _isLoading = false;
        if (_expandedExams.isEmpty && _examResults.isNotEmpty) {
          _expandedExams[_examResults[0]['id']] = true;
        }
      });
    }
  }

  Future<void> _fetchResults() async {
    if (_examResults.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getExamResults();
      if (mounted) {
        setState(() {
          _examResults = data;
          _isLoading = false;
          
          // Expand first result by default if available and none expanded
          if (_examResults.isNotEmpty && _expandedExams.isEmpty) {
            _expandedExams[_examResults[0]['id']] = true;
          }
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

  Future<void> _viewReportCard(dynamic registration) async {
    final String id = registration['id'].toString();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opening Report Card...")),
      );
      final reportData = await ApiService.getReportCard(id);
      
      if (reportData != null) {
        await PdfService.generateResultReportPdf(reportData);
      } else {
        throw "Invalid data received from server";
      }
      
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Examination Results",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _examResults.isNotEmpty,
        skeleton: const _ExamResultSkeleton(),
        onRefresh: _fetchResults,
        child: _examResults.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grade_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
                    SizedBox(height: context.scale(16)),
                    Text("No exam results found", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: context.pagePadding,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      if (isWide) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: context.scale(20),
                            mainAxisSpacing: context.scale(20),
                            mainAxisExtent: context.scale(550),
                          ),
                          itemCount: _examResults.length,
                          itemBuilder: (context, index) => _buildItem(index),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _examResults.length,
                        separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
                        itemBuilder: (context, index) => _buildItem(index),
                      );
                    }),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final registration = _examResults[index];
    final exam = registration['exam'];
    final bool isOpen = _expandedExams[registration['id']] ?? false;

    return _buildResultCard(registration, exam, isOpen, () {
      setState(() {
        _expandedExams[registration['id']] = !isOpen;
      });
    });
  }

  Widget _buildResultCard(dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
    if (exam == null) return const SizedBox.shrink();
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final startDateStr = exam['start_date'];
    final endDateStr = exam['end_date'];
    String formattedRange = "N/A";
    if (startDateStr != null && endDateStr != null) {
      try {
        DateTime start = DateTime.parse(startDateStr);
        DateTime end = DateTime.parse(endDateStr);
        formattedRange = "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
      } catch (_) {}
    }

    final results = registration['results'] as List? ?? [];
    
    double totalObtained = 0;
    for (var res in results) {
      totalObtained += double.tryParse(res['marks'].toString()) ?? 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: open ? colorScheme.primary : colorScheme.outlineVariant),
        boxShadow: [
          if (open) BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.05), blurRadius: context.scale(20), offset: Offset(0, context.scale(8))),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.scale(20)),
            child: Padding(
              padding: EdgeInsets.all(context.scale(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['name'] ?? 'Exam Name',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: context.font(16),
                          ),
                        ),
                        SizedBox(height: context.scale(8)),
                        Row(
                          children: [
                            Text(
                              "Status: ",
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              registration['status']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(16)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(6)),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(context.scale(8)),
                        ),
                        child: Text(
                          formattedRange,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: context.font(10),
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(8)),
                      Icon(
                        open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: context.scale(22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// DETAILS
          if (open)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(context.scale(20), 0, context.scale(20), context.scale(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: colorScheme.outlineVariant, height: 1),
                    SizedBox(height: context.scale(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Result Summary",
                          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w800, fontSize: context.font(14)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(context.scale(8)),
                          ),
                          child: Text(
                            "Total: ${totalObtained.toStringAsFixed(0)}",
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800, fontSize: context.font(12)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.scale(16)),

                    /// TABLE
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(context.scale(16)),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          /// TABLE HEADER
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                            color: colorScheme.surfaceContainerHighest,
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text("Subject", style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(12), fontWeight: FontWeight.w800))),
                                Expanded(flex: 1, child: Text("Marks", textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(12), fontWeight: FontWeight.w800))),
                                Expanded(flex: 1, child: Text("Grade", textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(12), fontWeight: FontWeight.w800))),
                                Expanded(flex: 1, child: Text("Result", textAlign: TextAlign.right, style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(12), fontWeight: FontWeight.w800))),
                              ],
                            ),
                          ),

                          /// TABLE ROWS
                          ...results.map((res) {
                            final subject = res['subject']?['name'] ?? 'N/A';
                            final marks = res['marks']?.toString() ?? 'N/A';
                            final grade = res['grade'] ?? '-';
                            final isPass = res['status']?.toString().toLowerCase() == 'pass';

                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(14)),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(subject, style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(11), fontWeight: FontWeight.w600))),
                                  Expanded(flex: 1, child: Text(marks, textAlign: TextAlign.center, style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.w800, color: colorScheme.primary))),
                                  Expanded(flex: 1, child: Text(grade, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11), fontWeight: FontWeight.w500))),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      isPass ? "Pass" : "Fail",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(color: isPass ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: context.font(10), fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: context.scale(24)),

                    /// REPORT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: context.scale(50),
                      child: ElevatedButton.icon(
                        onPressed: () => _viewReportCard(registration),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        icon: Icon(Icons.description_outlined, size: context.scale(20)),
                        label: Text("VIEW REPORT CARD", style: TextStyle(fontWeight: FontWeight.w800, fontSize: context.font(13), letterSpacing: 1.1)),
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

}

class _ExamResultSkeleton extends StatelessWidget {
  const _ExamResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: context.scale(20),
                  mainAxisSpacing: context.scale(20),
                  mainAxisExtent: context.scale(550),
                ),
                itemCount: 4,
                itemBuilder: (context, index) => _buildSkeletonCard(context, index == 0),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
              itemBuilder: (context, index) => _buildSkeletonCard(context, index == 0),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context, bool expanded) {
    final colorScheme = context.theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: context.scale(150), height: context.scale(18), borderRadius: context.scale(4)),
                      SizedBox(height: context.scale(8)),
                      SkeletonBox(width: context.scale(100), height: context.scale(14), borderRadius: context.scale(4)),
                    ],
                  ),
                ),
                SkeletonBox(width: context.scale(80), height: context.scale(24), borderRadius: context.scale(4)),
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(context.scale(20), 0, context.scale(20), context.scale(20)),
              child: Column(
                children: [
                  Divider(color: colorScheme.outlineVariant, height: 1),
                  SizedBox(height: context.scale(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: context.scale(120), height: context.scale(16), borderRadius: context.scale(4)),
                      SkeletonBox(width: context.scale(80), height: context.scale(24), borderRadius: context.scale(4)),
                    ],
                  ),
                  SizedBox(height: context.scale(16)),
                  Container(
                    height: context.scale(200),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                  ),
                  SizedBox(height: context.scale(24)),
                  SkeletonBox(width: double.infinity, height: context.scale(50), borderRadius: context.scale(12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
