import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';
import 'package:intl/intl.dart';

class SalarySlipsPage extends StatefulWidget {
  final int? employeeId;
  const SalarySlipsPage({super.key, this.employeeId});

  @override
  State<SalarySlipsPage> createState() => _SalarySlipsPageState();
}

class _SalarySlipsPageState extends State<SalarySlipsPage> {
  bool _isLoading = true;
  List<Salary> _salaries = [];
  UserDetail? _employeeDetail;

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
        responseData = await ApiService.getAccountantEmployeeSalary(widget.employeeId.toString());
      } else {
        responseData = await ApiService.getAccountantMySalaries();
      }

      if (mounted) {
        setState(() {
          if (responseData['account'] != null) {
            _employeeDetail = UserDetail.fromJson(responseData['account']);
          }
          if (responseData['salaries'] != null) {
            _salaries = (responseData['salaries'] as List).map((e) => Salary.fromJson(e)).toList();
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

  Widget _buildSalaryCard(BuildContext context, Salary salary) {
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

  void _showSalaryDetail(Salary salary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Salary Breakdown", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _detailRow(context, "Month/Year", salary.month ?? "N/A"),
              _detailRow(context, "Basic Pay", "₹${salary.amount}"),
              _detailRow(context, "Date", salary.paymentDate ?? "N/A"),
              _detailRow(context, "Status", salary.status),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  await ApiService.storeAccountantEmployeeSalary(widget.employeeId.toString(), {
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
