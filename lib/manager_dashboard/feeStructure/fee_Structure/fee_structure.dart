import 'dart:ui';
import 'package:eduphin/manager_dashboard/feeStructure/fee_Structure/create_new_fee.dart';
import 'package:flutter/material.dart';

import 'edit_fee.dart';

class InstituteFee {
  final String title;
  final String mandatoryOrOptional;
  final String detail;
  final int amount;

  InstituteFee({
    required this.title,
    required this.mandatoryOrOptional,
    required this.detail,
    required this.amount,
  });
}

class ClassFee {
  final String heading;
  final String subHeading;
  final String isOptional;
  final String details;
  final int fee;

  ClassFee({
    required this.heading,
    required this.subHeading,
    required this.isOptional,
    required this.details,
    required this.fee,
  });
}

class FeeStructurePage extends StatefulWidget {
  const FeeStructurePage({super.key});

  @override
  State<FeeStructurePage> createState() => _FeeStructurePageState();
}

class _FeeStructurePageState extends State<FeeStructurePage> {
  bool _isLoading = true;
  List<InstituteFee> _instituteFees = [];
  List<ClassFee> _classFees = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final instituteFeesData = [
      InstituteFee(
        title: "Annual Tuition Fee",
        mandatoryOrOptional: "Mandatory",
        detail: "Standard annual fee for all academic programs",
        amount: 75000,
      ),
      InstituteFee(
          title: "Sports Facility Fee",
          mandatoryOrOptional: "Optional",
          detail: "Standard annual fee for all academic programs",
          amount: 3000),
    ];

    final classFeesData = [
      ClassFee(
          heading: "Class: 10th Grade",
          subHeading: "Lab Fee",
          isOptional: "Mandatory",
          details: "Mandatory for all science stream students in 10th grade.",
          fee: 4000),
      ClassFee(
          heading: "Class: 5th Grade",
          subHeading: "Art Supplies Fee",
          isOptional: "Optional",
          details:
              "Provides all necessary art supplies for the year long art class.",
          fee: 4000),
    ];

    setState(() {
      _instituteFees = instituteFeesData;
      _classFees = classFeesData;
      _isLoading = false;
    });
  }

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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateNewFeePage()));
            },
            backgroundColor: Colors.blue.shade900,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Create New Fee",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Fee Structure"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Institute - Wide Fee",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _instituteFees.length,
                      itemBuilder: (context, index) {
                        final fee = _instituteFees[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CustomInstituteContainerBox(
                            title: fee.title,
                            mandatoryOrOptional: fee.mandatoryOrOptional,
                            detail: fee.detail,
                            amount: fee.amount,
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditFeePage(
                                    feeName: fee.title,
                                    amount: fee.amount.toString(),
                                    description: fee.detail,
                                    applyTo: "institute",
                                    isOptional:
                                        fee.mandatoryOrOptional == "Optional",
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  _instituteFees[index] = InstituteFee(
                                    title: result['feeName'],
                                    mandatoryOrOptional: result['isOptional']
                                        ? "Optional"
                                        : "Mandatory",
                                    detail: result['description'],
                                    amount: int.parse(result['amount']),
                                  );
                                });
                              }
                            },
                            onDelete: () {
                              showDeleteFeeDialog(
                                context,
                                feeName: fee.title,
                                onConfirm: () {
                                  setState(() {
                                    _instituteFees.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Text(
                      "Class Specific Fee",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _classFees.length,
                      itemBuilder: (context, index) {
                        final fee = _classFees[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CustomSpecificContainerBox(
                              heading: fee.heading,
                              subHeading: fee.subHeading,
                              isOptional: fee.isOptional,
                              details: fee.details,
                              fee: fee.fee,
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditFeePage(
                                      feeName: fee.subHeading,
                                      amount: fee.fee.toString(),
                                      description: fee.details,
                                      applyTo: "class",
                                      isOptional: fee.isOptional == "Optional",
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    _classFees[index] = ClassFee(
                                      heading: fee.heading,
                                      subHeading: result['feeName'],
                                      isOptional: result['isOptional']
                                          ? "Optional"
                                          : "Mandatory",
                                      details: result['description'],
                                      fee: int.parse(result['amount']),
                                    );
                                  });
                                }
                              },
                              onDelete: () {
                                showDeleteFeeDialog(
                                  context,
                                  feeName: fee.subHeading,
                                  onConfirm: () {
                                    setState(() {
                                      _classFees.removeAt(index);
                                    });
                                  },
                                );
                              }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

void showDeleteFeeDialog(BuildContext context, {required String feeName, required VoidCallback onConfirm}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteFeeDialog(
        feeName: feeName,
        onConfirm: onConfirm,
      );
    },
  );
}

class DeleteFeeDialog extends StatelessWidget {
  final String feeName;
  final VoidCallback onConfirm;

  const DeleteFeeDialog({
    super.key,
    required this.feeName,
    required this.onConfirm,
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
                    "Delete Fee",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete \"$feeName\"? "
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
                        onConfirm();
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

class CustomInstituteContainerBox extends StatelessWidget {
  final String title;
  final String mandatoryOrOptional;
  final int amount;
  final String detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomInstituteContainerBox({
    super.key,
    required this.title,
    required this.mandatoryOrOptional,
    required this.detail,
    required this.amount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMandatory = mandatoryOrOptional == "Mandatory";

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
                Text(title,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary, fontSize: 20)),
                Container(
                    decoration: BoxDecoration(
                      color: isMandatory
                          ? Colors.grey.withAlpha(25)
                          : Colors.blue.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        mandatoryOrOptional,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
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
                Text(amount.toString(),
                    style: const TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                    onPressed: onEdit,
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
                            style:
                                TextStyle(color: Colors.blue, fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: onDelete,
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
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20),
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

class CustomSpecificContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String isOptional;
  final int fee;
  final String details;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomSpecificContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.isOptional,
    required this.details,
    required this.fee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMandatory = isOptional == "Mandatory";

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
                Text(heading,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(150),
                        fontSize: 14)),
                Container(
                    decoration: BoxDecoration(
                      color: isMandatory
                          ? Colors.grey.withAlpha(25)
                          : Colors.blue.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        isOptional,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ))
              ],
            ),
            Text(subHeading,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary, fontSize: 20)),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 16,
                  color: Colors.blue,
                ),
                Text(fee.toString(),
                    style: const TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(details, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                    onPressed: onEdit,
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
                            style:
                                TextStyle(color: Colors.blue, fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: onDelete,
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
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20),
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
