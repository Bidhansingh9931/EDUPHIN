import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffSalaryDetailPage extends StatefulWidget {
  const StaffSalaryDetailPage({super.key});

  @override
  State<StaffSalaryDetailPage> createState() => _StaffSalaryDetailPageState();
}

class _StaffSalaryDetailPageState extends State<StaffSalaryDetailPage> {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);

  late Future<SalaryPageData> _salaryPageFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _salaryPageFuture = ApiService.getStaffSalaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Salary Detail", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<SalaryPageData>(
          future: _salaryPageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  alignment: Alignment.center,
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBankDetailsCard(data.account),
                  const SizedBox(height: 24),
                  _buildPastSalaryRecords(data.salaries),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(UserDetail detail) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text("Bank Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildBankInfoItem(Icons.person_outline_rounded, "Account Holder:", detail.user?.name ?? 'N/A'),
                _buildBankInfoItem(Icons.credit_card_rounded, "Account Number:", detail.bankAccountNumber ?? 'N/A'),
                _buildBankInfoItem(Icons.domain_rounded, "Bank Name:", detail.bankName ?? 'N/A'),
                _buildBankInfoItem(Icons.code_rounded, "IFSC Code:", detail.ifscCode ?? 'N/A'),
                _buildBankInfoItem(Icons.location_on_outlined, "Branch:", detail.branchName ?? 'N/A'),
                _buildBankInfoItem(Icons.payments_outlined, "Relationship Status:", detail.relationshipStatus ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastSalaryRecords(List<Salary> salaries) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF4C8C4A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.history_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text("Past Salary Records", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text("Month", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text("Net Salary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text("Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          if (salaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No salary records found", style: TextStyle(color: Colors.white38)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: salaries.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final salary = salaries[index];
                return _buildSalaryRow(salary);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(Salary salary) {
    bool isPaid = salary.status.toLowerCase() == 'paid';
    return InkWell(
      onTap: () => _showSalaryDetail(salary.id),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text("${salary.month} ${salary.year}", style: const TextStyle(color: Colors.white70, fontSize: 13))),
            Expanded(flex: 2, child: Text("₹ ${salary.amount}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                      salary.status.toUpperCase(),
                      style: TextStyle(
                        color: isPaid ? Colors.greenAccent : Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalaryDetail(dynamic salaryId) async {
    try {
      final data = await ApiService.getStaffSalarySlip(salaryId.toString());
      final detail = SalaryDetailData.fromJson(data);
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: cardColor,
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
                    backgroundColor: primaryColor,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
}
