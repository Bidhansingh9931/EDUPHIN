import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/student/student_fee_model.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';

class StudentFeePage extends StatefulWidget {
  const StudentFeePage({super.key});

  @override
  State<StudentFeePage> createState() => _StudentFeePageState();
}

class _StudentFeePageState extends State<StudentFeePage> {
  bool isLoading = true;
  String? errorMessage;
  StudentFeeData? feeData;
  static const String _cacheKey = 'student_fee_details';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchFeeData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        feeData = StudentFeeData.fromJson(cachedData as Map<String, dynamic>);
        if (feeData != null) {
          isLoading = false;
        }
      });
    }
  }

  Future<void> _fetchFeeData() async {
    if (feeData == null) setState(() => isLoading = true);
    try {
      final data = await ApiService.getStudentFees();
      if (mounted) {
        setState(() {
          feeData = data;
          isLoading = false;
          errorMessage = null;
        });
        CacheService.saveData(_cacheKey, data.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ErrorHandler.showError(context, e);
        if (feeData == null) {
          errorMessage = ErrorHandler.getMessage(e);
        }
      }
    }
  }

  Future<void> _printReceipt(String idHash) async {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fetching receipt details...")),
      );
      final receipt = await ApiService.getStudentFeeReceipt(idHash);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colorScheme.surfaceContainerLow,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
            title: Text("Receipt Generated", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Receipt for ₹${receipt['payment']['paid_amount']} fetched successfully.",
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
                ),
                SizedBox(height: context.scale(12)),
                Text(
                  "Amount in words: ${receipt['amount_in_words']}",
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, fontSize: context.font(12), color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Fee Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(18)),
        ),
      ),
      body: LoadingWrapper(
        isLoading: isLoading,
        hasData: feeData != null,
        error: errorMessage,
        skeleton: const _FeeSkeleton(),
        onRefresh: _fetchFeeData,
        onRetry: _fetchFeeData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// STUDENT INFO
                  _buildStudentInfoCard(),

                  SizedBox(height: context.scale(32)),

                  Text(
                    "Fee Summary",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(20)),
                  ),
                  SizedBox(height: context.scale(16)),
                  _buildSummaryGrid(feeData?.summary),

                  SizedBox(height: context.scale(32)),

                  _buildSectionHeader("Payment History", Icons.history_rounded),
                  SizedBox(height: context.scale(16)),
                  _buildPaymentHistoryList(),

                  SizedBox(height: context.scale(32)),

                  _buildSectionHeader("Fee Structure", Icons.account_balance_wallet_outlined),
                  SizedBox(height: context.scale(16)),
                  _buildFeeStructureTable(),

                  SizedBox(height: context.scale(32)),

                  if (feeData?.fines?.isNotEmpty ?? false) ...[
                    _buildSectionHeader("Fine Details", Icons.warning_amber_rounded),
                    SizedBox(height: context.scale(16)),
                    _buildFineDetailsTable(),
                    SizedBox(height: context.scale(32)),
                  ],
                  SizedBox(height: context.scale(50)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: context.scale(22)),
        SizedBox(width: context.scale(12)),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(20)),
        ),
      ],
    );
  }

  Widget _buildStudentInfoCard() {
    final s = feeData?.student;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.scale(24)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: context.scale(30),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: colorScheme.primary, size: context.scale(35)),
              ),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${s?.firstName ?? ""} ${s?.lastName ?? ""}",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
                    ),
                    SizedBox(height: context.scale(4)),
                    Text(
                      "Roll No: ${s?.studentRollNo ?? "N/A"}",
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scale(20)),
            child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          _infoRow(Icons.school_outlined, "Class", s?.classInfo?.name ?? "N/A"),
          SizedBox(height: context.scale(12)),
          _infoRow(Icons.email_outlined, "Email", s?.email ?? "N/A"),
          SizedBox(height: context.scale(12)),
          _infoRow(Icons.calendar_today_outlined, "Frequency", s?.feeFrequency ?? "N/A"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: context.scale(18)),
        SizedBox(width: context.scale(12)),
        Text("$label: ", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13), fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildSummaryGrid(FeeSummary? summary) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      final crossAxisCount = isWide ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        childAspectRatio: isWide ? 1.5 : 1.3,
        children: [
          _summaryCard("Total Fee", "₹${summary?.totalFee ?? 0}", Icons.account_balance_rounded, const Color(0xFF3B82F6)),
          _summaryCard("Fines", "₹${summary?.totalFine ?? 0}", Icons.gavel_rounded, const Color(0xFFF59E0B)),
          _summaryCard("Paid", "₹${summary?.totalPaid ?? 0}", Icons.check_circle_rounded, const Color(0xFF10B981)),
          _summaryCard("Due Amount", "₹${summary?.due ?? 0}", Icons.pending_actions_rounded, const Color(0xFFEF4444)),
        ],
      );
    });
  }

  Widget _summaryCard(String title, String amount, IconData icon, Color color) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: context.scale(24)),
          SizedBox(height: context.scale(12)),
          Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: context.scale(4)),
          FittedBox(fit: BoxFit.scaleDown, child: Text(amount, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(16)))),
        ],
      ),
    );
  }

  Widget _buildFeeStructureTable() {
    final fees = feeData?.fees ?? [];
    final overrides = feeData?.overrides ?? {};
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - context.scale(48)),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
            columnSpacing: context.scale(24),
            columns: [
              DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("FEE TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("AMOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("TYPE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
            ],
            rows: List.generate(fees.length, (index) {
              final fee = fees[index];
              final amount = overrides.containsKey(fee.id.toString()) ? overrides[fee.id.toString()]!.overriddenAmount : fee.amount;
              return DataRow(cells: [
                DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(fee.name, style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500))),
                DataCell(Text("₹$amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.primary))),
                DataCell(Text(fee.classId == null ? "Inst." : "Class", style: TextStyle(fontSize: context.font(13)))),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFineDetailsTable() {
    final fines = feeData?.fines ?? [];
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - context.scale(48)),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
            columnSpacing: context.scale(24),
            columns: [
              DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("REASON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("AMOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              DataColumn(label: Text("REMARKS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
            ],
            rows: List.generate(fines.length, (index) {
              final fine = fines[index];
              return DataRow(cells: [
                DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(fine.reason, style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500))),
                DataCell(Text("₹${fine.amount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: const Color(0xFFF59E0B)))),
                DataCell(Text(fine.remarks ?? "-", style: TextStyle(fontSize: context.font(13)))),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryList() {
    final payments = feeData?.payments ?? [];
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.scale(32)),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(16)),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Center(child: Text("No payment history found", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)))),
      );
    }

    if (!context.isMobile) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(16)),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - context.scale(48)),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
              columnSpacing: context.scale(24),
              columns: [
                DataColumn(label: Text("DATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
                DataColumn(label: Text("AMOUNT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
                DataColumn(label: Text("METHOD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
                DataColumn(label: Text("REF NO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
                DataColumn(label: Text("SUBMITTED BY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
                DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.onSurfaceVariant))),
              ],
              rows: payments.map((p) => DataRow(cells: [
                DataCell(Text(p.date, style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text("₹${p.paidAmount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: const Color(0xFF10B981)))),
                DataCell(_buildStatusBadge(p.paymentMethod.toUpperCase(), colorScheme.primary)),
                DataCell(Text(p.referenceNo ?? "-", style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(p.submitter?.name ?? "-", style: TextStyle(fontSize: context.font(13)))),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: context.scale(20)),
                    onPressed: () {
                      if (p.idHash != null) _printReceipt(p.idHash!);
                    },
                  ),
                ),
              ])).toList(),
            ),
          ),
        ),
      );
    }

    return Column(
      children: payments.map((p) {
        return Container(
          margin: EdgeInsets.only(bottom: context.scale(16)),
          padding: EdgeInsets.all(context.scale(16)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.date, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
                      SizedBox(height: context.scale(4)),
                      Text("₹${p.paidAmount}", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
                    ],
                  ),
                  _buildStatusBadge(p.paymentMethod.toUpperCase(), colorScheme.primary),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ref: ${p.referenceNo ?? "-"}", 
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text("By: ${p.submitter?.name ?? "-"}", 
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(8)),
                  Flexible(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFF10B981),
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.scale(8)),
                          side: const BorderSide(color: Color(0xFF10B981), width: 0.5),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (p.idHash != null) _printReceipt(p.idHash!);
                      },
                      icon: Icon(Icons.receipt_long_rounded, size: context.scale(14)),
                      label: FittedBox(
                        child: Text("RECEIPT", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FeeSkeleton extends StatelessWidget {
  const _FeeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info Skeleton
              Container(
                padding: EdgeInsets.all(context.scale(24)),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: context.scale(60), height: context.scale(60), borderRadius: context.scale(30)),
                        SizedBox(width: context.scale(16)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: context.scale(150), height: context.scale(20), borderRadius: context.scale(4)),
                            SizedBox(height: context.scale(8)),
                            SkeletonBox(width: context.scale(100), height: context.scale(14), borderRadius: context.scale(4)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: context.scale(24)),
                    SkeletonBox(height: context.scale(14), borderRadius: context.scale(4)),
                    SizedBox(height: context.scale(12)),
                    SkeletonBox(height: context.scale(14), borderRadius: context.scale(4)),
                  ],
                ),
              ),
              SizedBox(height: context.scale(32)),
              SkeletonBox(width: context.scale(150), height: context.scale(24), borderRadius: context.scale(4)),
              SizedBox(height: context.scale(16)),
              // Summary Grid Skeleton
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: context.isDesktop ? 4 : 2,
                crossAxisSpacing: context.scale(16),
                mainAxisSpacing: context.scale(16),
                childAspectRatio: context.isDesktop ? 1.5 : 1.3,
                children: List.generate(4, (index) => Container(
                  padding: EdgeInsets.all(context.scale(16)),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(context.scale(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: context.scale(24), height: context.scale(24), borderRadius: context.scale(4)),
                      SizedBox(height: context.scale(12)),
                      SkeletonBox(width: context.scale(60), height: context.scale(12), borderRadius: context.scale(4)),
                      SizedBox(height: context.scale(8)),
                      SkeletonBox(width: context.scale(80), height: context.scale(16), borderRadius: context.scale(4)),
                    ],
                  ),
                )),
              ),
              SizedBox(height: context.scale(32)),
              SkeletonBox(width: context.scale(150), height: context.scale(24), borderRadius: context.scale(4)),
              SizedBox(height: context.scale(16)),
              // List Skeleton
              ...List.generate(3, (index) => Padding(
                padding: EdgeInsets.only(bottom: context.scale(16)),
                child: SkeletonBox(height: context.scale(100), borderRadius: context.scale(16)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
