import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eduphin/services/api_service.dart';
import 'add_new_remarks.dart';

// Data model for a Remark
class Remark {
  final int id;
  final String type;
  final String description;
  final String remarkDate;
  final String dateRange;

  const Remark({
    required this.id,
    required this.type,
    required this.description,
    required this.remarkDate,
    required this.dateRange,
  });

  factory Remark.fromJson(Map<String, dynamic> json) {
    return Remark(
      id: json['id'] ?? 0,
      type: json['remarks_type'] ?? 'N/A',
      description: json['remarks'] ?? 'No description',
      remarkDate: json['remarks_date'] ?? 'N/A',
      dateRange: "${json['from_date'] ?? 'N/A'} - ${json['to_date'] ?? 'N/A'}",
    );
  }
}

class RemarksPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  const RemarksPage({
    super.key,
    required this.studentId,
    this.studentName = "Student",
  });

  @override
  State<StatefulWidget> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  bool _isLoading = true;
  final List<Remark> _remarks = [];
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
      final roleId = await ApiService.getRoleId();
      // Use teacher endpoint if role is Teacher (5), otherwise fallback to manager endpoint
      final endpoint = roleId == 5 
          ? 'teacher/students/${widget.studentId}/remarks'
          : 'manager/students/${widget.studentId}/remarks';

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['remarks'] is List) {
          final fetchedRemarks = (data['remarks'] as List)
              .map((remarkJson) => Remark.fromJson(remarkJson))
              .toList();

          if (mounted) {
            setState(() {
              _remarks.clear();
              _remarks.addAll(fetchedRemarks);
            });
          }
        } else {
          throw Exception(
              'API response format is incorrect or status is false.');
        }
      } else {
        throw Exception('Failed to load remarks: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = "The connection timed out. Please try again.";
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddNewRemarksPage(studentId: widget.studentId),
            ),
          );
          if (result == true) {
            _fetchRemarks();
          }
        },
        label: const Text("Add New Remark"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                "Remarks for ${widget.studentName}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_sharp),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }
    if (_remarks.isEmpty) {
      return const Center(child: Text("No remarks found for this student."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: _remarks.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final remark = _remarks[index];
              return RemarkCard(remark: remark, onUpdate: _fetchRemarks);
            },
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: _remarks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final remark = _remarks[index];
              return RemarkCard(remark: remark, onUpdate: _fetchRemarks);
            },
          );
        }
      },
    );
  }
}

class RemarkCard extends StatelessWidget {
  final Remark remark;
  final VoidCallback onUpdate;

  const RemarkCard({super.key, required this.remark, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = remark.type == "Positive";
    final typeColor = isPositive ? theme.colorScheme.primary : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      remark.type,
                      style: theme.textTheme.labelLarge?.copyWith(
                          color: typeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        showDeleteRemarkDialog(context, remark, onUpdate),
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(remark.description, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Date of Remarks",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor)),
                  Text(remark.remarkDate, style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("From Date - To Date",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor)),
                  Text(remark.dateRange, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showDeleteRemarkDialog(
    BuildContext context, Remark remark, VoidCallback onUpdate) {
  showDialog(
    context: context,
    builder: (_) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: DeleteRemarkDialog(remark: remark, onUpdate: onUpdate),
    ),
  );
}

class DeleteRemarkDialog extends StatefulWidget {
  final Remark remark;
  final VoidCallback onUpdate;

  const DeleteRemarkDialog(
      {super.key, required this.remark, required this.onUpdate});

  @override
  State<DeleteRemarkDialog> createState() => _DeleteRemarkDialogState();
}

class _DeleteRemarkDialogState extends State<DeleteRemarkDialog> {
  bool _isDeleting = false;

  Future<void> _deleteRemark() async {
    if (!mounted) return;
    setState(() => _isDeleting = true);

    try {
      final roleId = await ApiService.getRoleId();
      final endpoint = roleId == 5 
          ? 'teacher/students/remarks/${widget.remark.id}'
          : 'manager/students/remarks/${widget.remark.id}';

      await ApiService.delete(endpoint);
      if (mounted) {
        final theme = Theme.of(context);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Remark deleted successfully!'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        widget.onUpdate();
      }
    } on Exception catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Remark'),
      content: const Text('Are you sure you want to delete this remark? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteRemark,
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError),
          child: _isDeleting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
