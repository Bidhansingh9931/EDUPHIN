import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/salary_models.dart';
import 'package:eduphin/staff/staff_dashboard/staff_models.dart' as staff_model;
import 'package:intl/intl.dart';
import 'common_widgets.dart';

class SalaryBankDetailsPage extends StatefulWidget {
  const SalaryBankDetailsPage({super.key});

  @override
  State<SalaryBankDetailsPage> createState() => _SalaryBankDetailsPageState();
}

class _SalaryBankDetailsPageState extends State<SalaryBankDetailsPage> {
  late Future<SalaryPageData> _salaryDataFuture;

  @override
  void initState() {
    super.initState();
    _salaryDataFuture = ApiService.getSalaryDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Salary & Bank Details"),
      ),
      body: FutureBuilder<SalaryPageData>(
        future: _salaryDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No salary data found"));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBankDetailsCard(data, data.account),
                const SizedBox(height: 24),
                _buildPastRecordsTable(data.salaries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankDetailsCard(SalaryPageData data, BankAccount account) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, size: 20),
                const SizedBox(width: 12),
                Text("Bank Details", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _detailRow(Icons.person_outline, "Account Holder:", account.accountHolderName),
                _detailRow(Icons.credit_card_outlined, "Account Number:", account.accountNumber ?? "N/A"),
                _detailRow(Icons.account_balance_outlined, "Bank Name:", account.bankName ?? "N/A"),
                _detailRow(Icons.code_outlined, "IFSC Code:", account.ifscCode ?? "N/A"),
                _detailRow(Icons.location_on_outlined, "Branch:", account.branch ?? "N/A"),
                _detailRow(Icons.payments_outlined, "Basic Salary:", "₹50,000.00"),
                const SizedBox(height: 16),
                buildActionButton(context, "GENERATE NEW SALARY SLIP", () {
                  if (data.salaries.isNotEmpty) {
                    _showSalaryDetail(data.salaries.first.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No salary records found to generate slip.")),
                    );
                  }
                }, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDetail(dynamic salaryId) async {
    try {
      final data = await ApiService.getStaffSalarySlip(salaryId.toString());
      final detail = staff_model.SalaryDetailData.fromJson(data);
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1D2645),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Salary Slip Detail", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildDetailItem("Net Salary", "₹ ${detail.salary.netSalary ?? detail.salary.amount}"),
              _buildDetailItem("Amount in words", detail.amountInWords),
              _buildDetailItem("Basic Salary", "₹ ${detail.salary.basicSalary ?? 'N/A'}"),
              _buildDetailItem("Month/Year", "${detail.salary.month} / ${detail.salary.year}"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPastRecordsTable(List<SalaryRecord> records) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF558B2F), // Greenish header as per image
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20, color: Colors.white),
                const SizedBox(width: 12),
                Text("Past Salary Records", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text("Month")),
                DataColumn(label: Text("Net Salary")),
                DataColumn(label: Text("Payment Date")),
              ],
              rows: records.map((record) {
                return DataRow(cells: [
                  DataCell(Text(record.paymentDate != null ? DateFormat('MMMM yyyy').format(DateTime.parse(record.paymentDate!)) : "N/A")),
                  DataCell(Text("₹${record.netSalary}", style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(record.paymentDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(record.paymentDate!)) : "N/A")),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
