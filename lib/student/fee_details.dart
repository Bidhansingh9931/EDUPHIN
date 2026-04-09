import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_fee_model.dart';
import 'package:flutter/material.dart';

class StudentFeePage extends StatefulWidget {
  const StudentFeePage({super.key});

  @override
  State<StudentFeePage> createState() => _StudentFeePageState();
}

class _StudentFeePageState extends State<StudentFeePage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

  bool isLoading = true;
  String? errorMessage;
  StudentFeeData? feeData;

  @override
  void initState() {
    super.initState();
    _fetchFeeData();
  }

  Future<void> _fetchFeeData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getStudentFees();
      setState(() {
        feeData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _printReceipt(String idHash) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fetching receipt details...")),
      );
      final receipt = await ApiService.getStudentFeeReceipt(idHash);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Receipt Generated", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Receipt for ₹${receipt['payment']['paid_amount']} fetched successfully.",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  "Amount in words: ${receipt['amount_in_words']}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CLOSE", style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching receipt: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fee Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _fetchFeeData,
                  color: _primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// STUDENT INFO
                        _buildStudentInfoCard(),

                        const SizedBox(height: 32),

                        const Text(
                          "Fee Summary",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryGrid(feeData?.summary),

                        const SizedBox(height: 32),

                        _buildSectionHeader("Payment History", Icons.history),
                        const SizedBox(height: 16),
                        _buildPaymentHistoryList(),

                        const SizedBox(height: 32),

                        _buildSectionHeader("Fee Structure", Icons.account_balance_wallet_outlined),
                        const SizedBox(height: 16),
                        _buildFeeStructureTable(),

                        const SizedBox(height: 32),

                        if (feeData?.fines?.isNotEmpty ?? false) ...[
                          _buildSectionHeader("Fine Details", Icons.warning_amber_rounded),
                          const SizedBox(height: 16),
                          _buildFineDetailsTable(),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              onPressed: _fetchFeeData,
              child: const Text("Retry Connection"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStudentInfoCard() {
    final s = feeData?.student;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_card, _card.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: _primary.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: _primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${s?.firstName ?? ""} ${s?.lastName ?? ""}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Roll No: ${s?.studentRollNo ?? "N/A"}",
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white12, height: 1),
          ),
          _infoRow(Icons.class_outlined, "Class", s?.classInfo?.name ?? "N/A"),
          const SizedBox(height: 12),
          _infoRow(Icons.email_outlined, "Email", s?.email ?? "N/A"),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today_outlined, "Frequency", s?.feeFrequency ?? "N/A"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildSummaryGrid(FeeSummary? summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _summaryCard("Total Fee", "₹${summary?.totalFee ?? 0}", Icons.account_balance, _primary)),
            const SizedBox(width: 16),
            Expanded(child: _summaryCard("Fines", "₹${summary?.totalFine ?? 0}", Icons.gavel, Colors.orangeAccent)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _summaryCard("Paid", "₹${summary?.totalPaid ?? 0}", Icons.check_circle_outline, Colors.greenAccent)),
            const SizedBox(width: 16),
            Expanded(child: _summaryCard("Due Amount", "₹${summary?.due ?? 0}", Icons.pending_actions, Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeeStructureTable() {
    final fees = feeData?.fees ?? [];
    final overrides = feeData?.overrides ?? {};

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildTableHeader(["#", "FEE TITLE", "AMOUNT", "TYPE"]),
          ...List.generate(fees.length, (index) {
            final fee = fees[index];
            final amount = overrides.containsKey(fee.id.toString()) ? overrides[fee.id.toString()]!.overriddenAmount : fee.amount;
            return _buildTableRow([
              (index + 1).toString(),
              fee.name,
              "₹$amount",
              fee.classId == null ? "Inst." : "Class"
            ], isLast: index == fees.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildFineDetailsTable() {
    final fines = feeData?.fines ?? [];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildTableHeader(["#", "REASON", "AMOUNT", "REMARKS"]),
          ...List.generate(fines.length, (index) {
            final fine = fines[index];
            return _buildTableRow([
              (index + 1).toString(),
              fine.reason,
              "₹${fine.amount}",
              fine.remarks ?? "-"
            ], isLast: index == fines.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryList() {
    final payments = feeData?.payments ?? [];
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
        child: const Center(child: Text("No payment history found", style: TextStyle(color: Colors.white38))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final p = payments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text("₹${p.paidAmount}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  _buildStatusBadge(p.paymentMethod.toUpperCase(), _primary),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white10, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ref: ${p.referenceNo ?? "-"}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Text("By: ${p.submitter?.name ?? "-"}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                        foregroundColor: Colors.greenAccent,
                        elevation: 0,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.greenAccent, width: 0.5),
                        ),
                      ),
                      onPressed: () {
                        if (p.idHash != null) _printReceipt(p.idHash!);
                      },
                      icon: const Icon(Icons.receipt_long, size: 14),
                      label: const Text("RECEIPT",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(List<String> labels) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: labels.map((label) {
          int flex = (label == "#" || label == "TYPE" || label == "AMOUNT") ? 1 : 2;
          return Expanded(
            flex: flex,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> values, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: values.asMap().entries.map((entry) {
          int flex = (entry.key == 0 || entry.key == 3 || entry.key == 2) ? 1 : 2;
          return Expanded(
            flex: flex,
            child: Text(
              entry.value,
              style: TextStyle(
                color: entry.key == 2 ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: entry.key == 2 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
