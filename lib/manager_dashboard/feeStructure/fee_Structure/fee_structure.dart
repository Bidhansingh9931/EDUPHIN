import 'dart:convert';
import 'dart:ui';
import 'package:eduphin/manager_dashboard/feeStructure/fee_Structure/create_new_fee.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
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
      amount: (double.tryParse(json['amount']?.toString().replaceAll(RegExp(r'[₹,]'), '') ?? '0') ?? 0).toInt(),
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
  final int classId;

  ClassFee({
    required this.id,
    required this.heading,
    required this.subHeading,
    required this.isOptional,
    required this.details,
    required this.fee,
    required this.classId,
  });

  factory ClassFee.fromJson(Map<String, dynamic> json) {
    final className = (json['class'] is Map<String, dynamic>) ? json['class']['name']?.toString() : 'N/A';
    return ClassFee(
      id: json['id'] ?? 0,
      heading: "Class: ${className ?? 'N/A'}",
      subHeading: json['fee_name']?.toString() ?? 'N/A',
      isOptional: (json['is_optional'] == true || json['is_optional'] == 1) ? "Optional" : "Mandatory",
      details: json['description']?.toString() ?? '',
      fee: (double.tryParse(json['amount']?.toString().replaceAll(RegExp(r'[₹,]'), '') ?? '0') ?? 0).toInt(),
      classId: (json['class'] is Map<String, dynamic>) ? json['class']['id'] ?? 0 : 0,
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

        final List<dynamic> instituteFeesData = data['institute_fees'] as List? ?? [];
        final List<dynamic> classFeesData = data['class_fees'] as List? ?? [];

        final instituteFees = instituteFeesData
            .whereType<Map<String, dynamic>>()
            .map((fee) => InstituteFee.fromJson(fee))
            .toList();
        final classFees = classFeesData
            .whereType<Map<String, dynamic>>()
            .map((fee) => ClassFee.fromJson(fee))
            .toList();

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
      if (mounted) {
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
            SnackBar(
                content: const Text('Fee deleted successfully'),
                backgroundColor: context.theme.colorScheme.primary),
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
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: context.theme.colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fee Inventory", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
            Text("Manage institutional and class-specific fees", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    padding: context.pagePadding,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (context.isMobile)
                          _buildNarrowLayout()
                        else
                          _buildWideLayout(),
                        SizedBox(height: context.scale(80)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateNewFeePage()));
          if (result == true) {
            _fetchData();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        label: Text("CREATE NEW FEE", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstituteFeesSection(),
        SizedBox(height: context.scale(24)),
        _buildClassFeesSection(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInstituteFeesSection(),
        ),
        SizedBox(width: context.md),
        Expanded(
          child: _buildClassFeesSection(),
        ),
      ],
    );
  }

  Widget _buildInstituteFeesSection() {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Institute - Wide Fee",
          style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold),
        ),
        Text(
          "Fees applicable to all students",
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
        ),
        SizedBox(height: context.scale(16)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _instituteFees.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
          itemBuilder: (context, index) {
            final fee = _instituteFees[index];
            return CustomInstituteContainerBox(
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildClassFeesSection() {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Class Specific Fee",
          style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold),
        ),
        Text(
          "Fees applicable to specific classes",
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
        ),
        SizedBox(height: context.scale(16)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _classFees.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
          itemBuilder: (context, index) {
            final fee = _classFees[index];
            return CustomSpecificContainerBox(
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
                        classId: fee.classId,
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
                });
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
    barrierColor: context.theme.colorScheme.scrim.withValues(alpha: 0.5),
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
    final theme = context.theme;
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
              margin: EdgeInsets.symmetric(horizontal: context.scale(24)),
              padding: EdgeInsets.all(context.scale(20)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(context.scale(20)),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Delete Fee", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(20), fontWeight: FontWeight.bold)),
                  SizedBox(height: context.scale(12)),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14), color: theme.colorScheme.onSurface),
                      children: <TextSpan>[
                        const TextSpan(text: 'Are you sure you want to delete '),
                        TextSpan(text: '"$feeName"', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: '? This action cannot be undone.'),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scale(24)),
                  buildActionButton(
                    context,
                    "Yes, Delete",
                    () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                  SizedBox(height: context.scale(12)),
                  buildActionButton(
                    context,
                    "Cancel",
                    () => Navigator.pop(context),
                    isPrimary: false,
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
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: EdgeInsets.all(context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
              ),
              SizedBox(width: context.sm),
              Text(
                "₹$amount",
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(20),
                    color: theme.colorScheme.primary),
              ),
            ],
          ),
          SizedBox(height: context.xs),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: context.sm, vertical: context.scale(2)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(context.scale(6)),
            ),
            child: Text(
              mandatoryOrOptional.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: context.font(10),
                color: mandatoryOrOptional == "Mandatory"
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (detail.isNotEmpty) ...[
            SizedBox(height: context.sm),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: context.font(13),
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          SizedBox(height: context.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, size: context.scale(18)),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: context.scale(18)),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
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
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: EdgeInsets.all(context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: context.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  subHeading,
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
              ),
              SizedBox(width: context.sm),
              Text(
                "₹$fee",
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(20),
                    color: theme.colorScheme.primary),
              ),
            ],
          ),
          SizedBox(height: context.xs),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: context.sm, vertical: context.scale(2)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(context.scale(6)),
            ),
            child: Text(
              isOptional.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: context.font(10),
                color: isOptional == "Mandatory"
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: context.sm),
            Text(
              details,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: context.font(13),
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          SizedBox(height: context.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded, size: context.scale(18)),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      size: context.scale(18)),
                  label: const Text("Delete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
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
