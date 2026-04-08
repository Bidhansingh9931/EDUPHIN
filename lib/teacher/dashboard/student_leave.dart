import 'package:eduphin/services/responsive_helper.dart';
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
  late Future<List<StudentLeave>> _leaveFuture;
  List<StudentLeave> _allLeaves = [];
  List<StudentLeave> _filteredLeaves = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
    _searchController.addListener(_filterLeaves);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _fetchLeaves() {
    _leaveFuture = ApiService.getStudentLeaveDetails();
    _leaveFuture.then((leaves) {
      if (mounted) {
        setState(() {
          _allLeaves = leaves;
          _filteredLeaves = leaves;
        });
      }
    });
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
    _fetchLeaves();
    await _leaveFuture;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Leave Applications"),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            _buildFilterCard(),
            Expanded(
              child: FutureBuilder<List<StudentLeave>>(
                future: _leaveFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allLeaves.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (_filteredLeaves.isEmpty) {
                    return const Center(child: Text("No leave applications found."));
                  }
                  return _buildLeaveList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel(context, "Search"),
            buildTextField(context, _searchController, "Student Roll no."),
            const SizedBox(height: 12),
            buildLabel(context, "Applied Date"),
            buildDateField(context, _dateController, "dd-mm-yyyy"),
            const SizedBox(height: 12),
            buildLabel(context, "Status"),
            buildDropdown(
              context, 
              ['pending', 'approved', 'rejected'], 
              _selectedStatus, 
              (val) {
                setState(() => _selectedStatus = val);
                _filterLeaves();
              },
              hint: "Select Status"
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _filterLeaves,
                    icon: const Icon(Icons.search),
                    label: const Text("APPLY"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                     onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text("RESET"),
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
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Student")),
              DataColumn(label: Text("Class")),
              DataColumn(label: Text("Duration")),
              DataColumn(label: Text("Status")),
              DataColumn(label: Text("Action")),
            ],
            rows: _filteredLeaves.map((leave) {
              final fromDate = leave.fromDate.isNotEmpty ? DateFormat('dd MMM').format(DateTime.parse(leave.fromDate)) : '';
              final toDate = leave.toDate.isNotEmpty ? DateFormat('dd MMM').format(DateTime.parse(leave.toDate)) : '';
              
              return DataRow(cells: [
                DataCell(Text(leave.id.toString())),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(leave.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(leave.rollNo, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                )),
                DataCell(Text('${leave.className} - ${leave.sectionName}')),
                DataCell(Text('$fromDate - $toDate')),
                DataCell(Chip(
                  label: Text(leave.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: _getStatusColor(leave.status),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () => _showUpdateStatusDialog(leave),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showUpdateStatusDialog(StudentLeave leave) {
    String currentStatus = ['pending', 'approved', 'rejected'].contains(leave.status.toLowerCase()) 
        ? leave.status.toLowerCase() 
        : 'pending';
        
    showDialog(
      context: context,
      builder: (context) {
        String tempStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: DropdownButtonFormField<String>(
                value: tempStatus,
                items: ['pending', 'approved', 'rejected'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status.toUpperCase()));
                }).toList(),
                onChanged: (val) => setDialogState(() => tempStatus = val ?? tempStatus),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService.updateStudentLeaveStatus(leave.id, tempStatus);
                      if (!mounted) return;
                      _fetchLeaves();
                      Navigator.pop(context);
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
