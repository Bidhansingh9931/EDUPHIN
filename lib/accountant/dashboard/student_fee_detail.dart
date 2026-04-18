import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class StudentFeeDetailPage extends StatefulWidget {
  const StudentFeeDetailPage({super.key});

  @override
  State<StudentFeeDetailPage> createState() => _StudentFeeDetailPageState();
}

class _StudentFeeDetailPageState extends State<StudentFeeDetailPage> {
  bool _isLoading = false;
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  dynamic _selectedClassId;
  dynamic _selectedSectionId;
  List<dynamic> _students = [];
  Map<String, dynamic>? _studentDetails;
  dynamic _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('accountants/students');
      if (response.statusCode == 200 && mounted) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? body;
        setState(() {
          _classes = data['classes'] ?? [];
          _sections = data['sections'] ?? [];
          _students = data['students'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Initial Data Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> query = {};
      if (_selectedClassId != null) query['class_filter'] = _selectedClassId.toString();
      if (_selectedSectionId != null) query['section_filter'] = _selectedSectionId.toString();

      final students = await ApiService.getAccountantStudents(query);
      if (mounted) {
        setState(() {
          _students = students;
          _studentDetails = null;
          _selectedStudentId = null;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudentDetails(dynamic id) async {
    if (!mounted || id == null) return;

    final String studentId = id.toString();
    setState(() => _isLoading = true);
    try {
      debugPrint("Fetching details for student: $studentId");
      final details = await ApiService.getAccountantStudentFeeDetails(studentId);
      if (mounted) {
        setState(() {
          _studentDetails = details;
          _selectedStudentId = studentId;
        });
        debugPrint("Successfully loaded details for $studentId");
      }
    } catch (e) {
      debugPrint("Student Fee Detail Error: $e");
      if (mounted) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) msg = msg.replaceFirst('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: "Retry", textColor: Colors.white, onPressed: () => _fetchStudentDetails(id)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isMobile = !context.isTablet;
    final bool showDetails = _studentDetails != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(showDetails && isMobile ? "Student Details" : "Student Fees Management"),
        leading: showDetails && isMobile
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _studentDetails = null;
            _selectedStudentId = null;
          }),
        )
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    if (!showDetails || !isMobile) ...[
                      _buildFilterSection(context),
                      const SizedBox(height: 24),
                    ],
                    if (context.isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _buildStudentList(context)),
                          const SizedBox(width: 24),
                          Expanded(flex: 6, child: showDetails ? _buildDetailedView(context) : _buildEmptyDetail(context)),
                        ],
                      )
                    else ...[
                      if (!showDetails) _buildStudentList(context) else _buildDetailedView(context),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildEmptyDetail(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search_outlined, size: 64, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text("Select a student to view details", style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return Column(
      children: [
        _buildStudentInfoCard(context),
        const SizedBox(height: 20),
        _buildFeeSummarySection(context),
        const SizedBox(height: 20),
        _buildFineDetailsSection(context),
        const SizedBox(height: 20),
        _buildPaymentHistorySection(context),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filter Students", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdownField(context, _classes, _selectedClassId, "All Classes", (val) => setState(() => _selectedClassId = val))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownField(context, _sections, _selectedSectionId, "All Sections", (val) => setState(() => _selectedSectionId = val), isSection: true)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchStudents,
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
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      items: [
        DropdownMenuItem<dynamic>(value: null, child: Text(hint)),
        ...items.map((c) => DropdownMenuItem<dynamic>(
          value: c['id'],
          child: Text((isSection ? (c['section_name'] ?? c['name']) : c['name'])?.toString() ?? 'N/A'),
        )),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Student Directory", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          if (_students.isEmpty && !_isLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No students found")))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _students.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentId = student['encrypted_id'] ?? student['id'].toString();
                final isSelected = _selectedStudentId == studentId;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text("${index + 1}", style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim().isEmpty
                        ? (student["name"]?.toString() ?? student["user"]?["name"]?.toString() ?? 'N/A')
                        : "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text("${student["class"]?["name"] ?? 'N/A'} - ${student["section"]?["section_name"] ?? student["section"]?["name"] ?? 'N/A'}", style: TextStyle(fontSize: 11, color: theme.hintColor)),
                  onTap: () {
                    final targetId = student['encrypted_id'] ?? student['id'].toString();
                    _fetchStudentDetails(targetId);
                  },
                );
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(BuildContext context) {
    if (_studentDetails == null || _studentDetails!['student'] == null) return const SizedBox();
    final theme = Theme.of(context);
    final info = _studentDetails!['student'];
    final summary = _studentDetails!['summary'] ?? {};
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: theme.colorScheme.primary, radius: 20, child: const Icon(Icons.person, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${info['first_name'] ?? ''} ${info['last_name'] ?? ''}".trim().isEmpty ? (info['name']?.toString() ?? 'N/A') : "${info['first_name'] ?? ''} ${info['last_name'] ?? ''}",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailGrid(context, info),
            const Divider(height: 40),
            Text("Financial Overview", style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
            const SizedBox(height: 16),
            _buildSummaryRow(context, "Total Payable", "₹${summary['total_payable'] ?? '0'}", theme.colorScheme.primary),
            _buildSummaryRow(context, "Total Paid", "₹${summary['total_paid'] ?? '0'}", Colors.green),
            _buildSummaryRow(context, "Balance Due", "₹${summary['due'] ?? '0'}", Colors.orange, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, dynamic info) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
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
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFeeSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final List<dynamic> fees = _studentDetails!['fees'] ?? [];
    final overridesData = _studentDetails!['overrides'];
    final Map<String, dynamic> overrides = (overridesData is Map) ? Map<String, dynamic>.from(overridesData) : {};

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text("Assigned Fee Components", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (fees.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Text("No fees assigned"))
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
                  title: Text(fee['fee_name'] ?? 'Fee', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: isOverridden ? const Text("Manual Override Applied", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("₹$amount", style: TextStyle(fontWeight: FontWeight.bold, color: isOverridden ? Colors.orange : null)),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showOverrideDialog(feeId, amount.toString(), overrideData?['reason'] ?? '')),
                    ],
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _showPaymentDialog,
              icon: const Icon(Icons.payment, size: 18),
              label: const Text("COLLECT PAYMENT"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final finesData = _studentDetails!['fines'];
    final List<dynamic> fines = (finesData is List) ? finesData : [];
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text("Late Fines / Penalties", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton.icon(
                  onPressed: _showAddFineDialog,
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text("ADD FINE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.2)),
                ),
              ],
            ),
          ),
          if (fines.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Text("No fines recorded"))
          else
            ...fines.map((fine) {
              final fineId = fine['encrypted_id'] ?? fine['id'].toString();
              return ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(fine['reason'] ?? 'Fine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(fine['created_at']?.toString().split('T')[0] ?? '', style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("₹${fine['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _deleteFine(fineId)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(BuildContext context) {
    final theme = Theme.of(context);
    final paymentsData = _studentDetails!['payments'];
    final List<dynamic> history = (paymentsData is List) ? paymentsData : [];
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: const Row(
              children: [
                Icon(Icons.history, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text("Transaction History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (history.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Text("No transactions yet"))
          else
            ...history.map((pay) => ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, radius: 14, child: Icon(Icons.arrow_downward, size: 14, color: Colors.white)),
              title: Text("₹${pay['paid_amount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${pay['payment_date']} • ${pay['mode']}", style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.receipt_long_outlined, size: 20),
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
          final theme = Theme.of(sheetContext);
          return Container(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, top: 24, left: 24, right: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Record Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount (₹)")),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => selectedMode = v!,
                    decoration: const InputDecoration(labelText: "Mode"),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: remarkController, decoration: const InputDecoration(labelText: "Remarks (Optional)")),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amountController.text.isEmpty) return;
                        Navigator.pop(sheetContext);
                        setState(() => _isLoading = true);
                        try {
                          await ApiService.storeAccountantPayment({
                            'student_id': _selectedStudentId,
                            'paid_amount': amountController.text,
                            'payment_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            'mode': selectedMode,
                            'remarks': remarkController.text,
                          });
                          _fetchStudentDetails(_selectedStudentId);
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: const Text("SUBMIT PAYMENT"),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
    );
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
            const SizedBox(height: 12),
            TextField(controller: reasonController, decoration: const InputDecoration(labelText: "Reason")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await ApiService.storeFeeOverride(_selectedStudentId.toString(), feeId, {
                  'overridden_amount': amountController.text,
                  'reason': reasonController.text,
                });
                _fetchStudentDetails(_selectedStudentId);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              } finally {
                if (mounted) setState(() => _isLoading = false);
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
            const SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await ApiService.storeOrUpdateFine({
                  'student_id': _selectedStudentId,
                  'amount': amountController.text,
                  'reason': reasonController.text,
                });
                _fetchStudentDetails(_selectedStudentId);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFine(String fineId) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteFine(fineId);
      _fetchStudentDetails(_selectedStudentId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}