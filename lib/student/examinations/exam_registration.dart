import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';

class ExamRegistrationPage extends StatefulWidget {
  const ExamRegistrationPage({super.key});

  @override
  State<ExamRegistrationPage> createState() => _ExamRegistrationPageState();
}

class _ExamRegistrationPageState extends State<ExamRegistrationPage> {
  List<dynamic> _exams = [];
  List<dynamic> _registeredExamIds = [];
  bool _isLoading = true;
  final Map<int, bool> _expandedExams = {};

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentExams();

      setState(() {
        // Map availableExams from your JSON and filter out expired ones
        final List<dynamic> allExams = data['availableExams'] ?? [];
        final DateTime now = DateTime.now();
        
        _exams = allExams.where((exam) {
          if (exam['end_date'] == null) return true;
          try {
            final DateTime endDate = DateTime.parse(exam['end_date']);
            // Add a day to end_date to include the full day
            return endDate.add(const Duration(days: 1)).isAfter(now);
          } catch (_) {
            return true;
          }
        }).toList();

        // Map registered IDs from your JSON [1, 2]
        final rawIds = data['registeredExamIds'] as List?;
        _registeredExamIds = rawIds?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [];

        _isLoading = false;

        if (_exams.isNotEmpty && _expandedExams.isEmpty) {
          _expandedExams[_exams[0]['id']] = true;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: context.theme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _registerExam(dynamic exam) async {
    try {
      // Sending plain ID as string to backend
      final String examId = exam['id'].toString();

      await ApiService.registerForExam(examId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Successfully registered for exam!"),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _fetchExams();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceFirst("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.theme.colorScheme.error,
          ),
        );
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
          "EXAM REGISTRATION",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: 1.2,
            fontSize: context.font(18),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _fetchExams,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _exams.isEmpty ? _buildEmptyState() : _buildExamGrid(),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = context.theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: context.screenHeight * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
              SizedBox(height: context.md),
              Text(
                "No exams available",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: context.font(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamGrid() {
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
        mainAxisExtent: context.responsive(null, tablet: context.scale(380), desktop: context.scale(400)),
      ),
      itemCount: _exams.length,
      itemBuilder: (context, index) {
        final exam = _exams[index];
        final bool isRegistered = _registeredExamIds.contains(exam['id']);
        final bool isOpen = _expandedExams[exam['id']] ?? false;
        return _buildExamCard(exam, isRegistered, isOpen);
      },
    );
  }

  Widget _buildExamCard(dynamic exam, bool registered, bool open) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final List<dynamic> papers = exam['papers'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(
          color: open ? colorScheme.primary : colorScheme.outlineVariant,
          width: open ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: context.scale(10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.xs),
            onTap: () => setState(() => _expandedExams[exam['id']] = !open),
            title: Text(
              exam['name'] ?? 'Exam Name',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
            subtitle: Text(
              exam['type'] ?? "Written",
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
            ),
            trailing: Icon(
              open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: open ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: context.scale(24),
            ),
          ),
          if (open)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (papers.isNotEmpty) ...[
                      Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      SizedBox(height: context.sm),
                      ...papers.map((p) => Padding(
                            padding: EdgeInsets.symmetric(vertical: context.xs),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    p['subject']?['name'] ?? 'Subject',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: context.font(14),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: context.xs, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(context.scale(4)),
                                  ),
                                  child: Text(
                                    p['date'] ?? '',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: context.font(11),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                    SizedBox(height: context.lg),
                    SizedBox(
                      width: double.infinity,
                      height: context.scale(48),
                      child: ElevatedButton(
                        onPressed: registered ? null : () => _registerExam(exam),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
                          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                        ),
                        child: Text(
                          registered ? "ALREADY REGISTERED" : "REGISTER NOW",
                          style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
