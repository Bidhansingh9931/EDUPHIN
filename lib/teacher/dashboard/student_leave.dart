import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'student_leave_model.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart';

class StudentLeaveScreen extends StatefulWidget {
  const StudentLeaveScreen({super.key});

  @override
  State<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends State<StudentLeaveScreen> {
  List<StudentLeave> _allLeaves = [];
  List<StudentLeave> _filteredLeaves = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_filterLeaves);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await TeacherCacheService.load('student_leaves');
    if (cachedData != null && mounted) {
      final List<dynamic> list = cachedData;
      setState(() {
        _allLeaves = list.map((e) => StudentLeave.fromJson(e)).toList();
        _filteredLeaves = _allLeaves;
        _isLoading = false;
      });
      _filterLeaves();
    }
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    if (!mounted) return;
    if (_allLeaves.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final leaves = await ApiService.getStudentLeaveDetails();
      if (mounted) {
        setState(() {
          _allLeaves = leaves;
          _isLoading = false;
        });
        _filterLeaves();
        await TeacherCacheService.save('student_leaves', leaves.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _filterLeaves() {
    final query = _searchController.text.toLowerCase();
    final status = _selectedStatus;
    final date = _dateController.text;

    setState(() {
      _filteredLeaves = _allLeaves.where((leave) {
        final matchesQuery = leave.studentName.toLowerCase().contains(query) || leave.rollNo.toLowerCase().contains(query);
        final matchesStatus = status == null || leave.status.toLowerCase() == status.toLowerCase();
        final matchesDate = date.isEmpty || (leave.fromDate.contains(date) || leave.toDate.contains(date));

        return matchesQuery && matchesStatus && matchesDate;
      }).toList();
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchLeaves();
  }
  
  void _resetFilters() {
    _searchController.clear();
    _dateController.clear();
    setState(() {
      _selectedStatus = null;
    });
    _filterLeaves();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Leave Applications"),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterCard(),
                Expanded(
                  child: TeacherLoadingWrapper(
                    isLoading: _isLoading,
                    hasData: _allLeaves.isNotEmpty,
                    skeleton: _buildSkeleton(context),
                    child: _filteredLeaves.isEmpty && !_isLoading
                        ? Center(
                            child: Text(
                              "No leave applications found.",
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                            ),
                          )
                        : _buildLeaveList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.spacing),
        child: TeacherSkeleton(height: context.scale(60), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilterCard() {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: context.pagePadding,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildResponsiveRow(context, [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel(context, "Search"),
                  buildTextField(context, _searchController, "Student Roll no."),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel(context, "Applied Date"),
                  buildDateField(context, _dateController, "dd-mm-yyyy"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel(context, "Status"),
                  buildDropdown(
                    context,
                    ['pending', 'approved', 'rejected'],
                    _selectedStatus,
                    (val) {
                      setState(() => _selectedStatus = val);
                      _filterLeaves();
                    },
                    hint: "Select Status",
                  ),
                ],
              ),
            ]),
            SizedBox(height: context.spacing),
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: context.scale(120),
                  child: OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: Icon(Icons.refresh, size: context.scale(18)),
                    label: const Text("RESET"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(12)),
                SizedBox(
                  width: context.scale(120),
                  child: ElevatedButton.icon(
                    onPressed: _filterLeaves,
                    icon: Icon(Icons.search, size: context.scale(18)),
                    label: const Text("APPLY"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeaveList() {
    final theme = context.theme;
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
            dataRowMaxHeight: context.scale(60),
            columnSpacing: context.scale(24),
            columns: [
              DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("Student", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("Class", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
            ],
            rows: _filteredLeaves.map((leave) {
              final fromDate = leave.fromDate.isNotEmpty ? DateFormat('dd MMM').format(DateTime.parse(leave.fromDate)) : '';
              final toDate = leave.toDate.isNotEmpty ? DateFormat('dd MMM').format(DateTime.parse(leave.toDate)) : '';

              return DataRow(cells: [
                DataCell(Text(leave.id.toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(leave.studentName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13))),
                    Text(leave.rollNo, style: TextStyle(fontSize: context.font(11), color: theme.colorScheme.onSurfaceVariant)),
                  ],
                )),
                DataCell(Text('${leave.className} - ${leave.sectionName}', style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text('$fromDate - $toDate', style: TextStyle(fontSize: context.font(13)))),
                DataCell(Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, leave.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(4)),
                    border: Border.all(color: _getStatusColor(context, leave.status).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    leave.status.toUpperCase(),
                    style: TextStyle(fontSize: context.font(10), fontWeight: FontWeight.bold, color: _getStatusColor(context, leave.status)),
                  ),
                )),
                DataCell(IconButton(
                  icon: Icon(Icons.edit_note, size: context.scale(22), color: theme.colorScheme.primary),
                  onPressed: () => _showUpdateStatusDialog(leave),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = context.theme;
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'approved':
        return const Color(0xFF10B981); // Emerald
      case 'rejected':
        return const Color(0xFFEF4444); // Red
      default:
        return theme.colorScheme.outline;
    }
  }

  void _showUpdateStatusDialog(StudentLeave leave) {
    String currentStatus = ['pending', 'approved', 'rejected'].contains(leave.status.toLowerCase()) ? leave.status.toLowerCase() : 'pending';

    showDialog(
      context: context,
      builder: (context) {
        String tempStatus = currentStatus;
        final theme = context.theme;
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text('Update Status', style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(20))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel(context, "Select Status"),
                buildDropdown(
                  context,
                  ['pending', 'approved', 'rejected'],
                  tempStatus,
                  (val) => setDialogState(() => tempStatus = val ?? tempStatus),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: theme.colorScheme.secondary, fontSize: context.font(14))),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await ApiService.updateStudentLeaveStatus(leave.id, tempStatus);
                    if (!mounted) return;
                    _fetchLeaves();
                    Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status updated successfully'),
                          backgroundColor: Color(0xFF10B981), // Emerald
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ErrorHandler.showError(context, e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                ),
                child: Text('Update', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }
}
