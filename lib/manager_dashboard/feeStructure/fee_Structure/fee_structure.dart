import 'dart:convert';
import 'dart:ui';
import 'package:eduphin/manager_dashboard/feeStructure/fee_Structure/create_new_fee.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'edit_fee.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS (ROBUST)
// ───────────────────────────────────────────────────────────

class InstituteFee {
  final int id;
  final String title;
  final String mandatoryOrOptional;
  final String detail;
  final int amount;

  InstituteFee({
    required this.id,
    required this.title,
    required this.mandatoryOrOptional,
    required this.detail,
    required this.amount,
  });

  factory InstituteFee.fromJson(Map<String, dynamic> json) {
    return InstituteFee(
      id: json['id'] ?? 0,
      title: json['fee_name']?.toString() ?? 'N/A',
      mandatoryOrOptional: (json['is_optional'] == true || json['is_optional'] == 1) ? "Optional" : "Mandatory",
      detail: json['description']?.toString() ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
    );
  }
}

class ClassFee {
  final int id;
  final String heading;
  final String subHeading;
  final String isOptional;
  final String details;
  final int fee;

  ClassFee({
    required this.id,
    required this.heading,
    required this.subHeading,
    required this.isOptional,
    required this.details,
    required this.fee,
  });

  factory ClassFee.fromJson(Map<String, dynamic> json) {
    final className = (json['class'] is Map<String, dynamic>) ? json['class']['name']?.toString() : 'N/A';
    return ClassFee(
      id: json['id'] ?? 0,
      heading: "Class: ${className ?? 'N/A'}",
      subHeading: json['fee_name']?.toString() ?? 'N/A',
      isOptional: (json['is_optional'] == true || json['is_optional'] == 1) ? "Optional" : "Mandatory",
      details: json['description']?.toString() ?? '',
      fee: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         PAGE WIDGET
// ───────────────────────────────────────────────────────────

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/fees');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Fix: Safely handle null lists from the API
        final List<dynamic> instituteFeesData = data['institute_fees'] as List? ?? [];
        final List<dynamic> classFeesData = data['class_fees'] as List? ?? [];

        final instituteFees = instituteFeesData.whereType<Map<String, dynamic>>().map((fee) => InstituteFee.fromJson(fee)).toList();
        final classFees = classFeesData.whereType<Map<String, dynamic>>().map((fee) => ClassFee.fromJson(fee)).toList();

        if (mounted) {
          setState(() {
            _instituteFees = instituteFees;
            _classFees = classFees;
          });
        }
      } else {
        throw Exception('Failed to load fees: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFee(int feeId) async {
     try {
      final response = await ApiService.delete('manager/fees/$feeId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee deleted successfully'), backgroundColor: Colors.green),
          );
          _fetchData(); // Refresh the data
        }
      } else {
         final error = jsonDecode(response.body)['message'] ?? 'Failed to delete fee';
        throw Exception(error);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
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
          onPressed: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateNewFeePage()));
            if (result == true) {
              _fetchData();
            }
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
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return _buildWideLayout();
                  } else {
                    return _buildNarrowLayout();
                  }
                }),
              ),
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
                        feeId: fee.id,
                        feeName: fee.title,
                        amount: fee.amount.toString(),
                        description: fee.detail,
                        applyTo: "institute",
                        isOptional: fee.mandatoryOrOptional == "Optional",
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchData();
                  }
                },
                onDelete: () {
                  showDeleteFeeDialog(
                    context,
                    feeName: fee.title,
                    onConfirm: () => _deleteFee(fee.id),
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
                          feeId: fee.id,
                          feeName: fee.subHeading,
                          amount: fee.fee.toString(),
                          description: fee.details,
                          applyTo: "class",
                          isOptional: fee.isOptional == "Optional",
                        ),
                      ),
                    );
                    if (result == true) {
                      _fetchData();
                    }
                  },
                  onDelete: () {
                    showDeleteFeeDialog(
                      context,
                      feeName: fee.subHeading,
                      onConfirm: () => _deleteFee(fee.id),
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
                   // Fix: Use RichText for better text handling and styling
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                      children: <TextSpan>[
                        const TextSpan(text: 'Are you sure you want to delete '),
                        TextSpan(text: '"$feeName"', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: '? This action cannot be undone.'),
                      ],
                    ),
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
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         CUSTOM WIDGETS
// ───────────────────────────────────────────────────────────

class CustomInstituteContainerBox extends StatelessWidget {
  final String title;
  final String mandatoryOrOptional;
  final String detail;
  final int amount;
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
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fix: Wrap title in Flexible to prevent overflow
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "₹$amount",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mandatoryOrOptional,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mandatoryOrOptional == "Mandatory" ? Colors.redAccent : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: Text("Edit", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                  label: Text("Delete", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fix: Wrap title in Flexible to prevent overflow
              Flexible(
                child: Text(
                  subHeading,
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "₹$fee",
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isOptional,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOptional == "Mandatory" ? Colors.redAccent : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: Text("Edit", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                  label: Text("Delete", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
