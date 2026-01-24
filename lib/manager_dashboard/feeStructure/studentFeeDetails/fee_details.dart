// import 'dart:ui';

import 'package:eduphin/manager_dashboard/feeStructure/studentFeeDetails/edit_fine.dart';
import 'package:flutter/material.dart';

import 'add_new_fine.dart';

class FeeDetailsPage extends StatefulWidget {
  final String studentName;
  final String studentDetails;

  const FeeDetailsPage(
      {super.key, required this.studentName, required this.studentDetails});

  @override
  State<StatefulWidget> createState() => _FeeDetailsPageState();
}

class _FeeDetailsPageState extends State<FeeDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Data is hardcoded as per the original file, but uses widget.studentName
    final studentInfo = {
      'name': widget.studentName,
      'roll': 'S-1024',
      'classes': '10-A',
      'email': 'ananya.s@school.com',
      'feeFrequency': 'Monthly',
    };

    final financialSummary = {
      'totalFee': 15000.0,
      'totalFine': 200.0,
      'totalPayable': 15200.0,
      'paid': 10000.0,
      'due': 5200.0,
    };

    final feeDetails = {
      'tuitionFee': 12000.0,
      'tType': 'Institute-Wide',
      'tDetails': 'Monthly tuition fee for academic session',
      'labFee': 3000.0,
      'lType': 'Class-Specific',
      'lDetails': 'For science lab equipment and materials',
    };

    final fineDetails = {
      'lateFeePayment': 200.0,
      'issued': 'Mr.Sharma on 15/05/2024',
      'remark': 'Fee paid after due date',
    };

    final paymentHistory = {
      'paymentReceived': 10000.0,
      'date': '20/05/2024',
      'mode': 'UPI (Ref: 1234567890)',
      'submittedBy': 'Ananya Sharma',
      'remark': 'Partial fee payment',
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            child: constraints.maxWidth > 800
                ? _buildWideLayout(
                    studentInfo, financialSummary, feeDetails, fineDetails, paymentHistory)
                : _buildNarrowLayout(
                    studentInfo, financialSummary, feeDetails, fineDetails, paymentHistory),
          ),
        );
      }),
    );
  }

  Widget _buildNarrowLayout(Map studentInfo, Map financialSummary, Map feeDetails, Map fineDetails, Map paymentHistory) {
    return Column(
      children: [
        CustomStudentInfoFeeDetailContainerBox(
          heading: "Student Info",
          name: studentInfo['name'],
          roll: studentInfo['roll'],
          classes: studentInfo['classes'],
          email: studentInfo['email'],
          feeFrequency: studentInfo['feeFrequency'],
        ),
        const SizedBox(height: 16),
        CustomFinancialSummaryFeeDetailContainerBox(
          heading: "Financial Summary",
          totalFee: financialSummary['totalFee'],
          totalFine: financialSummary['totalFine'],
          totalPayable: financialSummary['totalPayable'],
          paid: financialSummary['paid'],
          due: financialSummary['due'],
        ),
        const SizedBox(height: 16),
        CustomFeeDetailsContainerBox(
          heading: "Fee Details",
          tuitionFee: feeDetails['tuitionFee'],
          tType: feeDetails['tType'],
          tDetails: feeDetails['tDetails'],
          labFee: feeDetails['labFee'],
          lType: feeDetails['lType'],
          lDetails: feeDetails['lDetails'],
        ),
        const SizedBox(height: 16),
        CustomFineDetailsContainerBox(
          heading: "Fine Details",
          lateFeePayment: fineDetails['lateFeePayment'],
          issued: fineDetails['issued'],
          remark: fineDetails['remark'],
        ),
        const SizedBox(height: 16),
        CustomPaymentHistoryContainerBox(
          heading: "Payment History",
          paymentReceived: paymentHistory['paymentReceived'],
          date: paymentHistory['date'],
          mode: paymentHistory['mode'],
          submittedBy: paymentHistory['submittedBy'],
          remark: paymentHistory['remark'],
        )
      ],
    );
  }

  Widget _buildWideLayout(Map studentInfo, Map financialSummary, Map feeDetails, Map fineDetails, Map paymentHistory) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              CustomStudentInfoFeeDetailContainerBox(
                heading: "Student Info",
                name: studentInfo['name'],
                roll: studentInfo['roll'],
                classes: studentInfo['classes'],
                email: studentInfo['email'],
                feeFrequency: studentInfo['feeFrequency'],
              ),
              const SizedBox(height: 16),
              CustomFeeDetailsContainerBox(
                heading: "Fee Details",
                tuitionFee: feeDetails['tuitionFee'],
                tType: feeDetails['tType'],
                tDetails: feeDetails['tDetails'],
                labFee: feeDetails['labFee'],
                lType: feeDetails['lType'],
                lDetails: feeDetails['lDetails'],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              CustomFinancialSummaryFeeDetailContainerBox(
                heading: "Financial Summary",
                totalFee: financialSummary['totalFee'],
                totalFine: financialSummary['totalFine'],
                totalPayable: financialSummary['totalPayable'],
                paid: financialSummary['paid'],
                due: financialSummary['due'],
              ),
              const SizedBox(height: 16),
              CustomFineDetailsContainerBox(
                heading: "Fine Details",
                lateFeePayment: fineDetails['lateFeePayment'],
                issued: fineDetails['issued'],
                remark: fineDetails['remark'],
              ),
              const SizedBox(height: 16),
              CustomPaymentHistoryContainerBox(
                heading: "Payment History",
                paymentReceived: paymentHistory['paymentReceived'],
                date: paymentHistory['date'],
                mode: paymentHistory['mode'],
                submittedBy: paymentHistory['submittedBy'],
                remark: paymentHistory['remark'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomStudentInfoFeeDetailContainerBox extends StatelessWidget {
  final String heading;
  final String name;
  final String roll;
  final String classes;
  final String email;
  final String feeFrequency;

  const CustomStudentInfoFeeDetailContainerBox({
    super.key,
    required this.heading,
    required this.name,
    required this.roll,
    required this.classes,
    required this.email,
    required this.feeFrequency,
  });

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
          Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Name", name, "Roll No.", roll),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Class", classes, "Email", email, isEmail: true),
          const SizedBox(height: 8),
          Text("Fee Frequency",
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
          Text(feeFrequency, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
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
              Text(label1, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
              Text(value1, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
              Text(value2, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary), overflow: isEmail ? TextOverflow.ellipsis : null),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomFinancialSummaryFeeDetailContainerBox extends StatelessWidget {
  final String heading;
  final double totalFee;
  final double totalFine;
  final double totalPayable;
  final double paid;
  final double due;

  const CustomFinancialSummaryFeeDetailContainerBox({
    super.key,
    required this.heading,
    required this.totalFee,
    required this.totalFine,
    required this.totalPayable,
    required this.paid,
    required this.due,
  });

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
          Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          _buildSummaryRow(theme, "Total Fee", totalFee),
          const SizedBox(height: 4),
          _buildSummaryRow(theme, "Total Fine", totalFine),
          const Divider(),
          _buildSummaryRow(theme, "Total Payable", totalPayable, isBold: true, color: theme.colorScheme.secondary),
          const Divider(),
          _buildSummaryRow(theme, "Paid", paid, color: Colors.green),
          const SizedBox(height: 4),
          _buildSummaryRow(theme, "Due", due, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, double amount, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text("₹$amount", style: theme.textTheme.bodyLarge?.copyWith(color: color ?? theme.colorScheme.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class CustomFeeDetailsContainerBox extends StatelessWidget {
  final String heading;
  final double tuitionFee;
  final String tType;
  final String tDetails;
  final double labFee;
  final String lType;
  final String lDetails;

  const CustomFeeDetailsContainerBox({
    super.key,
    required this.heading,
    required this.tuitionFee,
    required this.tType,
    required this.tDetails,
    required this.labFee,
    required this.lType,
    required this.lDetails,
  });

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
          Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 16),
          _buildFeeItem(theme, "1. Tuition Fee", tuitionFee, tType, tDetails, theme.colorScheme.secondary),
          const Divider(height: 24),
          _buildFeeItem(theme, "2. Lab Fee", labFee, lType, lDetails, Colors.orange),
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
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
            Text("₹$amount", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text("Type: ", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(35),
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
  final String heading;
  final double lateFeePayment;
  final String issued;
  final String remark;

  const CustomFineDetailsContainerBox({
    super.key,
    required this.heading,
    required this.lateFeePayment,
    required this.issued,
    required this.remark,
  });

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
              Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewFine()));
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1. Late Fee Payment", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              Text("₹$lateFeePayment", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Issued by: ", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(issued, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Remark: $remark", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
          const Divider(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditFinePage()));
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit Fine"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary.withAlpha(35),
                foregroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPaymentHistoryContainerBox extends StatelessWidget {
  final String heading;
  final double paymentReceived;
  final String date;
  final String mode;
  final String submittedBy;
  final String remark;

  const CustomPaymentHistoryContainerBox({
    super.key,
    required this.heading,
    required this.paymentReceived,
    required this.date,
    required this.mode,
    required this.submittedBy,
    required this.remark,
  });

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
          Text(heading, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow(theme, "Payment Received", "₹$paymentReceived", valueColor: Colors.green),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Date", date),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Mode", mode),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Submitted by", submittedBy),
          const SizedBox(height: 8),
          _buildInfoRow(theme, "Remark", remark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(35))),
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
