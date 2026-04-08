import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/salary_models.dart';
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
                _buildBankDetailsCard(data.account),
                const SizedBox(height: 24),
                _buildPastRecordsTable(data.salaries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankDetailsCard(BankAccount account) {
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
                buildActionButton(context, "GENERATE NEW SALARY SLIP", () {}, isPrimary: true),
              ],
            ),
          ),
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
