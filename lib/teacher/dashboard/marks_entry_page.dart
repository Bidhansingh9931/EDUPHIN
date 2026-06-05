import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/marks_entry_detail_page.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'common_widgets.dart';

class MarksEntryPage extends StatefulWidget {
  const MarksEntryPage({super.key});

  @override
  State<MarksEntryPage> createState() => _MarksEntryPageState();
}

class _MarksEntryPageState extends State<MarksEntryPage> {
  List<ExamPaper>? _papers;
  bool _isLoading = true;
  String? _error;
  final Map<String, String?> _filters = {'class': 'All Classes'};
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache
    final cachedData = await TeacherCacheService.load('exam_papers');
    if (cachedData != null && mounted) {
      setState(() {
        _papers = (cachedData as List).map((p) => ExamPaper.fromJson(p)).toList();
        _isLoading = false;
      });
    }

    // 2. Fetch from API
    try {
      final papers = await ApiService.getExamPapers();
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
          _error = null;
        });
        // 3. Save to cache
        await TeacherCacheService.save('exam_papers', papers.map((p) => p.toJson()).toList());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandler.getMessage(e);
          _isLoading = false;
        });
        if (_papers != null) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Marks"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: TeacherLoadingWrapper(
                  isLoading: _isLoading,
                  hasData: _papers != null,
                  skeleton: _buildSkeleton(),
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: _error != null && _papers == null
                        ? Center(child: Text(_error!))
                        : _buildStudentsTable(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        buildLabel(context, "Filter by Class"),
        buildDropdown(context, ['All Classes', 'Class 10A', 'Class 12B'], _filters['class'], (val) => setState(() => _filters['class'] = val)),
        SizedBox(height: context.scale(16)),
        SizedBox(
          width: double.infinity,
          child: buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey())),
        ),
      ]
    );
  }

  Widget _buildStudentsTable() {
    final theme = context.theme;
    final filteredPapers = _papers?.where((p) {
      if (_filters['class'] == 'All Classes') return true;
      return p.className == _filters['class'];
    }).toList() ?? [];

    return Card(
      elevation: 0,
      margin: EdgeInsets.all(context.spacing),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(16)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(20))),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: context.scale(20), color: theme.colorScheme.primary),
                SizedBox(width: context.scale(8)),
                Text("Exam Papers", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: buildResponsiveRow(context, [
              Padding(
                padding: EdgeInsets.only(bottom: context.spacing),
                child: Row(
                  children: [
                    Text("Show entries", style: theme.textTheme.labelMedium?.copyWith(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
                    SizedBox(width: context.scale(4)),
                    Icon(Icons.keyboard_arrow_down, size: context.scale(16), color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
              buildTextField(context, TextEditingController(), "Search Papers...", prefixIcon: Icons.search),
            ]),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 0.5),
          Expanded(
            child: filteredPapers.isEmpty 
              ? Center(child: Text("No exam papers found", style: TextStyle(fontSize: context.font(14))))
              : ListView.separated(
                  itemCount: filteredPapers.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), thickness: 0.5),
                  itemBuilder: (context, index) {
                    final paper = filteredPapers[index];
                    return _buildPaperRow(index + 1, paper);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Card(
      margin: EdgeInsets.all(context.spacing),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(20))),
      child: ListView.builder(
        itemCount: 5,
        padding: EdgeInsets.all(context.spacing),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(vertical: context.scale(12)),
          child: Row(
            children: [
              TeacherSkeleton(width: context.scale(30), height: context.scale(20)),
              SizedBox(width: context.spacing),
              Expanded(child: TeacherSkeleton(height: context.scale(20))),
              SizedBox(width: context.spacing),
              TeacherSkeleton(width: context.scale(60), height: context.scale(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(12)),
      child: Row(
        children: [
          SizedBox(width: context.scale(40), child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text("SUBJECT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text("CLASS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }

  Widget _buildPaperRow(int index, ExamPaper paper) {
    final theme = context.theme;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarksEntryDetailPage(paper: paper),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(16)),
        child: Row(
          children: [
            SizedBox(width: context.scale(40), child: Text("$index", style: TextStyle(fontSize: context.font(13)))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(paper.subjectName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface)),
                  Text(paper.examName, style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Expanded(child: Text("${paper.className} - ${paper.sectionName}", style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
        ),
      ),
    );
  }
}
