import 'dart:convert';

import 'package:eduphin/manager_dashboard/feeStructure/studentFeeDetails/edit_fine.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_new_fine.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class StudentInfo {
  final String name;
  final String roll;
  final String classes;
  final String email;
  final String feeFrequency;

  StudentInfo({
    required this.name,
    required this.roll,
    required this.classes,
    required this.email,
    required this.feeFrequency,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      name: json['name'] ?? 'N/A',
      roll: json['student_roll_no'] ?? 'N/A',
      classes: '${json['class']?['name'] ?? ''}-${json['section']?['section_name'] ?? ''}',
      email: json['email'] ?? 'N/A',
      feeFrequency: json['fee_frequency'] ?? 'N/A', // Assuming this field exists
    );
  }
}

class FinancialSummary {
  final double totalFee;
  final double totalFine;
  final double totalPayable;
  final double paid;
  final double due;

  FinancialSummary({
    required this.totalFee,
    required this.totalFine,
    required this.totalPayable,
    required this.paid,
    required this.due,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalFee: double.tryParse(json['total_fees'].toString()) ?? 0.0,
      totalFine: double.tryParse(json['total_fines'].toString()) ?? 0.0,
      totalPayable: double.tryParse(json['total_payable'].toString()) ?? 0.0,
      paid: double.tryParse(json['total_paid'].toString()) ?? 0.0,
      due: double.tryParse(json['total_due'].toString()) ?? 0.0,
    );
  }
}

class FeeDetailItem {
  final String title;
  final double amount;
  final String type;
  final String details;

  FeeDetailItem({required this.title, required this.amount, required this.type, required this.details});

  factory FeeDetailItem.fromJson(Map<String, dynamic> json) {
    return FeeDetailItem(
      title: json['fees_type'] ?? 'N/A',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'N/A',
      details: json['description'] ?? 'No details available',
    );
  }
}

class FineDetailItem {
  final int id;
  final String title;
  final double amount;
  final String issuedBy;
  final String remark;

  FineDetailItem({required this.id, required this.title, required this.amount, required this.issuedBy, required this.remark});

  factory FineDetailItem.fromJson(Map<String, dynamic> json) {
    return FineDetailItem(
      id: json['id'] ?? 0,
      title: json['fine_type'] ?? 'N/A',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      issuedBy: '${json['issued_by']?['name'] ?? 'N/A'} on ${DateFormat('dd/MM/yyyy').format(DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now())}',
      remark: json['remarks'] ?? 'No remarks',
    );
  }
}

class PaymentHistoryItem {
  final double amount;
  final String date;
  final String mode;
  final String submittedBy;
  final String remark;

  PaymentHistoryItem({required this.amount, required this.date, required this.mode, required this.submittedBy, required this.remark});

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      amount: double.tryParse(json['paid_amount'].toString()) ?? 0.0,
      date: DateFormat('dd/MM/yyyy').format(DateTime.tryParse(json['payment_date'] ?? '') ?? DateTime.now()),
      mode: json['payment_mode'] ?? 'N/A',
      submittedBy: json['student']?['name'] ?? 'N/A', // Assuming student submits
      remark: json['remarks'] ?? 'No remarks',
    );
  }
}

class StudentFeeDetails {
  final StudentInfo studentInfo;
  final FinancialSummary financialSummary;
  final List<FeeDetailItem> feeDetails;
  final List<FineDetailItem> fineDetails;
  final List<PaymentHistoryItem> paymentHistory;

  StudentFeeDetails({
    required this.studentInfo,
    required this.financialSummary,
    required this.feeDetails,
    required this.fineDetails,
    required this.paymentHistory,
  });

  factory StudentFeeDetails.fromJson(Map<String, dynamic> json) {
    return StudentFeeDetails(
      studentInfo: StudentInfo.fromJson(json['student'] ?? {}),
      financialSummary: FinancialSummary.fromJson(json['summary'] ?? {}),
      feeDetails: (json['fees'] as List? ?? []).map((i) => FeeDetailItem.fromJson(i)).toList(),
      fineDetails: (json['fines'] as List? ?? []).map((i) => FineDetailItem.fromJson(i)).toList(),
      paymentHistory: (json['payments'] as List? ?? []).map((i) => PaymentHistoryItem.fromJson(i)).toList(),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         PAGE WIDGET
// ───────────────────────────────────────────────────────────

class FeeDetailsPage extends StatefulWidget {
  final int studentId;

  const FeeDetailsPage({super.key, required this.studentId});

  @override
  State<StatefulWidget> createState() => _FeeDetailsPageState();
}

class _FeeDetailsPageState extends State<FeeDetailsPage> {
  late Future<StudentFeeDetails> _feeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _feeDetailsFuture = _fetchFeeDetails();
  }

  Future<StudentFeeDetails> _fetchFeeDetails() async {
    final response = await ApiService.get('manager/fees/student/${widget.studentId}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentFeeDetails.fromJson(data);
    } else {
      throw Exception('Failed to load fee details');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: FutureBuilder<StudentFeeDetails>(
        future: _feeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                  child: constraints.maxWidth > 800
                      ? _buildWideLayout(data)
                      : _buildNarrowLayout(data),
                ),
              );
            });
          } else {
            return const Center(child: Text("No fee details available."));
          }
        },
      ),
    );
  }

  Widget _buildNarrowLayout(StudentFeeDetails data) {
    return Column(
      children: [
        CustomStudentInfoFeeDetailContainerBox(studentInfo: data.studentInfo),
        const SizedBox(height: 16),
        CustomFinancialSummaryFeeDetailContainerBox(summary: data.financialSummary),
        const SizedBox(height: 16),
        CustomFeeDetailsContainerBox(feeDetails: data.feeDetails),
        const SizedBox(height: 16),
        CustomFineDetailsContainerBox(studentId: widget.studentId, fineDetails: data.fineDetails),
        const SizedBox(height: 16),
        CustomPaymentHistoryContainerBox(paymentHistory: data.paymentHistory),
      ],
    );
  }

  Widget _buildWideLayout(StudentFeeDetails data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              CustomStudentInfoFeeDetailContainerBox(studentInfo: data.studentInfo),
              const SizedBox(height: 16),
              CustomFeeDetailsContainerBox(feeDetails: data.feeDetails),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CustomFinancialSummaryFeeDetailContainerBox(summary: data.financialSummary),
              const SizedBox(height: 16),
              CustomFineDetailsContainerBox(studentId: widget.studentId, fineDetails: data.fineDetails),
              const SizedBox(height: 16),
              CustomPaymentHistoryContainerBox(paymentHistory: data.paymentHistory),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────
//                      REUSABLE WIDGETS
// ───────────────────────────────────────────────────────────

class CustomStudentInfoFeeDetailContainerBox extends StatelessWidget {
  final StudentInfo studentInfo;

  const CustomStudentInfoFeeDetailContainerBox({super.key, required this.studentInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Student Info", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Name", studentInfo.name, "Roll No.", studentInfo.roll),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Class", studentInfo.classes, "Email", studentInfo.email, isEmail: true),
          const SizedBox(height: 8),
          Text("Fee Frequency", style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.6))),
          Text(studentInfo.feeFrequency, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label1, String value1, String label2, String value2, {bool isEmail = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.6))),
              Text(value1, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.6))),
              Text(value2, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary), overflow: isEmail ? TextOverflow.ellipsis : null),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomFinancialSummaryFeeDetailContainerBox extends StatelessWidget {
  final FinancialSummary summary;

  const CustomFinancialSummaryFeeDetailContainerBox({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Financial Summary", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          _buildSummaryRow(theme, "Total Fee", summary.totalFee),
          const SizedBox(height: 4),
          _buildSummaryRow(theme, "Total Fine", summary.totalFine),
          const Divider(),
          _buildSummaryRow(theme, "Total Payable", summary.totalPayable, isBold: true, color: theme.colorScheme.secondary),
          const Divider(),
          _buildSummaryRow(theme, "Paid", summary.paid, color: Colors.green),
          const SizedBox(height: 4),
          _buildSummaryRow(theme, "Due", summary.due, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, double amount, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text("₹${NumberFormat('#,##,##0.00').format(amount)}", style: theme.textTheme.bodyLarge?.copyWith(color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class CustomFeeDetailsContainerBox extends StatelessWidget {
  final List<FeeDetailItem> feeDetails;

  const CustomFeeDetailsContainerBox({super.key, required this.feeDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Fee Details", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 16),
          if (feeDetails.isEmpty)
            const Text("No fee details available.", style: TextStyle(color: Colors.white70))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feeDetails.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = feeDetails[index];
                return _buildFeeItem(theme, "${index + 1}. ${item.title}", item.amount, item.type, item.details, theme.colorScheme.secondary);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(ThemeData theme, String title, double amount, String type, String details, Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500))),
            Text("₹${NumberFormat('#,##,##0.00').format(amount)}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text("Type: ", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(type, style: theme.textTheme.bodySmall?.copyWith(color: typeColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(details, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
      ],
    );
  }
}

class CustomFineDetailsContainerBox extends StatelessWidget {
  final int studentId;
  final List<FineDetailItem> fineDetails;

  const CustomFineDetailsContainerBox({super.key, required this.studentId, required this.fineDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fine Details", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewFine(studentId: studentId)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add New Fine")),
            ],
          ),
          const SizedBox(height: 16),
          if (fineDetails.isEmpty)
            const Text("No fine details available.", style: TextStyle(color: Colors.white70))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fineDetails.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final item = fineDetails[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text("${index + 1}. ${item.title}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500))),
                        Text("₹${NumberFormat('#,##,##0.00').format(item.amount)}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("Issued by: ", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(5)),
                          child: Text(item.issuedBy, style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Remark: ${item.remark}", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
                    const Divider(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => EditFinePage(fineId: item.id, reason: item.title, amount: item.amount.toString(), remarks: item.remark)));
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Edit Fine"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                          foregroundColor: theme.colorScheme.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class CustomPaymentHistoryContainerBox extends StatelessWidget {
  final List<PaymentHistoryItem> paymentHistory;

  const CustomPaymentHistoryContainerBox({super.key, required this.paymentHistory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment History", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 16),
           if (paymentHistory.isEmpty)
            const Text("No payment history available.", style: TextStyle(color: Colors.white70))
          else
            ListView.separated(
               shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentHistory.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = paymentHistory[index];
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    _buildInfoRow(theme, "Payment Received", "₹${NumberFormat('#,##,##0.00').format(item.amount)}", valueColor: Colors.green),
                    const SizedBox(height: 8),
                    _buildInfoRow(theme, "Date", item.date),
                    const SizedBox(height: 8),
                    _buildInfoRow(theme, "Mode", item.mode),
                    const SizedBox(height: 8),
                    _buildInfoRow(theme, "Submitted by", item.submittedBy),
                    const SizedBox(height: 8),
                    _buildInfoRow(theme, "Remark", item.remark),
                   ],
                 );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.6))),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyLarge?.copyWith(color: valueColor ?? theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
