import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart' as accountant_model;
import 'package:intl/intl.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/pdf_service.dart';

class SalarySlipsPage extends StatefulWidget {
  final String? employeeId;
  const SalarySlipsPage({super.key, this.employeeId});

  @override
  State<SalarySlipsPage> createState() => _SalarySlipsPageState();
}

class _SalarySlipsPageState extends State<SalarySlipsPage> {
  late Stream<Map<String, dynamic>> _salaryStream;

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  void _fetchSalaries() {
    setState(() {
      if (widget.employeeId != null) {
        _salaryStream = ApiService.getAccountantEmployeeSalaryStream(widget.employeeId!);
      } else {
        _salaryStream = ApiService.getAccountantMySalariesStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId != null ? "Employee Salary Slips" : "My Salary Slips"),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _salaryStream,
        builder: (context, snapshot) {
          return LoadingWrapper<Map<String, dynamic>>(
            snapshot: snapshot,
            onRetry: _fetchSalaries,
            skeleton: _buildSkeleton(),
            builder: (data) {
              final employeeDetail = data['account'] != null ? accountant_model.UserDetail.fromJson(data['account']) : null;
              final salaries = data['salaries'] != null ? (data['salaries'] as List).map((e) => accountant_model.Salary.fromJson(e)).toList() : <accountant_model.Salary>[];

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(800)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (employeeDetail != null && widget.employeeId != null) _buildEmployeeHeader(context, employeeDetail),
                        if (widget.employeeId == null && employeeDetail != null) _buildBankDetailsCard(context, employeeDetail),
                        Padding(
                          padding: EdgeInsets.only(top: context.spacing, bottom: context.spacing),
                          child: Text(
                            "Salary History",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (salaries.isEmpty)
                          _buildEmptyState(context)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: salaries.length,
                            itemBuilder: (context, index) => _buildSalaryCard(context, salaries[index]),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.employeeId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showGenerateSalaryDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Generate Salary"),
            )
          : null,
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(800)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.employeeId != null)
                Card(
                  margin: EdgeInsets.only(bottom: context.spacing * 1.5),
                  elevation: 0,
                  color: context.theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing),
                    child: Row(
                      children: [
                        Skeleton(width: context.scale(56), height: context.scale(56), borderRadius: context.scale(28)),
                        SizedBox(width: context.spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(height: context.font(18), width: context.scale(150)),
                              SizedBox(height: context.scale(4)),
                              Skeleton(height: context.font(14), width: context.scale(100)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (widget.employeeId == null)
                Card(
                  margin: EdgeInsets.only(bottom: context.spacing),
                  elevation: 0,
                  color: context.theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: context.scale(20), width: context.scale(120)),
                        Divider(height: context.scale(24), color: context.theme.colorScheme.outlineVariant),
                        ...List.generate(4, (index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: context.scale(4)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Skeleton(height: context.font(12), width: context.scale(80)),
                              Skeleton(height: context.font(12), width: context.scale(100)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: context.spacing, bottom: context.spacing),
                child: Skeleton(height: context.font(16), width: context.scale(120)),
              ),
              ...List.generate(5, (index) => Card(
                margin: EdgeInsets.only(bottom: context.spacing),
                elevation: 0,
                color: context.theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Row(
                    children: [
                      Skeleton(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
                      SizedBox(width: context.spacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(height: context.font(16), width: context.scale(120)),
                            SizedBox(height: context.scale(4)),
                            Skeleton(height: context.font(12), width: context.scale(100)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Skeleton(height: context.font(16), width: context.scale(60)),
                          SizedBox(height: context.scale(4)),
                          Skeleton(height: context.scale(18), width: context.scale(50), borderRadius: context.scale(4)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context, accountant_model.UserDetail employeeDetail) {
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.only(bottom: context.spacing * 1.5),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Row(
          children: [
            ProfileAvatar(
              imageUrl: employeeDetail.photo != null ? "${ApiService.baseUrl}/storage/${employeeDetail.photo}" : null,
              radius: context.scale(28),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeDetail.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: context.font(18),
                    ),
                  ),
                  Text(
                    "Employee ID: ${widget.employeeId ?? employeeDetail.encryptedId}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(BuildContext context, accountant_model.Salary salary) {
    final theme = context.theme;
    final isPaid = salary.status.toLowerCase() == 'paid';
    
    return Card(
      margin: EdgeInsets.only(bottom: context.spacing),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () => _showSalaryDetail(salary),
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.scale(12)),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_outline : Icons.pending_actions,
                  color: isPaid ? Colors.green : Colors.orange,
                  size: context.scale(24),
                ),
              ),
              SizedBox(width: context.spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salary.month ?? "Salary Slip",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: context.font(16),
                      ),
                    ),
                    Text(
                      "Paid: ${salary.paymentDate ?? 'Pending'}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: context.font(13),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${salary.amount}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                    ),
                  ),
                  SizedBox(height: context.scale(4)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
                    decoration: BoxDecoration(
                      color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(4)),
                    ),
                    child: Text(
                      salary.status.toUpperCase(),
                      style: TextStyle(
                        color: isPaid ? Colors.green : Colors.orange,
                        fontSize: context.font(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(BuildContext context, accountant_model.UserDetail employeeDetail) {
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(8)),
                Text(
                  "Bank Details",
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: context.scale(24), color: theme.colorScheme.outlineVariant),
            _bankDetailRow(context, "Bank Name", employeeDetail.bankName ?? "Not Set"),
            _bankDetailRow(context, "Account No", employeeDetail.bankAccountNumber ?? "Not Set"),
            _bankDetailRow(context, "IFSC Code", employeeDetail.ifscCode ?? "Not Set"),
            _bankDetailRow(context, "Branch", employeeDetail.branchName ?? "Not Set"),
          ],
        ),
      ),
    );
  }

  Widget _bankDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.theme.textTheme.bodySmall?.copyWith(color: context.theme.hintColor)),
          Text(value, style: context.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(40.0)),
        child: Column(
          children: [
            Icon(Icons.payments_outlined, size: context.scale(64), color: theme.hintColor.withValues(alpha: 0.3)),
            SizedBox(height: context.scale(16)),
            Text(
              "No salary records found",
              style: TextStyle(color: theme.hintColor, fontSize: context.font(14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalaryDetail(accountant_model.Salary salary) {
    final theme = context.theme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final id = salary.encryptedId ?? salary.id.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
          ),
          padding: EdgeInsets.fromLTRB(context.scale(24), context.scale(12), context.scale(24), context.scale(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(600)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.scale(40),
                  height: context.scale(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(context.scale(2)),
                  ),
                  margin: EdgeInsets.only(bottom: context.scale(24)),
                ),
                Text(
                  "Salary Slip Detail",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.scale(24)),
                StreamBuilder<Map<String, dynamic>>(
                  stream: ApiService.getAccountantSalaryDetailStream(id, employeeId: widget.employeeId),
                  builder: (context, snapshot) {
                    return LoadingWrapper<Map<String, dynamic>>(
                      snapshot: snapshot,
                      skeleton: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(6, (index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: context.spacing / 1.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Skeleton(width: context.scale(80), height: context.scale(14)),
                              Skeleton(width: context.scale(100), height: context.scale(14)),
                            ],
                          ),
                        )),
                      ),
                      builder: (dataMap) {
                        final data = dataMap['salary'] ?? (dataMap.containsKey('id') ? dataMap : {});
                        final amountInWords = dataMap['amount_in_words'] ?? '';

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _detailRow(context, "Month/Year", "${data['month'] ?? salary.month ?? 'N/A'}/${data['year'] ?? salary.year ?? 'N/A'}"),
                            _detailRow(context, "Basic Pay", "₹${data['basic_salary'] ?? data['amount'] ?? salary.amount ?? '0'}"),
                            _detailRow(context, "Allowances", "₹${data['allowances'] ?? '0'}"),
                            _detailRow(context, "Deductions", "₹${data['deductions'] ?? '0'}"),
                            Divider(height: context.scale(24), color: theme.colorScheme.outlineVariant),
                            _detailRow(context, "Net Salary", "₹${data['net_salary'] ?? data['amount'] ?? salary.amount ?? '0'}", isBold: true),
                            if (amountInWords.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: context.scale(8.0)),
                                child: Text(
                                  amountInWords,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontStyle: FontStyle.italic,
                                    fontSize: context.font(13),
                                  ),
                                ),
                              ),
                            _detailRow(context, "Payment Date", data['payment_date'] ?? salary.paymentDate ?? "N/A"),
                            _detailRow(context, "Status", salary.status),
                            SizedBox(height: context.scale(24)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  PdfService.generateSalaryPdf(salary, amountInWords);
                                },
                                icon: const Icon(Icons.download),
                                label: const Text("DOWNLOAD PAYSLIP"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondaryContainer,
                                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.scale(12)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: context.scale(32)),
                Row(
                  children: [
                    if (widget.employeeId != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Salary Slip"),
                                content: const Text("Are you sure you want to delete this salary record?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("DELETE", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await ApiService.deleteAccountantSalary(id);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _fetchSalaries();
                                }
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text("DELETE", style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                          ),
                        ),
                      ),
                    if (widget.employeeId != null) SizedBox(width: context.scale(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                        ),
                        child: const Text("CLOSE"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.spacing / 1.5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateSalaryDialog() {
    final basicController = TextEditingController();
    final dateController = TextEditingController();
    String? selectedMonth;
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generate Salary"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(400)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel(context, "Month"),
                StatefulBuilder(
                  builder: (context, setDialogState) => buildDropdown(
                    context,
                    months,
                    selectedMonth,
                    (val) => setDialogState(() => selectedMonth = val),
                    hint: "Select Month",
                  ),
                ),
                buildLabel(context, "Basic Salary"),
                buildTextField(context, basicController, "Enter Basic Salary", prefixIcon: Icons.currency_rupee),
                buildLabel(context, "Payment Date"),
                buildDateField(context, dateController, "Select Payment Date"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (selectedMonth == null || basicController.text.isEmpty) return;
              try {
                String paymentDate = dateController.text;
                if (paymentDate.isNotEmpty) {
                  try {
                    final date = DateFormat('dd-MM-yyyy').parse(paymentDate);
                    paymentDate = DateFormat('yyyy-MM-dd').format(date);
                  } catch (_) {}
                }

                await ApiService.storeAccountantEmployeeSalary(widget.employeeId!, {
                  'month': selectedMonth,
                  'year': DateTime.now().year,
                  'basic_salary': double.parse(basicController.text),
                  'payment_date': paymentDate,
                });
                if (context.mounted) {
                   Navigator.pop(context);
                   _fetchSalaries();
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("GENERATE"),
          ),
        ],
      ),
    );
  }
}
