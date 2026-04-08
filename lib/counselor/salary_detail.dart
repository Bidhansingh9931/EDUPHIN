import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class SalaryDetailPage extends StatefulWidget {
  final int salaryId;
  const SalaryDetailPage({super.key, required this.salaryId});

  @override
  State<SalaryDetailPage> createState() => _SalaryDetailPageState();
}

class _SalaryDetailPageState extends State<SalaryDetailPage> {
  bool _isLoading = true;
  Salary? _salary;
  String? _amountInWords;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await ApiService.get('counselor/salaries/${widget.salaryId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _salary = Salary.fromJson(data['salary']);
          _amountInWords = data['amount_in_words'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Salary Payslip")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salary == null
              ? const Center(child: Text("Salary details not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text("SALARY SLIP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                Text("For the month of ${_salary!.month}", style: TextStyle(color: theme.hintColor)),
                              ],
                            ),
                          ),
                          const Divider(height: 40),
                          _buildRow("Basic Salary", "₹${_salary!.amount}"),
                          _buildRow("Status", _salary!.status.toUpperCase()),
                          _buildRow("Payment Date", _salary!.paymentDate),
                          const Divider(height: 40),
                          const Text("TOTAL NET SALARY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text("₹${_salary!.amount}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          const SizedBox(height: 8),
                          Text("Amount in words:", style: TextStyle(fontSize: 11, color: theme.hintColor, fontStyle: FontStyle.italic)),
                          Text(_amountInWords ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                              label: const Text("DOWNLOAD PDF"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
