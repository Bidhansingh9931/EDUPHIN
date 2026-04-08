import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_fee_model.dart';
import 'package:flutter/material.dart';

class StudentFeePage extends StatefulWidget {
  const StudentFeePage({super.key});

  @override
  State<StudentFeePage> createState() => _StudentFeePageState();
}

class _StudentFeePageState extends State<StudentFeePage> {
  bool isLoading = true;
  String? errorMessage;
  StudentFeeData? feeData;

  @override
  void initState() {
    super.initState();
    _fetchFeeData();
  }

  Future<void> _fetchFeeData() async {
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
      
      // For now, we'll just show a success message.
      // In a real app, you might navigate to a PDF view or a receipt details page.
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xff3c4566),
            title: const Text("Receipt Generated", style: TextStyle(color: Colors.white)),
            content: Text(
              "Receipt for ₹${receipt['payment']['paid_amount']} fetched successfully.\n\nAmount in words: ${receipt['amount_in_words']}",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xff0a1230),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xff0a1230),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _fetchFeeData();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    final summary = feeData?.summary;

    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Student Fee Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFeeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// STUDENT INFO
              infoCard(),
        
              const SizedBox(height: 20),
        
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Fee Summary",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
        
              const SizedBox(height: 15),
        
              summaryGrid(summary),
        
              const SizedBox(height: 25),
        
              feeDetailsTable(),
        
              const SizedBox(height: 25),
        
              fineDetailsTable(),
        
              const SizedBox(height: 25),
        
              paymentHistoryTable(),
            ],
          ),
        ),
      ),
    );
  }

  /// STUDENT CARD
  Widget infoCard() {
    final s = feeData?.student;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name:  ${s?.firstName ?? ""} ${s?.lastName ?? ""}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          detailRow("Roll No", s?.studentRollNo),
          detailRow("Class", s?.classInfo?.name),
          detailRow("Email", s?.email),
          detailRow("Fee Frequency", s?.feeFrequency),
        ],
      ),
    );
  }

  Widget detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value ?? "N/A", style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  /// SUMMARY GRID
  Widget summaryGrid(FeeSummary? summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: summaryCard(Icons.payments, "Total Fee", "₹${summary?.totalFee ?? 0}")),
            const SizedBox(width: 15),
            Expanded(child: summaryCard(Icons.warning, "Total Fines", "₹${summary?.totalFine ?? 0}")),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: summaryCard(Icons.receipt, "Total Payable", "₹${summary?.totalPayable ?? 0}")),
            const SizedBox(width: 15),
            Expanded(child: summaryCard(Icons.check_circle, "Paid", "₹${summary?.totalPaid ?? 0}", color: Colors.green)),
          ],
        ),
        const SizedBox(height: 15),
        summaryCard(Icons.cancel, "Due", "₹${summary?.due ?? 0}", color: Colors.redAccent, wide: true),
      ],
    );
  }

  /// SUMMARY CARD
  Widget summaryCard(IconData icon, String title, String amount, {Color? color, bool wide = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// FEE DETAILS TABLE
  Widget feeDetailsTable() {
    final fees = feeData?.fees ?? [];
    final overrides = feeData?.overrides ?? {};

    return tableCard(
      "Fee Details",
      List.generate(fees.length, (index) {
        final fee = fees[index];
        final amount = overrides.containsKey(fee.id.toString())
            ? overrides[fee.id.toString()]!.overriddenAmount
            : fee.amount;
        return dataRow([
          (index + 1).toString(),
          fee.name,
          "₹$amount",
          fee.classId == null ? "Institute" : "Class"
        ]);
      }),
      const ["#", "Fee Title", "Amount", "Type"],
    );
  }

  /// FINE DETAILS TABLE
  Widget fineDetailsTable() {
    final fines = feeData?.fines ?? [];
    return tableCard(
      "Fine Details",
      List.generate(fines.length, (index) {
        final fine = fines[index];
        return dataRow([
          (index + 1).toString(),
          fine.reason,
          "₹${fine.amount}",
          fine.remarks ?? "-"
        ]);
      }),
      const ["#", "Reason", "Amount", "Remarks"],
    );
  }

  /// PAYMENT HISTORY
  Widget paymentHistoryTable() {
    final payments = feeData?.payments ?? [];
    return tableCard(
      "Payment History",
      List.generate(payments.length, (index) {
        final p = payments[index];
        return DataRow(cells: [
          DataCell(Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(Text("₹${p.paidAmount}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          DataCell(Text(p.date, style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(Text(p.paymentMethod, style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(Text(p.referenceNo ?? "-", style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(Text(p.remark ?? "-", style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(Text(p.submitter?.name ?? "-", style: const TextStyle(color: Colors.white, fontSize: 11))),
          DataCell(
            GestureDetector(
              onTap: () {
                if (p.idHash != null) {
                  _printReceipt(p.idHash!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Receipt ID not available")),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.print, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text("Receipt", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ]);
      }),
      const [
        "#",
        "Amount",
        "Date",
        "Mode",
        "Ref",
        "Remark",
        "By",
        "Action"
      ],
    );
  }

  /// TABLE CARD
  Widget tableCard(String title, List<DataRow> rows, List<String> columns) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
              rows: rows,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  DataRow dataRow(List<String> cells) {
    return DataRow(
      cells: cells.map((e) => DataCell(Text(e, style: const TextStyle(color: Colors.white, fontSize: 11)))).toList(),
    );
  }
}
