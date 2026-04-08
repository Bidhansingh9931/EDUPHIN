import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/student_leave_model.dart';
import 'package:intl/intl.dart';

class MyLeaveApplication extends StatefulWidget {
  const MyLeaveApplication({Key? key}) : super(key: key);

  @override
  State<MyLeaveApplication> createState() => _MyLeaveApplicationState();
}

class _MyLeaveApplicationState extends State<MyLeaveApplication> {
  String? _selectedLeaveType;
  String? _selectedStatus;
  List<StudentLeave> _allLeaves = [];
  List<StudentLeave> _filteredLeaves = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLeaveApplications();
  }

  Future<void> _fetchLeaveApplications() async {
    setState(() => _isLoading = true);
    try {
      final leaves = await ApiService.getStudentLeaveList();
      setState(() {
        _allLeaves = leaves;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLeaves = _allLeaves.where((leave) {
        final matchesType = _selectedLeaveType == null ||
            leave.leaveType.toLowerCase() == _selectedLeaveType!.toLowerCase();
        final matchesStatus = _selectedStatus == null ||
            leave.status.toLowerCase() == _selectedStatus!.toLowerCase();
        final matchesSearch = _searchController.text.isEmpty ||
            leave.reason.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            leave.leaveType.toLowerCase().contains(_searchController.text.toLowerCase());
        return matchesType && matchesStatus && matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedLeaveType = null;
      _selectedStatus = null;
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xff2e3556);
    Color card = const Color(0xff394066);
    Color button = const Color(0xff4b7bec);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchLeaveApplications,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TOP BAR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My Leave Applications",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: button,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: () => _showApplyLeaveSheet(context),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Apply For Leave", style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// FILTER CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Filter Applications",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Filter by Leave Type",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                dropdownColor: card,
                                value: _selectedLeaveType,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xff4a5178),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                style: const TextStyle(color: Colors.white),
                                hint: const Text("Select an option",
                                    style: TextStyle(color: Colors.white70)),
                                items: ["Sick", "Casual", "Emergency", "Other"]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  _selectedLeaveType = v;
                                  _applyFilters();
                                },
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "Filter by Status",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                dropdownColor: card,
                                value: _selectedStatus,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xff4a5178),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                style: const TextStyle(color: Colors.white),
                                hint: const Text("Select an option",
                                    style: TextStyle(color: Colors.white70)),
                                items: ["Pending", "Approved", "Rejected"]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  _selectedStatus = v;
                                  _applyFilters();
                                },
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey),
                                  onPressed: _resetFilters,
                                  child: const Text("RESET", style: TextStyle(color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// APPLICATION HISTORY
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Application History",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "View the status of your past and current leave requests.",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 15),

                              /// SEARCH
                              TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "search records",
                                  hintStyle: const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: const Color(0xff4a5178),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search, color: Colors.white),
                                    onPressed: _applyFilters,
                                  ),
                                ),
                                onChanged: (_) => _applyFilters(),
                              ),

                              const SizedBox(height: 15),

                              /// TABLE
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                      const Color(0xff4a5178)),
                                  columns: const [
                                    DataColumn(label: Text("#", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("Leave Type", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("From", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("To", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("Reason", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("Status", style: TextStyle(color: Colors.white))),
                                    DataColumn(label: Text("Applied At", style: TextStyle(color: Colors.white))),
                                  ],
                                  rows: _filteredLeaves.asMap().entries.map((entry) {
                                    final index = entry.key + 1;
                                    final leave = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text("$index", style: const TextStyle(color: Colors.white))),
                                      DataCell(Text(leave.leaveType, style: const TextStyle(color: Colors.white))),
                                      DataCell(Text(_formatDate(leave.fromDate), style: const TextStyle(color: Colors.white))),
                                      DataCell(Text(_formatDate(leave.toDate), style: const TextStyle(color: Colors.white))),
                                      DataCell(Text(leave.reason, style: const TextStyle(color: Colors.white))),
                                      DataCell(_buildStatusBadge(leave.status)),
                                      DataCell(Text(_formatDateTime(leave.appliedAt), style: const TextStyle(color: Colors.white))),
                                    ]);
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff2e3556),
      builder: (context) => _ApplyLeaveBottomSheet(onSuccess: _fetchLeaveApplications),
    );
  }
}

class _ApplyLeaveBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _ApplyLeaveBottomSheet({required this.onSuccess});

  @override
  State<_ApplyLeaveBottomSheet> createState() => _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends State<_ApplyLeaveBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _leaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _fromDate == null || _toDate == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ApiService.applyStudentLeave(
        leaveType: _leaveType!,
        fromDate: DateFormat('yyyy-MM-dd').format(_fromDate!),
        toDate: DateFormat('yyyy-MM-dd').format(_toDate!),
        reason: _reasonController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leave applied successfully")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apply For Leave",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xff394066),
              decoration: const InputDecoration(
                labelText: "Leave Type",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              style: const TextStyle(color: Colors.white),
              items: ["Sick", "Casual", "Emergency", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => _leaveType = v,
              validator: (v) => v == null ? "Required" : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("From Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    subtitle: Text(_fromDate == null ? "Select" : DateFormat('dd MMM yyyy').format(_fromDate!),
                        style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _fromDate = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text("To Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    subtitle: Text(_toDate == null ? "Select" : DateFormat('dd MMM yyyy').format(_toDate!),
                        style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: _fromDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _toDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _reasonController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Reason",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4b7bec)),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
