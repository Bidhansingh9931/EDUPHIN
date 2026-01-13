import 'dart:ui';
import 'package:eduphin/manager_dashboard/feeStructure/fee_Structure/create_new_fee.dart';
import 'package:flutter/material.dart';

import 'edit_fee.dart';

class FeeStructurePage extends StatefulWidget {
  const FeeStructurePage({super.key});

  @override
  State<FeeStructurePage> createState() => _FeeStructurePageState();
}

class _FeeStructurePageState extends State<FeeStructurePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateNewFeePage()));
            },
            backgroundColor: Colors.blue.shade900,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add,),
                SizedBox(
                  width: 5,
                ),
                Text("Create New Fee",style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Fee Structure"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Institute - Wide Fee",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 16,
              ),
              CustomInstituteContainerBox(
                title: "Annual Tuition Fee",
                mandatoryOrOptional: "Mandatory",
                detail: "Standard annual fee for all academic programs",
                amount: 75000,
              ),
              SizedBox(
                height: 16,
              ),
              CustomInstituteContainerBox(
                  title: "Sports Facility Fee",
                  mandatoryOrOptional: "Optional",
                  detail: "Standard annual fee for all academic programs",
                  amount: 3000),
              SizedBox(
                height: 16,
              ),
              Text(
                "Class Specific Fee",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 16,
              ),
              CustomSpecificContainerBox(
                  heading: "Class: 10th Grade",
                  subHeading: "Lab Fee",
                  isOptional: "Mandatory",
                  details: "Mandatory for all science stream students in 10th grade.",
                  fee: 4000
              ),
              SizedBox(
                height: 16,
              ),
              CustomSpecificContainerBox(heading: "Class: 5th Grade",
                  subHeading: "Art Supplies Fee",
                  isOptional: "Optional",
                  details: "Provides all necessary art supplies for the year long art class.",
                  fee: 4000),
              SizedBox(
                height: 16,
              ),

            ],
          ),
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
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
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
                    "Are you sure you want to delete this section "
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

class CustomInstituteContainerBox extends StatefulWidget {
  final String title;
  final String mandatoryOrOptional;
  final int amount;
  final String detail;

  const CustomInstituteContainerBox({
    super.key,
    required this.title,
    required this.mandatoryOrOptional,
    required this.detail,
    required this.amount,
  });

  @override
  State<CustomInstituteContainerBox> createState() => _CustomInstituteContainerBoxState();
}

class _CustomInstituteContainerBoxState extends State<CustomInstituteContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMandatory = widget.mandatoryOrOptional == "Mandatory";

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
                Text(widget.title,
                    style:
                        TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
                Container(
                    decoration: BoxDecoration(
                      color: isMandatory
                          ? Colors.grey.withAlpha(25)
                          : Colors.blue.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.mandatoryOrOptional,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ))
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 16,
                  color: Colors.blue,
                ),
                Text(widget.amount.toString(),
                    style: const TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.detail,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EditFeePage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withAlpha(45)),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Edit",
                            style: TextStyle(color: Colors.blue, fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => showDeleteDialog(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(45)),
                    child: const Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class CustomSpecificContainerBox extends StatefulWidget {
  final String heading;
  final String subHeading;
  final String isOptional;
  final int fee;
  final String details;

  const CustomSpecificContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.isOptional,
    required this.details,
    required this.fee,
  });

  @override
  State<CustomSpecificContainerBox> createState() => _CustomSpecificContainerBoxState();
}

class _CustomSpecificContainerBoxState extends State<CustomSpecificContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMandatory = widget.isOptional == "Mandatory";

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
                Text(widget.heading,
                    style:
                    TextStyle(color: theme.colorScheme.onPrimary.withAlpha(150), fontSize: 14)),
                Container(
                    decoration: BoxDecoration(
                      color: isMandatory
                          ? Colors.grey.withAlpha(25)
                          : Colors.blue.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.isOptional,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ))
              ],
            ),
            Text(widget.subHeading,
                style:
                TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
            SizedBox(height: 5,),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 16,
                  color: Colors.blue,
                ),
                Text(widget.fee.toString(),
                    style: const TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.details,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EditFeePage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withAlpha(45)),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Edit",
                            style: TextStyle(color: Colors.blue, fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => showDeleteDialog(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(45)),
                    child: const Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
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

