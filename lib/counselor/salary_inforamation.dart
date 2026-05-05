import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/error_handler.dart';
import '../services/caching_service.dart';
import '../services/common_widgets.dart';
import 'counselor_models.dart';
import 'salary_detail.dart';

class SalaryBankPage extends StatefulWidget {
  const SalaryBankPage({super.key});

  @override
  State<SalaryBankPage> createState() => _SalaryBankPageState();
}

class _SalaryBankPageState extends State<SalaryBankPage> {
  bool _isLoading = true;
  UserDetail? _userDetail;
  List<Salary> _salaryHistory = [];
  String? _errorMessage;
  final String _cacheKey = 'counselor_salary_bank_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchSalaryData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      final data = cachedData['data'] ?? cachedData;
      setState(() {
        if (data['account'] != null) {
          _userDetail = UserDetail.fromJson(data['account']);
        }
        if (data['salaries'] != null) {
          _salaryHistory = (data['salaries'] as List).map((json) => Salary.fromJson(json)).toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSalaryData() async {
    if (_salaryHistory.isEmpty && _userDetail == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/salaries');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          final salaryData = data['data'];
          setState(() {
            if (salaryData['account'] != null) {
              _userDetail = UserDetail.fromJson(salaryData['account']);
            }
            if (salaryData['salaries'] != null) {
              _salaryHistory = (salaryData['salaries'] as List).map((json) => Salary.fromJson(json)).toList();
            }
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted) {
          if (_salaryHistory.isEmpty && _userDetail == null) {
            setState(() {
              _errorMessage = ErrorHandler.getMessage("Status: ${response.statusCode}");
              _isLoading = false;
            });
          }
          ErrorHandler.showError(context, "Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        if (_salaryHistory.isEmpty && _userDetail == null) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage(e);
            _isLoading = false;
          });
        }
        ErrorHandler.showError(context, e);
      }
    }
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.scale(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Skeleton(width: 120, height: 16),
                          Skeleton(width: 60, height: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Skeleton(width: 150, height: 40),
                      const SizedBox(height: 32),
                      Row(
                        children: const [
                          Skeleton(width: 100, height: 14),
                          Spacer(),
                          Skeleton(width: 100, height: 14),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Skeleton(width: 180, height: 20),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Skeleton(width: 24, height: 24),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Skeleton(width: 100, height: 12),
                              SizedBox(height: 4),
                              Skeleton(width: 150, height: 16),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Skeleton(width: 150, height: 20),
              const SizedBox(height: 16),
              ...List.generate(3, (index) => const Card(margin: EdgeInsets.only(bottom: 12), child: ListTile(title: Skeleton(width: 200, height: 16)))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final lastSalary = _salaryHistory.isNotEmpty ? _salaryHistory.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Salary & Bank", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSalaryData,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _salaryHistory.isNotEmpty || _userDetail != null,
          error: _errorMessage,
          skeleton: _buildSkeleton(),
          onRetry: _fetchSalaryData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SALARY SUMMARY CARD
                    Card(
                      elevation: 0,
                      color: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(16)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(context.scale(16)),
                        onTap: lastSalary != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalaryDetailPage(salaryId: lastSalary.id))) : null,
                        child: Padding(
                          padding: EdgeInsets.all(context.scale(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Last Paid Amount",
                                    style: TextStyle(
                                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                      fontSize: context.font(14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(context.scale(20)),
                                    ),
                                    child: Text(
                                      lastSalary?.status.toUpperCase() ?? "N/A",
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: context.font(10),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.scale(12)),
                              Text(
                                lastSalary != null ? "₹${lastSalary.amount}" : "₹0.00",
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: context.font(36),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: context.scale(32)),
                              Row(
                                children: [
                                  _buildMiniInfo(context, "Payment Date", lastSalary?.paymentDate ?? "N/A"),
                                  const Spacer(),
                                  _buildMiniInfo(context, "For Month", lastSalary?.month ?? "N/A"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.scale(32)),

                    _buildSectionTitle(context, "Bank Account Details"),
                    SizedBox(height: context.scale(16)),
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(16)),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.scale(8)),
                        child: Column(
                          children: [
                            _buildDetailRow(context, Icons.person_outline, "Account Holder", _userDetail?.fullName ?? "N/A"),
                            _buildDetailRow(context, Icons.account_balance, "Bank Name", _userDetail?.bankName ?? "N/A"),
                            _buildDetailRow(context, Icons.numbers, "Account Number", _userDetail?.bankAccountNumber ?? "N/A"),
                            _buildDetailRow(context, Icons.code, "IFSC Code", _userDetail?.ifscCode ?? "N/A"),
                            _buildDetailRow(context, Icons.location_on_outlined, "Branch", _userDetail?.branchName ?? "N/A", isLast: true),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.scale(32)),

                    _buildSectionTitle(context, "Salary History"),
                    SizedBox(height: context.scale(16)),
                    _salaryHistory.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _salaryHistory.length,
                            itemBuilder: (context, index) {
                              final salary = _salaryHistory[index];
                              return Card(
                                elevation: 0,
                                color: colorScheme.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  side: BorderSide(color: colorScheme.outlineVariant),
                                ),
                                margin: EdgeInsets.only(bottom: context.scale(12)),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalaryDetailPage(salaryId: salary.id))),
                                  contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(8)),
                                  leading: CircleAvatar(
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.receipt_long, color: colorScheme.primary, size: context.scale(20)),
                                  ),
                                  title: Text(
                                    "Salary for ${salary.month}",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                  ),
                                  subtitle: Text(
                                    "Paid on ${salary.paymentDate}",
                                    style: TextStyle(fontSize: context.font(12)),
                                  ),
                                  trailing: Text(
                                    "₹${salary.amount}",
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(16),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(BuildContext context, String label, String value) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onPrimary.withValues(alpha: 0.7),
            fontSize: context.font(11),
          ),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: context.font(14),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: context.scale(4)),
      child: Text(
        title,
        style: context.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: context.font(16),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isLast = false}) {
    final theme = context.theme;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(16)),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: context.scale(22)),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: context.font(11),
                      ),
                    ),
                    SizedBox(height: context.scale(4)),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.font(15),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (!isLast)
          Divider(
            indent: context.scale(54),
            endIndent: context.scale(16),
            color: theme.dividerColor.withValues(alpha: 0.5),
            height: 1,
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(60)),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: context.scale(64),
              color: context.theme.hintColor.withValues(alpha: 0.3),
            ),
            SizedBox(height: context.scale(16)),
            Text(
              "No Records Yet",
              style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14)),
            ),
          ],
        ),
      ),
    );
  }
}


