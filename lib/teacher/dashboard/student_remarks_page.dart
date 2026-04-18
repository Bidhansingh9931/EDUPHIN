import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'add_student_remark_page.dart';

class StudentRemark {
  final int id;
  final String type;
  final String description;
  final String remarkDate;
  final String dateRange;

  const StudentRemark({
    required this.id,
    required this.type,
    required this.description,
    required this.remarkDate,
    required this.dateRange,
  });

  factory StudentRemark.fromJson(Map<String, dynamic> json) {
    return StudentRemark(
      id: json['id'] ?? 0,
      type: json['remarks_type'] ?? 'N/A',
      description: json['remarks'] ?? 'No description',
      remarkDate: json['remarks_date'] ?? 'N/A',
      dateRange: "${json['from_date'] ?? 'N/A'} - ${json['to_date'] ?? 'N/A'}",
    );
  }
}

class StudentRemarksPage extends StatefulWidget {
  final int studentId;
  final String studentName;

  const StudentRemarksPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentRemarksPage> createState() => _StudentRemarksPageState();
}

class _StudentRemarksPageState extends State<StudentRemarksPage> {
  bool _isLoading = true;
  final List<StudentRemark> _remarks = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchRemarks();
  }

  Future<void> _fetchRemarks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('teacher/student/${widget.studentId}/remarks');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['remarks'] is List) {
          final fetchedRemarks = (data['remarks'] as List)
              .map((remarkJson) => StudentRemark.fromJson(remarkJson))
              .toList();

          if (mounted) {
            setState(() {
              _remarks.clear();
              _remarks.addAll(fetchedRemarks);
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Unknown API error');
        }
      } else {
        String errorMessage = 'Error ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (_) {}
        
        if (response.statusCode == 404) {
          throw Exception('Student or Remarks not found (404). $errorMessage');
        }
        throw Exception('Failed to load remarks: $errorMessage');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Remarks: ${widget.studentName}"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudentRemarkPage(studentId: widget.studentId, studentName: widget.studentName),
            ),
          );
          if (result == true) _fetchRemarks();
        },
        label: const Text("Add Remark"),
        icon: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center)))
              : _remarks.isEmpty
                  ? const Center(child: Text("No remarks found."))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _remarks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _RemarkTile(remark: _remarks[index], onDeleted: _fetchRemarks),
                    ),
    );
  }
}

class _RemarkTile extends StatelessWidget {
  final StudentRemark remark;
  final VoidCallback onDeleted;

  const _RemarkTile({required this.remark, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = remark.type.toLowerCase() == "positive";
    final typeColor = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(remark.type, style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(remark.description, style: theme.textTheme.bodyLarge),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Validity:", style: theme.textTheme.bodySmall),
                Text(remark.dateRange, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Remark?"),
        content: const Text("Are you sure you want to remove this remark?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.delete('teacher/student/remarks/${remark.id}');
        if (response.statusCode == 200) {
          onDeleted();
        } else {
          String errorMessage = "Failed to delete remark";
          try {
            final data = jsonDecode(response.body);
            errorMessage = data['message'] ?? errorMessage;
          } catch (_) {}
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
