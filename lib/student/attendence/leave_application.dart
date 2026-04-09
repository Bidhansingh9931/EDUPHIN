import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/student_leave_model.dart';
import 'package:intl/intl.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({super.key});

  @override
  State<LeaveApplicationPage> createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

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
          SnackBar(content: Text("Error fetching leaves: $e")),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLeaves = _allLeaves.where((leave) {
        final matchesType = _selectedLeaveType == null || leave.leaveType.toLowerCase() == _selectedLeaveType!.toLowerCase();
        final matchesStatus = _selectedStatus == null || leave.status.toLowerCase() == _selectedStatus!.toLowerCase();
        final matchesSearch = _searchController.text.isEmpty || leave.reason.toLowerCase().contains(_searchController.text.toLowerCase()) || leave.leaveType.toLowerCase().contains(_searchController.text.toLowerCase());
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Leave Applications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchLeaveApplications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              onRefresh: _fetchLeaveApplications,
              color: _primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => _showApplyLeaveSheet(context),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text("APPLY FOR NEW LEAVE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    /// FILTER CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_list, color: Colors.white70, size: 20),
                              SizedBox(width: 8),
                              Text("Filter Leaves", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Leave Type", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    _buildDropdownField(
                                      value: _selectedLeaveType,
                                      items: ["Sick", "Casual", "Emergency", "Other"],
                                      onChanged: (v) {
                                        setState(() => _selectedLeaveType = v);
                                        _applyFilters();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Status", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    _buildDropdownField(
                                      value: _selectedStatus,
                                      items: ["Pending", "Approved", "Rejected"],
                                      onChanged: (v) {
                                        setState(() => _selectedStatus = v);
                                        _applyFilters();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.white12)),
                              ),
                              onPressed: _resetFilters,
                              child: const Text("RESET FILTERS", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// HISTORY HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Leave History", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${_filteredLeaves.length} applications", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_filteredLeaves.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                        child: const Column(
                          children: [
                            Icon(Icons.history, color: Colors.white10, size: 48),
                            SizedBox(height: 16),
                            Text("No leave records found", style: TextStyle(color: Colors.white38, fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredLeaves.length,
                        itemBuilder: (context, index) {
                          final leave = _filteredLeaves[index];
                          return _buildLeaveCard(leave);
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLeaveCard(StudentLeave leave) {
    Color statusColor = Colors.orangeAccent;
    if (leave.status.toLowerCase() == 'approved') statusColor = Colors.greenAccent;
    if (leave.status.toLowerCase() == 'rejected') statusColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(leave.leaveType.toUpperCase(), style: TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              _statusBadge(leave.status.toUpperCase(), statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _dateBlock("FROM", leave.fromDate),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, color: Colors.white12, size: 16),
              ),
              _dateBlock("TO", leave.toDate),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, height: 1),
          ),
          const Text("Reason:", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 4),
          Text(leave.reason, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _dateBlock(String label, String dateStr) {
    DateTime dt = DateTime.tryParse(dateStr) ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(DateFormat('dd MMM').format(dt), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(DateFormat('yyyy').format(dt), style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDropdownField({String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: _card,
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 20),
          hint: const Text("All", style: TextStyle(color: Colors.white38, fontSize: 13)),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApplyLeaveBottomSheet(onSuccess: _fetchLeaveApplications, theme: {'bg': _bg, 'card': _card, 'primary': _primary, 'secondary': _secondary}),
    );
  }
}

class _ApplyLeaveBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, Color> theme;
  const _ApplyLeaveBottomSheet({required this.onSuccess, required this.theme});

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
          const SnackBar(content: Text("Leave application submitted successfully")),
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
    final t = widget.theme;
    return Container(
      decoration: BoxDecoration(
        color: t['card'],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text("Apply for Leave", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Fill in the details below to request time off.", style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 32),
              
              const Text("Leave Type *", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: t['card'],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: t['secondary'],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: const TextStyle(color: Colors.white),
                items: ["Sick", "Casual", "Emergency", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => _leaveType = v,
                validator: (v) => v == null ? "Please select a leave type" : null,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(child: _datePickerField("From Date *", _fromDate, (d) => setState(() => _fromDate = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _datePickerField("To Date *", _toDate, (d) => setState(() => _toDate = d))),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text("Reason *", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Why do you need leave?",
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  filled: true,
                  fillColor: t['secondary'],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v!.isEmpty ? "Please provide a reason" : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t['primary'],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("SUBMIT REQUEST", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerField(String label, DateTime? date, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: widget.theme['secondary'], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: widget.theme['primary']!.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 10),
                Text(
                  date == null ? "Select Date" : DateFormat('dd MMM, yyyy').format(date),
                  style: TextStyle(color: date == null ? Colors.white24 : Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
