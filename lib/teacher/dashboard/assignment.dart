import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'common_widgets.dart';
import 'create_assignment.dart';
import 'app_drawer.dart';

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  late Future<AssignmentPageData> _dataFuture;
  AssignmentSchedule? _selectedSchedule;
  List<Assignment> _allAssignments = [];
  List<Assignment> _filteredAssignments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = ApiService.getAssignmentsPageData();
    _dataFuture.then((data) {
      if (mounted) {
        setState(() {
          _allAssignments = data.assignments;
          _filteredAssignments = data.assignments;
        });
      }
    });
  }

  Future<void> _viewFile(String? attachment) async {
    if (attachment == null || attachment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No attachment available")),
      );
      return;
    }
    
    final url = "${ApiService.baseUrl}/storage/$attachment";
    final uri = Uri.parse(url);

    if (kIsWeb) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open the file URL")),
          );
        }
      }
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading file...")),
    );
    
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName = attachment.split('/').last;
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        await OpenFile.open(file.path);
      } else {
        throw Exception("Failed to download file (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open file: $e"),
            backgroundColor: const Color(0xFFEF4444), // Red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<AssignmentPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pageData = snapshot.data!;
            return _buildContent(context, pageData);
          }
          return const Center(child: Text("No data"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAssignmentPage()));
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AssignmentPageData pageData) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.scale(1200)),
        child: Column(
          children: [
            buildFilterCard(
              context,
              children: [
                buildLabel(context, "Filter by Class/Subject"),
                buildDropdown(
                  context,
                  ['All Classes', ...pageData.schedules.map((s) => '${s.subjectName} - ${s.className} (${s.sectionName})')],
                  _selectedSchedule == null ? 'All Classes' : '${_selectedSchedule!.subjectName} - ${_selectedSchedule!.className} (${_selectedSchedule!.sectionName})',
                  (newValue) {
                    setState(() {
                      if (newValue == 'All Classes') {
                        _selectedSchedule = null;
                        _filteredAssignments = _allAssignments;
                      } else {
                        _selectedSchedule = pageData.schedules.firstWhere((s) => '${s.subjectName} - ${s.className} (${s.sectionName})' == newValue);
                        _filteredAssignments = _allAssignments.where((a) => a.classId == _selectedSchedule!.classId && a.sectionId == _selectedSchedule!.sectionId && a.subjectId == _selectedSchedule!.subjectId).toList();
                      }
                    });
                  },
                  hint: "Select Schedule",
                ),
              ],
            ),
            Expanded(
              child: _filteredAssignments.isEmpty
                  ? const Center(child: Text("No assignments found for this selection"))
                  : context.responsive(
                      ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left, vertical: context.spacing / 2),
                        itemCount: _filteredAssignments.length,
                        itemBuilder: (context, index) => _buildAssignmentCard(_filteredAssignments[index]),
                      ),
                      tablet: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left, vertical: context.spacing / 2),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: context.spacing,
                          mainAxisSpacing: context.spacing,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: _filteredAssignments.length,
                        itemBuilder: (context, index) => _buildAssignmentCard(_filteredAssignments[index]),
                      ),
                      desktop: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left, vertical: context.spacing / 2),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: context.spacing,
                          mainAxisSpacing: context.spacing,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: _filteredAssignments.length,
                        itemBuilder: (context, index) => _buildAssignmentCard(_filteredAssignments[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAssignmentCard(Assignment assignment) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: context.isMobile ? EdgeInsets.only(bottom: context.spacing) : EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: context.scale(8)),
                _buildStatusBadge(assignment.status),
              ],
            ),
            SizedBox(height: context.scale(12)),
            if (assignment.description != null)
              Text(
                assignment.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: context.font(13),
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Divider(height: context.scale(24), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 0.5),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.scale(6)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Icon(Icons.calendar_today_outlined, size: context.scale(14), color: theme.colorScheme.primary),
                ),
                SizedBox(width: context.scale(8)),
                Text(
                  "Due: ${assignment.dueDate}",
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(12), fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _viewFile(assignment.attachment),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.all(context.scale(8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                  ),
                  icon: Icon(Icons.file_present_outlined, size: context.scale(20)),
                  tooltip: "View Attachment",
                ),
                SizedBox(width: context.scale(8)),
                IconButton(
                  onPressed: () => _deleteAssignment(assignment.id),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.error,
                    padding: EdgeInsets.all(context.scale(8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, size: context.scale(20)),
                  tooltip: "Delete Assignment",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final theme = context.theme;
    bool isActive = status.toLowerCase() == 'active';
    final color = isActive ? const Color(0xFF10B981) : theme.colorScheme.outline; // Emerald for active
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: context.font(10),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _deleteAssignment(int id) async {
    final theme = context.theme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text("Delete Assignment", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this assignment?", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("CANCEL", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary, fontSize: context.font(13), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("DELETE", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: context.font(13))),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteAssignment(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment deleted successfully")));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
