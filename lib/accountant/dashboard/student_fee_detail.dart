import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';

class StudentFeeDetailPage extends StatefulWidget {
  const StudentFeeDetailPage({super.key});

  @override
  State<StudentFeeDetailPage> createState() => _StudentFeeDetailPageState();
}

class _StudentFeeDetailPageState extends State<StudentFeeDetailPage> {
  late Stream<Map<String, dynamic>> _studentsStream;
  Stream<Map<String, dynamic>>? _studentDetailsStream;
  
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  dynamic _selectedClassId;
  dynamic _selectedSectionId;
  String? _selectedStudentId;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() {
    setState(() {
      final Map<String, String> query = {};
      if (_selectedClassId != null) query['class_filter'] = _selectedClassId.toString();
      if (_selectedSectionId != null) query['section_filter'] = _selectedSectionId.toString();
      _studentsStream = ApiService.getAccountantStudentsStream(query).handleError((error) {
        if (mounted) ErrorHandler.showError(context, error);
      });
    });
  }

  void _fetchStudentDetails(String studentId) {
    setState(() {
      _selectedStudentId = studentId;
      _studentDetailsStream = ApiService.getAccountantStudentFeeDetailsStream(studentId).handleError((error) {
        if (mounted) ErrorHandler.showError(context, error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isMobile = !context.isTablet;
    final bool showDetails = _selectedStudentId != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(showDetails && isMobile ? "Student Details" : "Student Fees Management"),
          ),
        ),
        leading: showDetails && isMobile
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _selectedStudentId = null;
                  _studentDetailsStream = null;
                }),
              )
            : null,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _studentsStream,
        builder: (context, studentsSnapshot) {
          if (studentsSnapshot.hasData) {
            final data = studentsSnapshot.data!;
            _classes = data['classes'] ?? [];
            _sections = data['sections'] ?? [];
          }
          return LoadingWrapper<Map<String, dynamic>>(
            snapshot: studentsSnapshot,
            onRetry: _fetchStudents,
            skeleton: _buildSkeleton(context),
            builder: (data) {
              final students = data['students'] ?? (data is List ? data : []);
              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(1000)),
                    child: Column(
                      children: [
                        if (!showDetails || !isMobile) ...[
                          _buildFilterSection(context),
                          SizedBox(height: context.spacing),
                        ],
                        if (context.isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: _buildStudentList(context, students)),
                              SizedBox(width: context.spacing),
                              Expanded(
                                flex: 6,
                                child: _selectedStudentId != null ? _buildDetailsStreamWrapper() : _buildEmptyDetail(context),
                              ),
                            ],
                          )
                        else if (!showDetails)
                          _buildStudentList(context, students)
                        else
                          _buildDetailsStreamWrapper(),
                        SizedBox(height: context.spacing * 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            children: [
              Skeleton(height: context.scale(180), width: double.infinity, borderRadius: context.scale(16)),
              SizedBox(height: context.spacing),
              _buildStudentListSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStreamWrapper() {
    return StreamBuilder<Map<String, dynamic>>(
      key: ValueKey(_selectedStudentId),
      stream: _studentDetailsStream,
      builder: (context, snapshot) {
        return LoadingWrapper<Map<String, dynamic>>(
          snapshot: snapshot,
          onRetry: () => _fetchStudentDetails(_selectedStudentId!),
          skeleton: _buildDetailsSkeleton(),
          builder: (data) => _buildDetailedView(context, data),
        );
      },
    );
  }

  Widget _buildEmptyDetail(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(40.0)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search_outlined, size: context.scale(64), color: context.theme.hintColor.withValues(alpha: 0.3)),
              SizedBox(height: context.spacing),
              Text("Select a student to view details", style: TextStyle(color: context.theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context, Map<String, dynamic> data) {
    return Column(
      children: [
        if (_isProcessing) const LinearProgressIndicator(),
        _buildStudentInfoCard(context, data),
        SizedBox(height: context.spacing),
        _buildFeeSummarySection(context, data),
        SizedBox(height: context.spacing),
        _buildFineDetailsSection(context, data),
        SizedBox(height: context.spacing),
        _buildPaymentHistorySection(context, data),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filter Students", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: context.spacing),
            AdaptiveFieldRow(
              children: [
                _buildDropdownField(context, _classes, _selectedClassId, "All Classes", (val) => setState(() => _selectedClassId = val)),
                _buildDropdownField(context, _sections, _selectedSectionId, "All Sections", (val) => setState(() => _selectedSectionId = val), isSection: true),
              ],
            ),
            SizedBox(height: context.spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchStudents,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                ),
                child: const Text("APPLY FILTERS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, List<dynamic> items, dynamic value, String hint, Function(dynamic) onChanged, {bool isSection = false}) {
    return DropdownButtonFormField<dynamic>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: TextStyle(fontSize: context.font(13))),
      items: [
        DropdownMenuItem<dynamic>(value: null, child: Text(hint)),
        ...items.map((c) => DropdownMenuItem<dynamic>(
              value: c['id'],
              child: Text((isSection ? (c['section_name'] ?? c['name']) : c['name'])?.toString() ?? 'N/A'),
            )),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(12))),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, List<dynamic> students) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Text("Student Directory", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          if (students.isEmpty)
            Padding(padding: EdgeInsets.all(context.scale(40)), child: const Center(child: Text("No students found")))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = students[index];
                final studentId = student['encrypted_id'] ?? student['id'].toString();
                final isSelected = _selectedStudentId == studentId;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                  contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(4)),
                  leading: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CircleAvatar(
                      radius: context.scale(16),
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text("${index + 1}", style: TextStyle(fontSize: context.font(10), color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim().isEmpty ? (student["name"]?.toString() ?? student["user"]?["name"]?.toString() ?? 'N/A') : "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                    ),
                  ),
                  subtitle: Text("${student["class"]?["name"] ?? 'N/A'} - ${student["section"]?["section_name"] ?? student["section"]?["name"] ?? 'N/A'}", style: TextStyle(fontSize: context.font(11), color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => _fetchStudentDetails(studentId),
                );
              },
            ),
          SizedBox(height: context.scale(12)),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(BuildContext context, Map<String, dynamic> data) {
    final info = data['student'];
    if (info == null) return const SizedBox();
    final theme = context.theme;
    final summary = data['summary'] ?? {};
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: theme.colorScheme.primary, radius: context.scale(24), child: Icon(Icons.person, color: Colors.white, size: context.scale(24))),
                  SizedBox(width: context.spacing),
                  Text(
                    "${info['first_name'] ?? ''} ${info['last_name'] ?? ''}".trim().isEmpty ? (info['name']?.toString() ?? 'N/A') : "${info['first_name'] ?? ''} ${info['last_name'] ?? ''}",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.spacing),
            _buildDetailGrid(context, info),
            Divider(height: context.scale(40), color: theme.colorScheme.outlineVariant),
            Text("Financial Overview", style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
            SizedBox(height: context.spacing),
            _buildSummaryRow(context, "Total Payable", "₹${summary['total_payable'] ?? '0'}", theme.colorScheme.primary),
            _buildSummaryRow(context, "Total Paid", "₹${summary['total_paid'] ?? '0'}", Colors.green),
            _buildSummaryRow(context, "Balance Due", "₹${summary['due'] ?? '0'}", Colors.orange, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, dynamic info) {
    return AdaptiveFieldRow(
      children: [
        _infoItem(context, "Roll No", info['roll_no']?.toString() ?? 'N/A'),
        _infoItem(context, "Class", "${info['class']?['name'] ?? 'N/A'} - ${info['section']?['section_name'] ?? info['section']?['name'] ?? 'N/A'}"),
        _infoItem(context, "Email", info['email']?.toString() ?? 'N/A'),
      ],
    );
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.theme.hintColor, fontSize: context.font(10), fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: context.font(13)), maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8.0)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: context.font(13))),
            SizedBox(width: context.spacing),
            Text(value, style: TextStyle(color: color, fontSize: context.font(15), fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummarySection(BuildContext context, Map<String, dynamic> data) {
    final theme = context.theme;
    final List<dynamic> fees = data['fees'] ?? [];
    final overridesData = data['overrides'];
    final Map<String, dynamic> overrides = (overridesData is Map) ? Map<String, dynamic>.from(overridesData) : {};

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing),
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(16)))),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white, size: context.scale(20)),
                  SizedBox(width: context.spacing / 2),
                  const Text("Assigned Fee Components", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          if (fees.isEmpty)
            Padding(padding: EdgeInsets.all(context.scale(32)), child: const Text("No fees assigned"))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fees.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final fee = fees[index];
                final feeId = fee['encrypted_id'] ?? fee['id'].toString();
                final isOverridden = overrides.containsKey(feeId) || overrides.containsKey(fee['id'].toString());
                final overrideData = overrides[feeId] ?? overrides[fee['id'].toString()];
                final amount = isOverridden ? overrideData['overridden_amount'] : fee['amount'];

                return ListTile(
                  title: Text(fee['fee_name'] ?? 'Fee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                  subtitle: isOverridden ? Text("Manual Override Applied", style: TextStyle(color: Colors.orange, fontSize: context.font(10), fontWeight: FontWeight.bold)) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("₹$amount", style: TextStyle(fontWeight: FontWeight.bold, color: isOverridden ? Colors.orange : null, fontSize: context.font(14))),
                      SizedBox(width: context.scale(8)),
                      IconButton(icon: Icon(Icons.edit_outlined, size: context.scale(18)), onPressed: () => _showOverrideDialog(feeId, amount.toString(), overrideData?['reason'] ?? '')),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPaymentDialog,
                icon: Icon(Icons.payment, size: context.scale(18)),
                label: const Text("COLLECT PAYMENT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineDetailsSection(BuildContext context, Map<String, dynamic> data) {
    final theme = context.theme;
    final finesData = data['fines'];
    final List<dynamic> fines = (finesData is List) ? finesData : [];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing),
            decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(16)))),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.white, size: context.scale(20)),
                      SizedBox(width: context.spacing / 2),
                      const Text("Late Fines / Penalties", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(width: context.spacing),
                  TextButton.icon(
                    onPressed: _showAddFineDialog,
                    icon: Icon(Icons.add, size: context.scale(14), color: Colors.white),
                    label: Text("ADD FINE", style: TextStyle(color: Colors.white, fontSize: context.font(11), fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.2)),
                  ),
                ],
              ),
            ),
          ),
          if (fines.isEmpty)
            Padding(padding: EdgeInsets.all(context.scale(32)), child: const Text("No fines recorded"))
          else
            ...fines.map((fine) {
              final fineId = fine['encrypted_id'] ?? fine['id'].toString();
              return ListTile(
                leading: Icon(Icons.error_outline, color: Colors.red, size: context.scale(24)),
                title: Text(fine['reason'] ?? 'Fine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13))),
                subtitle: Text(fine['created_at']?.toString().split('T')[0] ?? '', style: TextStyle(fontSize: context.font(11))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("₹${fine['amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: context.font(14))),
                    IconButton(icon: Icon(Icons.delete_outline, size: context.scale(18), color: Colors.red), onPressed: () => _deleteFine(fineId)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(BuildContext context, Map<String, dynamic> data) {
    final theme = context.theme;
    final paymentsData = data['payments'];
    final List<dynamic> history = (paymentsData is List) ? paymentsData : [];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.spacing),
            decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(16)))),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.white, size: context.scale(20)),
                  SizedBox(width: context.spacing / 2),
                  const Text("Transaction History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          if (history.isEmpty)
            Padding(padding: EdgeInsets.all(context.scale(32)), child: const Text("No transactions yet"))
          else
            ...history.map((pay) => ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green, radius: context.scale(14), child: Icon(Icons.arrow_downward, size: context.scale(14), color: Colors.white)),
                  title: Text("₹${pay['paid_amount']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                  subtitle: Text("${pay['payment_date']} • ${pay['mode']}", style: TextStyle(fontSize: context.font(11))),
                  trailing: Icon(Icons.receipt_long_outlined, size: context.scale(20)),
                  onTap: () {},
                )),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    final amountController = TextEditingController();
    final remarkController = TextEditingController();
    String selectedMode = 'Cash';

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final theme = sheetContext.theme;
          return Container(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24)))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, top: context.scale(24), left: context.scale(24), right: context.scale(24)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Record Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: context.spacing),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount (₹)")),
                  SizedBox(height: context.spacing),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => selectedMode = v!,
                    decoration: const InputDecoration(labelText: "Mode"),
                  ),
                  SizedBox(height: context.spacing),
                  TextField(controller: remarkController, decoration: const InputDecoration(labelText: "Remarks (Optional)")),
                  SizedBox(height: context.spacing * 1.5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amountController.text.isEmpty) return;
                        Navigator.pop(sheetContext);
                        setState(() => _isProcessing = true);
                        try {
                          await ApiService.storeAccountantPayment({
                            'student_id': _selectedStudentId,
                            'paid_amount': amountController.text,
                            'payment_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            'mode': selectedMode,
                            'remarks': remarkController.text,
                          });
                          _fetchStudentDetails(_selectedStudentId!);
                        } catch (e) {
                          if (mounted) ErrorHandler.showError(context, e);
                        } finally {
                          if (mounted) setState(() => _isProcessing = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      ),
                      child: const Text("SUBMIT PAYMENT"),
                    ),
                  ),
                  SizedBox(height: context.scale(40)),
                ],
              ),
            ),
          );
        });
  }

  void _showOverrideDialog(String feeId, String currentAmount, String currentReason) {
    final amountController = TextEditingController(text: currentAmount);
    final reasonController = TextEditingController(text: currentReason);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Adjust Fee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "New Amount")),
            SizedBox(height: context.spacing / 2),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isProcessing = true);
              try {
                await ApiService.storeFeeOverride(_selectedStudentId.toString(), feeId, {
                  'overridden_amount': amountController.text,
                  'reason': reasonController.text,
                });
                _fetchStudentDetails(_selectedStudentId!);
              } catch (e) {
                if (mounted) ErrorHandler.showError(context, e);
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text("APPLY"),
          ),
        ],
      ),
    );
  }

  void _showAddFineDialog() {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Fine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason")),
            SizedBox(height: context.spacing / 2),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isProcessing = true);
              try {
                await ApiService.storeOrUpdateFine({
                  'student_id': _selectedStudentId,
                  'amount': amountController.text,
                  'reason': reasonController.text,
                });
                _fetchStudentDetails(_selectedStudentId!);
              } catch (e) {
                if (mounted) ErrorHandler.showError(context, e);
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFine(String fineId) async {
    setState(() => _isProcessing = true);
    try {
      await ApiService.deleteFine(fineId);
      _fetchStudentDetails(_selectedStudentId!);
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildStudentListSkeleton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Skeleton(height: context.font(16), width: context.scale(120)),
          ),
          const Divider(height: 1),
          ...List.generate(
            5,
            (index) => ListTile(
              leading: Skeleton(width: context.scale(32), height: context.scale(32), borderRadius: context.scale(16)),
              title: Skeleton(height: context.font(14), width: context.scale(150)),
              subtitle: Skeleton(height: context.font(11), width: context.scale(100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSkeleton() {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(16)),
            side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
                    SizedBox(width: context.spacing),
                    Skeleton(height: context.font(18), width: context.scale(150)),
                  ],
                ),
                SizedBox(height: context.spacing),
                Wrap(
                  spacing: context.spacing,
                  runSpacing: context.scale(12),
                  children: List.generate(
                    3,
                    (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: context.font(10), width: context.scale(40)),
                        SizedBox(height: context.scale(4)),
                        Skeleton(height: context.font(13), width: context.scale(80)),
                      ],
                    ),
                  ),
                ),
                Divider(height: context.scale(40), color: context.theme.colorScheme.outlineVariant),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: context.scale(8.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Skeleton(height: context.font(13), width: context.scale(80)),
                        Skeleton(height: context.font(15), width: context.scale(60)),
                      ],
                    ),
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
