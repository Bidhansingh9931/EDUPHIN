import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'common_widgets.dart';
import 'create_assignment.dart';

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
    
    // Use ApiService.baseUrl which handles 10.0.2.2 for Android
    final url = "${ApiService.baseUrl}/storage/$attachment";
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading file...")),
    );
    
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse(url),
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
          SnackBar(content: Text("Could not open file: $e"), backgroundColor: Colors.red),
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
    return Column(
      children: [
        buildFilterCard(
          context,
          children: [
            _buildLabel("Filter by Class/Subject"),
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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredAssignments.length,
                itemBuilder: (context, index) => _buildAssignmentCard(_filteredAssignments[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(assignment.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                _buildStatusBadge(assignment.status),
              ],
            ),
            const SizedBox(height: 8),
            if (assignment.description != null) 
              Text(assignment.description!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Due: ${assignment.dueDate}", style: theme.textTheme.labelSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _viewFile(assignment.attachment),
                  icon: const Icon(Icons.file_present, size: 16), 
                  label: const Text("View File", style: TextStyle(fontSize: 12))
                ),
                IconButton(
                  onPressed: () => _deleteAssignment(assignment.id), 
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }

  void _deleteAssignment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Assignment"),
        content: const Text("Are you sure you want to delete this assignment?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      )
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
