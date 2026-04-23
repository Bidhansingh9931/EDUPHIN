import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/salary_models.dart';
import 'package:eduphin/staff/staff_dashboard/staff_models.dart' as staff_model;
import 'package:intl/intl.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/pdf_service.dart';

class SalaryBankDetailsPage extends StatefulWidget {
  const SalaryBankDetailsPage({super.key});

  @override
  State<SalaryBankDetailsPage> createState() => _SalaryBankDetailsPageState();
}

class _SalaryBankDetailsPageState extends State<SalaryBankDetailsPage> {
  SalaryPageData? _salaryData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load from cache first
      final cachedData = await TeacherCacheService.load('salary_details');
      if (cachedData != null) {
        setState(() {
          _salaryData = SalaryPageData.fromJson(cachedData);
          _isLoading = false;
        });
      }

      // Fetch fresh data
      final freshData = await ApiService.getSalaryDetails();
      await TeacherCacheService.save('salary_details', freshData.toJson());

      if (mounted) {
        setState(() {
          _salaryData = freshData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_salaryData == null) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        } else {
          // If we have cached data, just show a snackbar for the background fetch error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update salary details: $e")),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Salary & Bank Details"),
        centerTitle: true,
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _salaryData != null,
        skeleton: _buildSkeleton(),
        child: _error != null
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: context.scale(48), color: colorScheme.error),
                      SizedBox(height: context.spacing),
                      Text(
                        "Error: $_error",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
                      ),
                      SizedBox(height: context.spacing * 1.5),
                      FilledButton(
                        onPressed: _fetchData,
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                ),
              )
            : _salaryData == null
                ? Center(
                    child: Text(
                      "No salary data found",
                      style: TextStyle(fontSize: context.font(14), color: colorScheme.outline),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: SingleChildScrollView(
                      padding: context.pagePadding,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBankDetailsCard(_salaryData!, _salaryData!.account),
                              SizedBox(height: context.spacing * 2),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: context.scale(4)),
                                child: Row(
                                  children: [
                                    Icon(Icons.history, color: colorScheme.primary, size: context.scale(20)),
                                    SizedBox(width: context.scale(12)),
                                    Text(
                                      "Past Salary Records",
                                      style: TextStyle(
                                        fontSize: context.font(18),
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.spacing),
                              _buildPastRecordsTable(_salaryData!.salaries),
                              SizedBox(height: context.spacing * 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: context.theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(20)),
                  side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.scale(16)),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(20))),
                      ),
                      child: Row(
                        children: [
                          TeacherSkeleton(width: context.scale(20), height: context.scale(20)),
                          SizedBox(width: context.scale(12)),
                          TeacherSkeleton(width: context.scale(100), height: context.font(16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(context.scale(20)),
                      child: Column(
                        children: List.generate(
                          6,
                          (index) => Padding(
                            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                            child: Row(
                              children: [
                                TeacherSkeleton(width: context.scale(32), height: context.scale(32), borderRadius: BorderRadius.circular(16)),
                                SizedBox(width: context.scale(12)),
                                TeacherSkeleton(width: context.scale(100), height: context.font(14)),
                                const Spacer(),
                                TeacherSkeleton(width: context.scale(80), height: context.font(14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.spacing * 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scale(4)),
                child: Row(
                  children: [
                    TeacherSkeleton(width: context.scale(20), height: context.scale(20)),
                    SizedBox(width: context.scale(12)),
                    TeacherSkeleton(width: context.scale(150), height: context.font(18)),
                  ],
                ),
              ),
              SizedBox(height: context.spacing),
              TeacherSkeleton(height: context.scale(200), borderRadius: BorderRadius.circular(context.scale(20))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(SalaryPageData data, BankAccount account) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(16)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(20))),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, size: context.scale(20), color: colorScheme.primary),
                SizedBox(width: context.scale(12)),
                Text(
                  "Bank Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(16),
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Column(
              children: [
                _detailRow(Icons.person_outline, "Account Holder", account.accountHolderName),
                _detailRow(Icons.credit_card_outlined, "Account Number", account.accountNumber ?? "N/A"),
                _detailRow(Icons.account_balance_outlined, "Bank Name", account.bankName ?? "N/A"),
                _detailRow(Icons.code_outlined, "IFSC Code", account.ifscCode ?? "N/A"),
                _detailRow(Icons.location_on_outlined, "Branch", account.branch ?? "N/A"),
                _detailRow(Icons.payments_outlined, "Basic Salary", account.basicSalary ?? "N/A", isLast: true),
                SizedBox(height: context.scale(24)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (data.salaries.isNotEmpty) {
                        _showSalaryDetail(data.salaries.first.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No salary records found to generate slip.")),
                        );
                      }
                    },
                    icon: Icon(Icons.receipt_long, size: context.scale(18)),
                    label: Text("GENERATE NEW SALARY SLIP", style: TextStyle(fontSize: context.font(14))),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDetail(dynamic salaryId) async {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    try {
      final data = await ApiService.getTeacherSalarySlip(salaryId.toString());
      final detail = staff_model.SalaryDetailData.fromJson(data);
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final theme = context.theme;
          final colorScheme = theme.colorScheme;
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(28))),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + context.scale(24),
              top: context.scale(16),
              left: context.scale(24),
              right: context.scale(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: context.scale(32),
                      height: context.scale(4),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(context.scale(2)),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scale(24)),
                  Text(
                    "Salary Slip Detail",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: context.font(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.spacing),
                  Divider(color: colorScheme.outlineVariant),
                  SizedBox(height: context.spacing),
                  _buildModalDetailItem(context, "Net Salary", "₹ ${detail.salary.netSalary ?? detail.salary.amount}", isPrimary: true),
                  _buildModalDetailItem(context, "Amount in words", detail.amountInWords),
                  _buildModalDetailItem(context, "Basic Salary", "₹ ${detail.salary.basicSalary ?? 'N/A'}"),
                  _buildModalDetailItem(context, "Month / Year", "${detail.salary.month} / ${detail.salary.year}"),
                  SizedBox(height: context.spacing * 2),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => PdfService.generateSalaryPdf(detail.salary, detail.amountInWords),
                          icon: const Icon(Icons.download),
                          label: const Text("DOWNLOAD PDF"),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                        ),
                      ),
                      SizedBox(width: context.spacing),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                          child: Text("CLOSE", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildModalDetailItem(BuildContext context, String label, String value, {bool isPrimary = false}) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: context.font(12),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.scale(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.font(16),
              fontWeight: FontWeight.bold,
              color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isLast = false}) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.scale(12)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.scale(8)),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: context.scale(16), color: colorScheme.primary),
              ),
              SizedBox(width: context.scale(12)),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: context.font(14),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: context.font(14),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant),
      ],
    );
  }

  Widget _buildPastRecordsTable(List<SalaryRecord> records) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columnSpacing: context.scale(24),
          dataRowMinHeight: context.scale(60),
          dataRowMaxHeight: context.scale(60),
          columns: [
            DataColumn(label: Text("Month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.onSurface))),
            DataColumn(label: Text("Net Salary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.onSurface))),
            DataColumn(label: Text("Payment Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.onSurface))),
          ],
          rows: records.map((record) {
            return DataRow(
              onSelectChanged: (selected) {
                if (selected != null && selected) {
                  _showSalaryDetail(record.id);
                }
              },
              cells: [
                DataCell(Text(
                  record.paymentDate != null ? DateFormat('MMMM yyyy').format(DateTime.parse(record.paymentDate!)) : "N/A",
                  style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
                )),
                DataCell(Text(
                  "₹${record.netSalary}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.primary),
                )),
                DataCell(Text(
                  record.paymentDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(record.paymentDate!)) : "N/A",
                  style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
