import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';
import 'salary_detail.dart';

class SalaryBankPage extends StatefulWidget {
  const SalaryBankPage({super.key});

  @override
  State<SalaryBankPage> createState() => _SalaryBankPageState();
}

class _SalaryBankPageState extends State<SalaryBankPage> {
  bool _isLoading = true;
  UserDetail? _userDetail;
  List<Salary> _salaryHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchSalaryData();
  }

  Future<void> _fetchSalaryData() async {
    if (!mounted) return;
    try {
      final response = await ApiService.get('counselor/salaries');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            if (data['account'] != null) {
              _userDetail = UserDetail.fromJson(data['account']);
            }
            if (data['salaries'] != null) {
              _salaryHistory = (data['salaries'] as List)
                  .map((json) => Salary.fromJson(json))
                  .toList();
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lastSalary = _salaryHistory.isNotEmpty ? _salaryHistory.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Salary & Bank"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSalaryData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SALARY SUMMARY CARD
                  Card(
                    color: colorScheme.primary,
                    child: InkWell(
                      onTap: lastSalary != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalaryDetailPage(salaryId: lastSalary.id))) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Last Paid Amount",
                                  style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    lastSalary?.status.toUpperCase() ?? "N/A",
                                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lastSalary != null ? "₹${lastSalary.amount}" : "₹0.00",
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                _buildMiniInfo(context, "Payment Date", lastSalary?.paymentDate ?? "N/A"),
                                const Spacer(),
                                _buildMiniInfo(context, "For Month", lastSalary?.month ?? "N/A"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(context, "Bank Account Details"),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildDetailRow(context, Icons.person_outline, "Account Holder", _userDetail?.fullName ?? "N/A"),
                          _buildDetailRow(context, Icons.account_balance, "Bank Name", _userDetail?.bankName ?? "N/A"),
                          _buildDetailRow(context, Icons.numbers, "Account Number", _userDetail?.bankAccountNumber ?? "N/A"),
                          _buildDetailRow(context, Icons.code, "IFSC Code", _userDetail?.ifscCode ?? "N/A"),
                          _buildDetailRow(context, Icons.location_on_outlined, "Branch", _userDetail?.branchName ?? "N/A", isLast: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle(context, "Salary History"),
                  const SizedBox(height: 16),
                  _salaryHistory.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _salaryHistory.length,
                          itemBuilder: (context, index) {
                            final salary = _salaryHistory[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalaryDetailPage(salaryId: salary.id))),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.receipt_long, color: colorScheme.primary, size: 20),
                                ),
                                title: Text("Salary for ${salary.month}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text("Paid on ${salary.paymentDate}", style: const TextStyle(fontSize: 12)),
                                trailing: Text("₹${salary.amount}", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildMiniInfo(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ),
        if (!isLast) Divider(indent: 54, endIndent: 16, color: theme.dividerColor.withValues(alpha: 0.5), height: 1),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No Records Yet", style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}
