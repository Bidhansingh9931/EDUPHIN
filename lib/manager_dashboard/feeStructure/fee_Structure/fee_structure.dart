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

    if (mounted) {
      setState(() {
        _instituteFees = instituteFeesData;
        _classFees = classFeesData;
        _isLoading = false;
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateNewFeePage()));
          },
          backgroundColor: Colors.blue.shade900,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            "Create New Fee",
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Fee Structure"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildWideLayout();
                } else {
                  return _buildNarrowLayout();
                }
              }),
            ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstituteFeesSection(),
          const SizedBox(height: 16),
          _buildClassFeesSection(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildInstituteFeesSection(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _buildClassFeesSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstituteFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Institute - Wide Fee",
          style: Theme.of(context).textTheme.titleLarge,
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
                        isOptional: fee.mandatoryOrOptional == "Optional",
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _instituteFees[index] = InstituteFee(
                        title: result['feeName'],
                        mandatoryOrOptional:
                            result['isOptional'] ? "Optional" : "Mandatory",
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
      ],
    );
  }

  Widget _buildClassFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Class Specific Fee",
          style: Theme.of(context).textTheme.titleLarge,
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
                    if (result != null && mounted) {
                      setState(() {
                        _classFees[index] = ClassFee(
                          heading: fee.heading,
                          subHeading: result['feeName'],
                          isOptional:
                              result['isOptional'] ? "Optional" : "Mandatory",
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
    );
  }
}

void showDeleteFeeDialog(
    BuildContext context, {
    required String feeName,
    required VoidCallback onConfirm,
  }) {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
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
                  Text("Delete Fee", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete \"$feeName\"? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
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
                      child: Text("Yes, Delete", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              Container(
                decoration: BoxDecoration(
                  color: isMandatory
                      ? Colors.grey.withAlpha(25)
                      : Colors.blue.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  mandatoryOrOptional,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
           Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 16,
                color: Colors.blue,
              ),
              Text(amount.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          Text(detail, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Divider(
            color: theme.colorScheme.onPrimary.withAlpha(180),
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(45)),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
                  label: Text("Edit",
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.blue)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(45)),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                  label: Text("Delete",
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomSpecificContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String isOptional;
  final String details;
  final int fee;
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subHeading,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              Container(
                decoration: BoxDecoration(
                  color: isMandatory
                      ? Colors.grey.withAlpha(25)
                      : Colors.blue.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  isOptional,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 16,
                color: Colors.blue,
              ),
              Text(fee.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          Text(details, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Divider(
            color: theme.colorScheme.onPrimary.withAlpha(180),
            thickness: 1,
          ),
           const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(45)),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
                  label: Text("Edit",
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.blue)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(45)),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                  label: Text("Delete",
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
