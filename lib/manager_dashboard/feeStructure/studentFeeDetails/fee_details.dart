import 'dart:ui';

import 'package:eduphin/manager_dashboard/feeStructure/studentFeeDetails/edit_fine.dart';
import 'package:flutter/material.dart';

import 'add_new_fine.dart';

class FeeDetailsPage extends StatefulWidget {
  const FeeDetailsPage({super.key, required String studentName, required String studentDetails});

  @override
  State<StatefulWidget> createState() => _FeeDetailsPageState();
}

class _FeeDetailsPageState extends State<FeeDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomStudentInfoFeeDetailContainerBox(
                heading: "Student Info",
                name: "Ananya Sharma",
                roll: "S-1024",
                classes: "10-A",
                email: "ananya.s@school.com",
                feeFrequency: "Monthly",
              ),
              SizedBox(
                height: 16,
              ),
              CustomFinancialSummaryFeeDetailContainerBox(
                  heading: "Financial Summary",
                  totalFee: 15000,
                  totalFine: 200,
                  totalPayable: 15200,
                  paid: 10000,
                  due: 5200),
              SizedBox(
                height: 16,
              ),
              CustomFeeDetailsContainerBox(
                heading: "Fee Details",
                tuitionFee: 12000,
                tType: "Institute-Wide",
                tDetails: "Monthly tuition fee for academic session",
                labFee: 3000,
                lType: "Class-Specific",
                lDetails: "For science lab equipment and materials",
              ),
              SizedBox(height: 16,),
              CustomFineDetailsContainerBox(
                heading: "Fine Details",
                lateFeePayment: 200,
                issued: "Mr.Sharma on 15/05/2024",
                remark: "Fee paid after due date",
              ),
              SizedBox(height: 16,),
              CustomPaymentHistoryContainerBox(
                heading: "Payment History",
                paymentReceived: 10000,
                date: "20/05/2024",
                mode: "UPI (Ref: 1234567890)",
                submittedBy: "Ananya Sharma",
                remark: "Partial fee payment",
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomStudentInfoFeeDetailContainerBox extends StatefulWidget {
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
  State<CustomStudentInfoFeeDetailContainerBox> createState() =>
      _CustomStudentInfoFeeDetailContainerBoxState();
}

class _CustomStudentInfoFeeDetailContainerBoxState
    extends State<CustomStudentInfoFeeDetailContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.heading,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary, fontSize: 20)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary.withAlpha(100),
                              fontSize: 16)),
                      Text(widget.name,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Roll No.",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary.withAlpha(100),
                              fontSize: 16)),
                      Text(widget.roll,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Class",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary.withAlpha(100),
                              fontSize: 16)),
                      Text(widget.classes,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary.withAlpha(100),
                              fontSize: 16)),
                      Text(widget.email,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Fee Frequency",
                style: TextStyle(
                    color: theme.colorScheme.onPrimary.withAlpha(100),
                    fontSize: 16)),
            Text(widget.feeFrequency,
                style:
                    TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class CustomFinancialSummaryFeeDetailContainerBox extends StatefulWidget {
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
  State<CustomFinancialSummaryFeeDetailContainerBox> createState() =>
      _CustomFinancialSummaryFeeDetailContainerBoxState();
}

class _CustomFinancialSummaryFeeDetailContainerBoxState
    extends State<CustomFinancialSummaryFeeDetailContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.heading,
              style: TextStyle(
                  color: theme.colorScheme.onPrimary, fontSize: 20),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Fee", style: TextStyle(fontSize: 16)),
                Text("₹${widget.totalFee}",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Fine", style: TextStyle(fontSize: 16)),
                Text("₹${widget.totalFine}",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("₹${widget.totalPayable}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Paid",
                    style: TextStyle(fontSize: 16, color: Colors.green)),
                Text("₹${widget.paid}",
                    style: const TextStyle(fontSize: 16, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Due",
                    style: TextStyle(fontSize: 16, color: Colors.red)),
                Text("₹${widget.due}",
                    style: const TextStyle(fontSize: 16, color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFeeDetailsContainerBox extends StatefulWidget {
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
  State<CustomFeeDetailsContainerBox> createState() =>
      _CustomFeeDetailsContainerBoxState();
}

class _CustomFeeDetailsContainerBoxState
    extends State<CustomFeeDetailsContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.heading,
              style: TextStyle(
                  color: theme.colorScheme.onPrimary, fontSize: 20),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("1. Tuition Fee",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("₹${widget.tuitionFee}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Type: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.tType,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.tDetails,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("2. Lab Fee",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("₹${widget.labFee}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Type: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.lType,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.lDetails,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFineDetailsContainerBox extends StatefulWidget {
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
  State<CustomFineDetailsContainerBox> createState() =>
      _CustomFineDetailsContainerBoxState();
}

class _CustomFineDetailsContainerBoxState
    extends State<CustomFineDetailsContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.heading,
                  style: TextStyle(
                      color: theme.colorScheme.onPrimary, fontSize: 20),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewFine()));
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                  children: [
                    Icon(Icons.add,color: Colors.white,),
                    SizedBox(width: 4,),
                    Text("Add New Fine",style: TextStyle(color: Colors.white),)
                  ],
                )),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("1. Late Fee Payment",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("₹${widget.lateFeePayment}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Issued by: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.issued,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Remark: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                
                Text(
                  widget.remark,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),

              ],
            ),
            const SizedBox(height: 16,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditFinePage()));
                  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withAlpha(75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Edit",style: TextStyle(color: Colors.blue,fontSize: 16),)),
                ),
                const SizedBox(width: 16,),
                Expanded(
                  child: ElevatedButton(onPressed: (){
                    showDeleteDialog(context);
                  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomPaymentHistoryContainerBox extends StatefulWidget {
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
  State<CustomPaymentHistoryContainerBox> createState() =>
      _CustomPaymentHistoryContainerBoxState();
}

class _CustomPaymentHistoryContainerBoxState
    extends State<CustomPaymentHistoryContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.heading,
              style: TextStyle(
                  color: theme.colorScheme.onPrimary, fontSize: 20),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("1. Payment Received",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text("₹${widget.paymentReceived}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Date: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.date,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Mode: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                Text(
                  widget.mode,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),

              ],
            ),
            const SizedBox(height: 8,),
            Row(
              children: [
                const Text("Submitted By: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                Text(
                  widget.submittedBy,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Remark: ",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

                Expanded(
                  child: Text(
                    widget.remark,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showDeleteDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return const DeleteManagerDialog(
        managerName: "Rajeev K.Malhotra",
      );
    },
  );
}
class DeleteManagerDialog extends StatelessWidget {
  final String managerName;

  const DeleteManagerDialog({
    super.key,
    required this.managerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete this event? "
                        "This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // 🔥 delete logic here
                      },
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}