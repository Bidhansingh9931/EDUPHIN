import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class SalaryBankDetailsPage extends StatefulWidget {
  const SalaryBankDetailsPage({super.key});

  @override
  State<SalaryBankDetailsPage> createState() => _SalaryBankDetailsPageState();
}

class _SalaryBankDetailsPageState extends State<SalaryBankDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _salaryData;

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  Future<void> _fetchSalaries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getLibrarianSalaries();
      if (mounted) {
        setState(() {
          // The backend returns {account, salaries} or {userDetail, lastSalary, salaries}
          // We normalize it based on what the UI expects
          _salaryData = {
            'userDetail': data['account'] ?? data['userDetail'],
            'lastSalary': data['lastSalary'] ?? (data['salaries'] is List && (data['salaries'] as List).isNotEmpty ? data['salaries'][0] : null),
            'salaries': data['salaries'] ?? [],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _viewSalarySlip(dynamic salaryId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final slipData = await ApiService.getLibrarianSalarySlip(salaryId.toString());
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24, left: 24, right: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: theme.dividerTheme.color, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Salary Slip Details", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 48),
                  _buildSlipRow(context, "Basic Salary:", "₹${slipData['salary']?['basic_salary'] ?? slipData['basic_salary'] ?? '0.00'}"),
                  _buildSlipRow(context, "Allowances:", "₹${slipData['salary']?['allowances'] ?? slipData['allowance'] ?? '0.00'}"),
                  _buildSlipRow(context, "Deductions:", "₹${slipData['salary']?['deductions'] ?? slipData['deduction'] ?? '0.00'}"),
                  const Divider(height: 32),
                  _buildSlipRow(context, "Net Salary:", "₹${slipData['salary']?['net_salary'] ?? slipData['net_salary'] ?? '0.00'}", isBold: true),
                  const SizedBox(height: 12),
                  Text("In Words: ${slipData['amountInWords'] ?? 'N/A'}", 
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.hintColor)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.download),
                      label: const Text("DOWNLOAD PDF"),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildSlipRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salary & Bank Details"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSalaries,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        /// BANK DETAILS CARD
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance, color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Text("Bank Details", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Divider(height: 40),
                                _buildDetailRow(context, "Account Holder", _salaryData?['userDetail']?['first_name'] != null ? "${_salaryData?['userDetail']?['first_name']} ${_salaryData?['userDetail']?['last_name'] ?? ''}".trim() : "N/A"),
                                _buildDetailRow(context, "Account Number", _salaryData?['userDetail']?['bank_account_number'] ?? "N/A"),
                                _buildDetailRow(context, "Bank Name", _salaryData?['userDetail']?['bank_name'] ?? "N/A"),
                                _buildDetailRow(context, "IFSC Code", _salaryData?['userDetail']?['ifsc_code'] ?? "N/A"),
                                _buildDetailRow(context, "Branch", _salaryData?['userDetail']?['branch_name'] ?? "N/A"),
                                _buildDetailRow(context, "Current Salary", "₹${_salaryData?['lastSalary']?['amount'] ?? _salaryData?['lastSalary']?['net_salary'] ?? '0.00'}", isLast: true),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// PAST SALARY RECORDS SECTION
                        Row(
                          children: [
                            Icon(Icons.history, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Text("Past Salary Records", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _salaryData?['salaries'] == null || (_salaryData!['salaries'] as List).isEmpty
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Center(child: Text("No Salary Records Found", style: TextStyle(color: theme.hintColor))),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: (_salaryData!['salaries'] as List).length,
                                itemBuilder: (context, index) {
                                  final salary = _salaryData!['salaries'][index];
                                  final isPaid = salary['status']?.toLowerCase() == 'paid';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      onTap: () => _viewSalarySlip(salary['id']),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: CircleAvatar(
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        child: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                                      ),
                                      title: Text("₹${salary['amount'] ?? salary['net_salary'] ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                        salary['payment_date'] != null 
                                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary['payment_date'])) 
                                          : (salary['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary['created_at'])) : "N/A"),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.5)),
                                        ),
                                        child: Text(
                                          (salary['status'] ?? "N/A").toUpperCase(), 
                                          style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (!isLast) const SizedBox(height: 16),
          if (!isLast) Divider(height: 1, color: theme.dividerTheme.color?.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
