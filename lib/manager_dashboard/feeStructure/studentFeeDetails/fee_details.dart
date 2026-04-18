import 'dart:convert';

import 'package:eduphin/manager_dashboard/feeStructure/studentFeeDetails/edit_fine.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
      throw Exception(ApiService.errorMessage(response, 'Failed to load fee details'));
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Student Fee Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<StudentFeeDetails>(
        future: _feeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          } else if (snapshot.hasError) {
            String errorMsg = snapshot.error.toString().replaceFirst('Exception: ', '');
            return Center(child: Padding(
              padding: context.pagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorMsg, 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                  SizedBox(height: context.md),
                  FilledButton.icon(
                    onPressed: () => setState(() {
                      _feeDetailsFuture = _fetchFeeDetails();
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  )
                ],
              ),
            ));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: context.responsive(
                    _buildNarrowLayout(data),
                    tablet: _buildWideLayout(data),
                    desktop: _buildWideLayout(data),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text("No fee details available.", style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)));
          }
        },
      ),
    );
  }

  Widget _buildNarrowLayout(StudentFeeDetails data) {
    return Column(
      children: [
        CustomStudentInfoFeeDetailContainerBox(studentInfo: data.studentInfo),
        SizedBox(height: context.spacing),
        CustomFinancialSummaryFeeDetailContainerBox(summary: data.financialSummary),
        SizedBox(height: context.spacing),
        CustomFeeDetailsContainerBox(feeDetails: data.feeDetails),
        SizedBox(height: context.spacing),
        CustomFineDetailsContainerBox(studentId: widget.studentId, fineDetails: data.fineDetails),
        SizedBox(height: context.spacing),
        CustomPaymentHistoryContainerBox(paymentHistory: data.paymentHistory),
        SizedBox(height: context.scale(50)),
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
              SizedBox(height: context.spacing),
              CustomFeeDetailsContainerBox(feeDetails: data.feeDetails),
              SizedBox(height: context.scale(50)),
            ],
          ),
        ),
        SizedBox(width: context.spacing),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CustomFinancialSummaryFeeDetailContainerBox(summary: data.financialSummary),
              SizedBox(height: context.spacing),
              CustomFineDetailsContainerBox(studentId: widget.studentId, fineDetails: data.fineDetails),
              SizedBox(height: context.spacing),
              CustomPaymentHistoryContainerBox(paymentHistory: data.paymentHistory),
              SizedBox(height: context.scale(50)),
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
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student Info", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            SizedBox(height: context.scale(12)),
            _buildInfoRow(context, "Name", studentInfo.name, "Roll No.", studentInfo.roll),
            SizedBox(height: context.scale(12)),
            _buildInfoRow(context, "Class", studentInfo.classes, "Email", studentInfo.email, isEmail: true),
            SizedBox(height: context.scale(12)),
            Text("Fee Frequency", style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            Text(studentInfo.feeFrequency, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label1, String value1, String label2, String value2, {bool isEmail = false}) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label1, style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
              Text(value1, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
        SizedBox(width: context.scale(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
              Text(value2, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), overflow: isEmail ? TextOverflow.ellipsis : null),
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
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Financial Summary", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            SizedBox(height: context.scale(12)),
            _buildSummaryRow(context, "Total Fee", summary.totalFee),
            SizedBox(height: context.scale(4)),
            _buildSummaryRow(context, "Total Fine", summary.totalFine),
            Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
            _buildSummaryRow(context, "Total Payable", summary.totalPayable, isBold: true, color: theme.colorScheme.secondary),
            Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
            _buildSummaryRow(context, "Paid", summary.paid, color: Colors.green, isBold: true),
            SizedBox(height: context.scale(4)),
            _buildSummaryRow(context, "Due", summary.due, color: theme.colorScheme.error, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount, {Color? color, bool isBold = false}) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: context.font(14), color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text("₹${NumberFormat('#,##,##0.00').format(amount)}", style: TextStyle(fontSize: context.font(14), color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class CustomFeeDetailsContainerBox extends StatelessWidget {
  final List<FeeDetailItem> feeDetails;

  const CustomFeeDetailsContainerBox({super.key, required this.feeDetails});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fee Details", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            SizedBox(height: context.scale(16)),
            if (feeDetails.isEmpty)
              Text("No fee details available.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: feeDetails.length,
                separatorBuilder: (context, index) => Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
                itemBuilder: (context, index) {
                  final item = feeDetails[index];
                  return _buildFeeItem(context, "${index + 1}. ${item.title}", item.amount, item.type, item.details, theme.colorScheme.secondary);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(BuildContext context, String title, double amount, String type, String details, Color typeColor) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(title, style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface))),
            Text("₹${NumberFormat('#,##,##0.00').format(amount)}", style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          ],
        ),
        SizedBox(height: context.scale(8)),
        Row(
          children: [
            Text("Type: ", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(6)),
              ),
              child: Text(type, style: TextStyle(fontSize: context.font(11), color: typeColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: context.scale(8)),
        Text(details, style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant)),
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
    final theme = context.theme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Fine Details", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewFine(studentId: studentId)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                    padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                  ),
                  icon: Icon(Icons.add, size: context.scale(16)),
                  label: Text("Add Fine", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: context.scale(16)),
            if (fineDetails.isEmpty)
              Text("No fine details available.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fineDetails.length,
                separatorBuilder: (context, index) => SizedBox(height: context.scale(24)),
                itemBuilder: (context, index) {
                  final item = fineDetails[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text("${index + 1}. ${item.title}", style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface))),
                          Text("₹${NumberFormat('#,##,##0.00').format(item.amount)}", style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        ],
                      ),
                      SizedBox(height: context.scale(8)),
                      Row(
                        children: [
                          Text("Issued by: ", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(context.scale(6))),
                            child: Text(item.issuedBy, style: TextStyle(fontSize: context.font(11), color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(8)),
                      Text("Remark: ${item.remark}", style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant)),
                      Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditFinePage(fineId: item.id, reason: item.title, amount: item.amount.toString(), remarks: item.remark)));
                          },
                          icon: Icon(Icons.edit, size: context.scale(16)),
                          label: Text("Edit Fine", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            foregroundColor: theme.colorScheme.secondary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class CustomPaymentHistoryContainerBox extends StatelessWidget {
  final List<PaymentHistoryItem> paymentHistory;

  const CustomPaymentHistoryContainerBox({super.key, required this.paymentHistory});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment History", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            SizedBox(height: context.scale(16)),
            if (paymentHistory.isEmpty)
              Text("No payment history available.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paymentHistory.length,
                separatorBuilder: (context, index) => Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
                itemBuilder: (context, index) {
                  final item = paymentHistory[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, "Payment Received", "₹${NumberFormat('#,##,##0.00').format(item.amount)}", valueColor: Colors.green),
                      SizedBox(height: context.scale(8)),
                      _buildInfoRow(context, "Date", item.date),
                      SizedBox(height: context.scale(8)),
                      _buildInfoRow(context, "Mode", item.mode),
                      SizedBox(height: context.scale(8)),
                      _buildInfoRow(context, "Submitted by", item.submittedBy),
                      SizedBox(height: context.scale(8)),
                      _buildInfoRow(context, "Remark", item.remark),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        SizedBox(width: context.scale(16)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: context.font(14), color: valueColor ?? theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
