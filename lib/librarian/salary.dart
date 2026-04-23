import 'librarian_skeleton_widgets.dart';
import '../services/common_widgets.dart';
import '../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import 'librarian_models.dart' as librarian_model;
import 'package:intl/intl.dart';

class SalaryBankDetailsPage extends StatefulWidget {
  const SalaryBankDetailsPage({super.key});

  @override
  State<SalaryBankDetailsPage> createState() => _SalaryBankDetailsPageState();
}

class _SalaryBankDetailsPageState extends State<SalaryBankDetailsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  late Stream<Map<String, dynamic>> _salaryStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    _salaryStream = ApiService.getLibrarianSalariesStream().asBroadcastStream();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _refreshStream();
    });
  }

  void _showError(String message) {
    final cleanMessage = message.replaceFirst("Exception: ", "").replaceFirst("ClientException: ", "");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(cleanMessage, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: context.theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(context.md),
      ),
    );
  }

  void _viewSalarySlip(dynamic salaryId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(context.lg),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(context.scale(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  LibrarianSkeleton(width: context.scale(30), height: context.scale(30), borderRadius: 15),
                  SizedBox(width: context.md),
                  const LibrarianSkeleton(width: 150, height: 24),
                ],
              ),
              const Divider(height: 32),
              for (int i = 0; i < 3; i++) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LibrarianSkeleton(width: 100, height: 16),
                    LibrarianSkeleton(width: 80, height: 16),
                  ],
                ),
                SizedBox(height: context.md),
              ],
              const LibrarianSkeleton(height: 80, borderRadius: 16),
              SizedBox(height: context.lg),
              const LibrarianSkeleton(height: 50, borderRadius: 12),
            ],
          ),
        ),
      ),
    );

    try {
      final slipData = await ApiService.getLibrarianSalarySlip(salaryId.toString());
      if (!mounted) return;
      Navigator.pop(context);

      final salary = slipData['salary'] ?? {};
      final amountInWords = slipData['amount_in_words'] ?? "N/A";

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final colorScheme = context.theme.colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(32))),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + context.lg,
              top: context.md,
              left: context.lg,
              right: context.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: context.scale(40),
                    height: context.scale(4),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(context.scale(2)),
                    ),
                  ),
                ),
                SizedBox(height: context.lg),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.description_outlined, color: colorScheme.primary),
                    ),
                    SizedBox(width: context.md),
                    Text(
                      "Salary Slip Details",
                      style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(height: 32),
                _buildSlipRow(context, "Basic Salary", "₹${salary['basic_salary'] ?? '0.00'}"),
                _buildSlipRow(context, "Allowances", "₹${salary['allowances'] ?? '0.00'}"),
                _buildSlipRow(context, "Deductions", "₹${salary['deductions'] ?? '0.00'}", isNegative: true),
                SizedBox(height: context.md),
                Container(
                  padding: EdgeInsets.all(context.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildSlipRow(context, "Net Salary", "₹${salary['net_salary'] ?? '0.00'}", isBold: true, color: colorScheme.primary),
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.translate, size: context.scale(16), color: colorScheme.primary),
                          SizedBox(width: context.sm),
                          Expanded(
                            child: Text(
                              "AMOUNT IN WORDS: ${amountInWords.toUpperCase()}",
                              style: TextStyle(
                                fontSize: context.font(12),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => PdfService.generateSalaryPdf(
                          librarian_model.Salary.fromJson(salary),
                          amountInWords,
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text("DOWNLOAD PDF"),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(context.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                        ),
                      ),
                    ),
                    SizedBox(width: context.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.all(context.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                        ),
                        child: const Text("DISMISS"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError(e.toString());
      }
    }
  }

  Widget _buildSlipRow(BuildContext context, String label, String value, {bool isBold = false, bool isNegative = false, Color? color}) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: context.font(14),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            isNegative ? "- $value" : value,
            style: TextStyle(
              fontSize: context.font(16),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? (isNegative ? colorScheme.error : colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Salary & Bank Details"),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _salaryStream,
        builder: (context, snapshot) {
          return LoadingWrapper<Map<String, dynamic>>(
            snapshot: snapshot,
            skeleton: const SalarySkeleton(),
            onRetry: _handleRefresh,
            builder: (salaryData) {
              return RefreshIndicator(
                key: _refreshKey,
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBankCard(context, colorScheme, salaryData),
                          SizedBox(height: context.xl),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.xs),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, color: colorScheme.primary, size: context.scale(22)),
                                SizedBox(width: context.sm),
                                Text(
                                  "Past Salary Records",
                                  style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.md),
                          _buildSalaryList(context, colorScheme, salaryData),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, ColorScheme colorScheme, Map<String, dynamic>? salaryData) {
    final user = salaryData?['userDetail'] ?? {};
    final fullName = user['first_name'] != null
        ? "${user['first_name']} ${user['last_name'] ?? ''}".trim()
        : (user['name'] ?? "N/A");

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(28)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.sm),
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.account_balance, color: colorScheme.primary, size: context.scale(22)),
                ),
                SizedBox(width: context.md),
                Text("Bank Details", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.w800)),
              ],
            ),
            SizedBox(height: context.lg),
            _buildDetailRow(context, "Account Holder", fullName),
            _buildDetailRow(context, "Account Number", user['bank_account_number'] ?? "N/A", canCopy: true),
            _buildDetailRow(context, "Bank Name", user['bank_name'] ?? "N/A"),
            _buildDetailRow(context, "IFSC Code", user['ifsc_code'] ?? "N/A"),
            _buildDetailRow(context, "Branch", user['branch_name'] ?? "N/A"),
            _buildDetailRow(
              context,
              "Current Salary",
              "₹${salaryData?['lastSalary']?['net_salary'] ?? user['salary'] ?? '0.00'}",
              isLast: true,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryList(BuildContext context, ColorScheme colorScheme, Map<String, dynamic>? salaryData) {
    final salaries = salaryData?['salaries'] as List? ?? [];

    if (salaries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.xl * 2),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: context.scale(48), color: colorScheme.outlineVariant),
              SizedBox(height: context.md),
              Text("No Salary Records Found", style: TextStyle(color: colorScheme.outline, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: salaries.length,
      itemBuilder: (context, index) {
        final salary = salaries[index];
        final isPaid = salary['status']?.toString().toLowerCase() == 'paid';
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: context.md),
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: ListTile(
            onTap: () => _viewSalarySlip(salary['id']),
            contentPadding: EdgeInsets.all(context.md),
            leading: Container(
              padding: EdgeInsets.all(context.sm),
              decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.payments_rounded, color: colorScheme.primary),
            ),
            title: Text(
              "₹${salary['net_salary'] ?? '0.00'}",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: context.font(17)),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: context.xs),
              child: Text(
                salary['payment_date'] != null
                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary['payment_date']))
                    : (salary['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary['created_at'])) : "Payment Pending"),
                style: TextStyle(fontSize: context.font(13), color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
            trailing: _buildBadge(context, salary['status'] ?? "Pending", isPaid ? Colors.green : Colors.orange),
          ),
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.scale(10)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(11), fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isLast = false, bool isPrimary = false, bool canCopy = false}) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w800, color: isPrimary ? colorScheme.primary : colorScheme.onSurface),
                      ),
                    ),
                    if (canCopy && value != "N/A") ...[
                      SizedBox(width: context.xs),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard"), duration: Duration(seconds: 1)));
                        },
                        child: Icon(Icons.copy_rounded, size: context.scale(14), color: colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ],
    );
  }
}
