import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart' as accountant_model;
import 'package:intl/intl.dart';

class SalarySlipsPage extends StatefulWidget {
  final String? employeeId;
  const SalarySlipsPage({super.key, this.employeeId});

  @override
  State<SalarySlipsPage> createState() => _SalarySlipsPageState();
}

class _SalarySlipsPageState extends State<SalarySlipsPage> {
  bool _isLoading = true;
  List<accountant_model.Salary> _salaries = [];
  accountant_model.UserDetail? _employeeDetail;

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  Future<void> _fetchSalaries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> responseData;
      if (widget.employeeId != null) {
        responseData = await ApiService.getAccountantEmployeeSalary(widget.employeeId!);
      } else {
        responseData = await ApiService.getAccountantMySalaries();
      }

      if (mounted) {
        setState(() {
          if (responseData['account'] != null) {
            _employeeDetail = accountant_model.UserDetail.fromJson(responseData['account']);
          }
          if (responseData['salaries'] != null) {
            _salaries = (responseData['salaries'] as List).map((e) => accountant_model.Salary.fromJson(e)).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId != null ? "Employee Salary Slips" : "My Salary Slips"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      if (_employeeDetail != null && widget.employeeId != null) _buildEmployeeHeader(context),
                      if (_salaries.isEmpty) 
                        _buildEmptyState(context)
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _salaries.length,
                          itemBuilder: (context, index) => _buildSalaryCard(context, _salaries[index]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: widget.employeeId != null ? FloatingActionButton(
        onPressed: () => _showGenerateSalaryDialog(),
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildEmployeeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
              child: Text(_employeeDetail!.name[0], style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_employeeDetail!.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                  Text("ID: ${widget.employeeId}", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(BuildContext context, accountant_model.Salary salary) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _showSalaryDetail(salary),
        title: Text(salary.month ?? "Salary Slip", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Paid: ${salary.paymentDate ?? 'Pending'}", style: TextStyle(fontSize: 12, color: theme.hintColor)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("₹${salary.amount}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(salary.status.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Icon(Icons.payments_outlined, size: 64, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text("No salary records found", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  void _showSalaryDetail(accountant_model.Salary salary) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<Map<String, dynamic>>(
              future: ApiService.getAccountantSalaryDetail(salary.encryptedId ?? salary.id.toString()),
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final data = snapshot.data?['salary'] ?? {};
                final amountInWords = snapshot.data?['amount_in_words'] ?? '';

                return Container(
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.hintColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 24)),
                      Text("Salary Slip Detail", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      if (isLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                      else ...[
                        _detailRow(context, "Month/Year", "${data['month'] ?? salary.month}/${data['year'] ?? salary.year}"),
                        _detailRow(context, "Basic Pay", "₹${data['basic_salary'] ?? salary.amount}"),
                        _detailRow(context, "Allowances", "₹${data['allowances'] ?? '0'}"),
                        _detailRow(context, "Deductions", "₹${data['deductions'] ?? '0'}"),
                        const Divider(height: 24),
                        _detailRow(context, "Net Salary", "₹${data['net_salary'] ?? salary.amount}", isBold: true),
                        if (amountInWords.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(amountInWords, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.primary, fontStyle: FontStyle.italic, fontSize: 13)),
                          ),
                        _detailRow(context, "Payment Date", data['payment_date'] ?? salary.paymentDate ?? "N/A"),
                        _detailRow(context, "Status", salary.status),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Salary Slip"),
                                      content: const Text("Are you sure you want to delete this salary record?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await ApiService.deleteAccountantSalary(salary.encryptedId ?? salary.id.toString());
                                      if (mounted) {
                                        Navigator.pop(context);
                                        _fetchSalaries();
                                      }
                                    } catch (e) {
                                      scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text("DELETE", style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  void _showGenerateSalaryDialog() {
    final basicController = TextEditingController();
    final allowancesController = TextEditingController();
    final deductionsController = TextEditingController();
    final dateController = TextEditingController();
    String? selectedMonth;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Generate Salary"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMonth,
                  hint: const Text("Select Month"),
                  items: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) => setDialogState(() => selectedMonth = val),
                ),
                const SizedBox(height: 12),
                TextField(controller: basicController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Basic Salary")),
                const SizedBox(height: 12),
                TextField(controller: dateController, readOnly: true, decoration: const InputDecoration(labelText: "Payment Date", suffixIcon: Icon(Icons.calendar_today)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                    if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton(
                onPressed: () async {
                if (selectedMonth == null || basicController.text.isEmpty) return;
                try {
                  await ApiService.storeAccountantEmployeeSalary(widget.employeeId!, {
                    'month': selectedMonth,
                    'year': DateTime.now().year,
                    'basic_salary': double.parse(basicController.text),
                    'payment_date': dateController.text,
                  });
                  Navigator.pop(context);
                  _fetchSalaries();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("GENERATE"),
            ),
          ],
        ),
      ),
    );
  }
}
