import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/student_leave_model.dart';
import 'package:intl/intl.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({super.key});

  @override
  State<LeaveApplicationPage> createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
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
          SnackBar(
            content: Text("Error fetching leaves: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLeaves = _allLeaves.where((leave) {
        final matchesType = _selectedLeaveType == null || leave.leaveType.toLowerCase() == _selectedLeaveType!.toLowerCase();
        final matchesStatus = _selectedStatus == null || leave.status.toLowerCase() == _selectedStatus!.toLowerCase();
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Leave Applications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaveApplications,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _fetchLeaveApplications,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// APPLY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: context.scale(56),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                              elevation: 0,
                            ),
                            onPressed: () => _showApplyLeaveSheet(context),
                            icon: Icon(Icons.add, size: context.scale(20)),
                            label: Text("APPLY FOR NEW LEAVE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: context.font(14))),
                          ),
                        ),
                        SizedBox(height: context.lg),

                        /// FILTER CARD
                        _buildSectionHeader("Filter Applications", Icons.filter_list_rounded),
                        SizedBox(height: context.md),
                        _buildFilters(),
                        SizedBox(height: context.xl),

                        /// HISTORY LIST
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader("Leave History", Icons.history_rounded),
                            Text("${_filteredLeaves.length} applications", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
                          ],
                        ),
                        SizedBox(height: context.md),

                        if (_filteredLeaves.isEmpty)
                          _buildEmptyState()
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredLeaves.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                              crossAxisSpacing: context.md,
                              mainAxisSpacing: context.md,
                              mainAxisExtent: context.responsive(220, tablet: 230),
                            ),
                            itemBuilder: (context, index) => _buildLeaveCard(_filteredLeaves[index]),
                          ),
                        SizedBox(height: context.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(18),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Wrap(
                spacing: context.md,
                runSpacing: context.md,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - context.md) / 2 : double.infinity,
                    child: _buildFilterDropdown(
                      label: "Leave Type",
                      value: _selectedLeaveType,
                      items: ["Sick", "Casual", "Emergency", "Other"],
                      onChanged: (v) {
                        setState(() => _selectedLeaveType = v);
                        _applyFilters();
                      },
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - context.md) / 2 : double.infinity,
                    child: _buildFilterDropdown(
                      label: "Status",
                      value: _selectedStatus,
                      items: ["Pending", "Approved", "Rejected"],
                      onChanged: (v) {
                        setState(() => _selectedStatus = v);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: context.md),
            SizedBox(
              width: double.infinity,
              height: context.scale(48),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                onPressed: _resetFilters,
                child: Text("RESET FILTERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({required String label, String? value, required List<String> items, required Function(String?) onChanged}) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(11))),
        SizedBox(height: context.xs),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: colorScheme.surfaceContainerLow,
          hint: Text("All", style: TextStyle(fontSize: context.font(14))),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveCard(StudentLeave leave) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    Color statusColor = const Color(0xFFF59E0B); // Pending (Amber)
    if (leave.status.toLowerCase() == 'approved') statusColor = const Color(0xFF10B981); // Approved (Emerald)
    if (leave.status.toLowerCase() == 'rejected') statusColor = const Color(0xFFEF4444); // Rejected (Red)

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(context.scale(6)),
                  ),
                  child: Text(
                    leave.leaveType.toUpperCase(), 
                    style: TextStyle(color: colorScheme.primary, fontSize: context.font(11), fontWeight: FontWeight.bold),
                  ),
                ),
                _statusBadge(leave.status.toUpperCase(), statusColor),
              ],
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                _dateBlock("FROM", leave.fromDate),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.md),
                  child: Icon(Icons.arrow_forward_rounded, color: colorScheme.outline, size: context.scale(16)),
                ),
                _dateBlock("TO", leave.toDate),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.md),
              child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            Text(
              leave.reason, 
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5, fontSize: context.font(14)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBlock(String label, String dateStr) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    DateTime dt = DateTime.tryParse(dateStr) ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(10))),
        SizedBox(height: context.xs),
        Text(DateFormat('dd MMM').format(dt), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
        Text(DateFormat('yyyy').format(dt), style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(4)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(80)),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded, color: colorScheme.outlineVariant.withValues(alpha: 0.5), size: context.scale(80)),
            SizedBox(height: context.md),
            Text("No leave history found", style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(16))),
          ],
        ),
      ),
    );
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ApplyLeaveBottomSheet(),
    );
  }
}

class _ApplyLeaveBottomSheet extends StatefulWidget {
  const _ApplyLeaveBottomSheet();

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
        leaveType: _leaveType!.toLowerCase(),
        fromDate: DateFormat('yyyy-MM-dd').format(_fromDate!),
        toDate: DateFormat('yyyy-MM-dd').format(_toDate!),
        reason: _reasonController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        // Better way to find the state and refresh
        final state = context.findAncestorStateOfType<_LeaveApplicationPageState>();
        if (state != null) {
          state._selectedStatus = null; // Reset status filter
          state._selectedLeaveType = null; // Reset type filter
          state._fetchLeaveApplications();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Leave application submitted successfully"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: context.md, right: context.md, top: context.md),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: context.scale(40), height: context.scale(4), decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(context.scale(2))))),
                  SizedBox(height: context.md),
                  Text("Apply for Leave", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(24))),
                  SizedBox(height: context.xs),
                  Text("Fill in the details below to request time off.", style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                  SizedBox(height: context.lg),
                  
                  Text("Leave Type *", style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(11))),
                  SizedBox(height: context.xs),
                  DropdownButtonFormField<String>(
                    dropdownColor: colorScheme.surfaceContainerLow,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(16)),
                    items: ["Sick", "Casual", "Emergency", "Other"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14)))))
                        .toList(),
                    onChanged: (v) => _leaveType = v,
                    validator: (v) => v == null ? "Please select a leave type" : null,
                  ),
                  SizedBox(height: context.md),
                  
                  Row(
                    children: [
                      Expanded(child: _datePickerField("From Date *", _fromDate, (d) => setState(() => _fromDate = d))),
                      SizedBox(width: context.md),
                      Expanded(child: _datePickerField("To Date *", _toDate, (d) => setState(() => _toDate = d))),
                    ],
                  ),
                  SizedBox(height: context.md),
                  
                  Text("Reason *", style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(11))),
                  SizedBox(height: context.xs),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    style: TextStyle(fontSize: context.font(14)),
                    decoration: InputDecoration(
                      hintText: "Why do you need leave?",
                      hintStyle: TextStyle(fontSize: context.font(14)),
                    ),
                    validator: (v) => v!.isEmpty ? "Please provide a reason" : null,
                  ),
                  SizedBox(height: context.lg),
                  
                  SizedBox(
                    width: double.infinity,
                    height: context.scale(56),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(width: context.scale(24), height: context.scale(24), child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                          : Text("SUBMIT REQUEST", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: context.font(14))),
                    ),
                  ),
                  SizedBox(height: context.sm),
                  SizedBox(
                    width: double.infinity,
                    height: context.scale(56),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCEL", style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(14))),
                    ),
                  ),
                  SizedBox(height: context.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _datePickerField(String label, DateTime? date, Function(DateTime) onPick) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(11))),
        SizedBox(height: context.xs),
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
            padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(14)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), 
              borderRadius: BorderRadius.circular(context.scale(12)),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: colorScheme.primary.withValues(alpha: 0.7), size: context.scale(16)),
                SizedBox(width: context.sm),
                Expanded(
                  child: Text(
                    date == null ? "Select Date" : DateFormat('dd MMM, yyyy').format(date),
                    style: TextStyle(color: date == null ? colorScheme.onSurfaceVariant : colorScheme.onSurface, fontSize: context.font(14)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
