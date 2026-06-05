import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import '../../services/api_service.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:eduphin/staff/staff_dashboard/staff_models.dart' as staff_model;
import 'staff_models.dart';

class StaffSalaryDetailPage extends StatefulWidget {
  const StaffSalaryDetailPage({super.key});

  @override
  State<StaffSalaryDetailPage> createState() => _StaffSalaryDetailPageState();
}

class _StaffSalaryDetailPageState extends State<StaffSalaryDetailPage> {
  late Stream<SalaryPageData> _salaryPageStream;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _salaryPageStream = ApiService.getStaffSalariesStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Salary Details", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: StreamBuilder<SalaryPageData>(
          stream: _salaryPageStream,
          builder: (context, snapshot) {
            return LoadingWrapper<SalaryPageData>(
              snapshot: snapshot,
              skeleton: _buildSkeleton(context),
              onRetry: _loadData,
              builder: (data) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: context.pagePadding,
                        child: context.responsive(
                          Column(
                            children: [
                              _buildBankDetailsCard(context, data.account),
                              SizedBox(height: context.spacing),
                              _buildPastSalaryRecords(context, data.salaries),
                            ],
                          ),
                          tablet: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildBankDetailsCard(context, data.account)),
                              SizedBox(width: context.spacing),
                              Expanded(flex: 3, child: _buildPastSalaryRecords(context, data.salaries)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(BuildContext context, UserDetail detail) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: colorScheme.primary, size: context.scale(22)),
                SizedBox(width: context.scale(12)),
                Text("Bank Information", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              ],
            ),
          ),
          Divider(color: colorScheme.outlineVariant, height: 1),
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Column(
              children: [
                _buildBankInfoItem(context, Icons.person_outline_rounded, "Account Holder", detail.user?.name ?? 'N/A'),
                _buildBankInfoItem(context, Icons.credit_card_rounded, "Account Number", detail.bankAccountNumber ?? 'N/A'),
                _buildBankInfoItem(context, Icons.domain_rounded, "Bank Name", detail.bankName ?? 'N/A'),
                _buildBankInfoItem(context, Icons.code_rounded, "IFSC Code", detail.ifscCode ?? 'N/A'),
                _buildBankInfoItem(context, Icons.location_on_outlined, "Branch", detail.branchName ?? 'N/A'),
                _buildBankInfoItem(context, Icons.payments_outlined, "Relationship", detail.relationshipStatus ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(8)),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(context.scale(8)),
            ),
            child: Icon(icon, color: colorScheme.primary, size: context.scale(18)),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11), fontWeight: FontWeight.bold)),
                SizedBox(height: context.scale(2)),
                Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastSalaryRecords(BuildContext context, List<Salary> salaries) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: colorScheme.primary, size: context.scale(22)),
                SizedBox(width: context.scale(12)),
                Text("Salary History", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              ],
            ),
          ),
          Divider(color: colorScheme.outlineVariant, height: 1),
          if (salaries.isEmpty)
            Padding(
              padding: EdgeInsets.all(context.scale(40)),
              child: Center(child: Text("No salary records found", style: TextStyle(color: colorScheme.onSurfaceVariant))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: context.scale(400)),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)),
                  columnSpacing: context.scale(24),
                  horizontalMargin: context.scale(20),
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(label: Text("MONTH/YEAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                    DataColumn(label: Text("NET SALARY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                    DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                  ],
                  rows: salaries.map((salary) {
                    bool isPaid = salary.status.toLowerCase() == 'paid';
                    return DataRow(
                      onSelectChanged: (_) => _showSalaryDetail(salary.id),
                      cells: [
                        DataCell(Text("${salary.month} ${salary.year}", style: TextStyle(fontSize: context.font(13)))),
                        DataCell(Text("₹ ${salary.amount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.primary))),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                            decoration: BoxDecoration(
                              color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(context.scale(6)),
                              border: Border.all(color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              salary.status.toUpperCase(),
                              style: TextStyle(
                                color: isPaid ? Colors.green : Colors.orange,
                                fontSize: context.font(10),
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          SizedBox(height: context.scale(12)),
        ],
      ),
    );
  }

  void _showSalaryDetail(dynamic salaryId) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final id = salaryId.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24)))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(context.scale(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.scale(40),
                  height: context.scale(4),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.scale(24)),
              Text("Salary Slip Details", style: GoogleFonts.roboto(fontSize: context.font(20), fontWeight: FontWeight.bold)),
              SizedBox(height: context.scale(24)),
              StreamBuilder<staff_model.SalaryDetailData>(
                stream: ApiService.getStaffSalarySlipStream(id),
                builder: (context, snapshot) {
                  return LoadingWrapper<staff_model.SalaryDetailData>(
                    snapshot: snapshot,
                    skeleton: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(4, (index) => Padding(
                        padding: EdgeInsets.only(bottom: context.scale(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(width: context.scale(100), height: context.scale(12)),
                            SizedBox(height: context.scale(8)),
                            Skeleton(width: context.scale(200), height: context.scale(18)),
                          ],
                        ),
                      )),
                    ),
                    builder: (data) {
                      final detail = data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(context, "Net Salary", "₹ ${detail.salary.netSalary ?? detail.salary.amount}", isPrimary: true),
                          _buildDetailRow(context, "Amount in Words", detail.amountInWords),
                          _buildDetailRow(context, "Basic Salary", "₹ ${detail.salary.basicSalary ?? 'N/A'}"),
                          _buildDetailRow(context, "Period", "${detail.salary.month} / ${detail.salary.year}"),
                          SizedBox(height: context.scale(20)),
                          SizedBox(
                            width: double.infinity,
                            height: context.scale(45),
                            child: OutlinedButton.icon(
                              onPressed: () => PdfService.generateSalaryPdf(detail.salary, detail.amountInWords),
                              icon: const Icon(Icons.download_rounded, size: 20),
                              label: const Text("DOWNLOAD PDF"),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                side: BorderSide(color: colorScheme.primary),
                                foregroundColor: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              ),
              SizedBox(height: context.scale(12)),
              SizedBox(
                width: double.infinity,
                height: context.scale(50),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  ),
                  child: Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isPrimary = false}) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.bold)),
          SizedBox(height: context.scale(4)),
          Text(value, style: TextStyle(
            color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
            fontSize: context.font(16),
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600
          )),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: context.pagePadding,
        child: context.responsive(
          Column(
            children: [
              _buildBankDetailsSkeleton(context),
              SizedBox(height: context.spacing),
              _buildHistorySkeleton(context),
            ],
          ),
          tablet: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildBankDetailsSkeleton(context)),
              SizedBox(width: context.spacing),
              Expanded(flex: 3, child: _buildHistorySkeleton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsSkeleton(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          children: List.generate(6, (index) => Padding(
            padding: EdgeInsets.only(bottom: context.scale(16)),
            child: Row(
              children: [
                Skeleton(width: context.scale(34), height: context.scale(34), borderRadius: 8),
                SizedBox(width: context.scale(16)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: context.scale(80), height: context.scale(10)),
                    SizedBox(height: context.scale(4)),
                    Skeleton(width: context.scale(120), height: context.scale(14)),
                  ],
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildHistorySkeleton(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          children: List.generate(5, (index) => Padding(
            padding: EdgeInsets.only(bottom: context.scale(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: context.scale(100), height: context.scale(20)),
                Skeleton(width: context.scale(80), height: context.scale(20)),
                Skeleton(width: context.scale(60), height: context.scale(20)),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
