import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart';
import 'package:eduphin/superAdmin/cache_service.dart';
import 'package:eduphin/superAdmin/super_admin_common_widgets.dart';

class ManageAccountsScreen extends StatefulWidget {
  final String instituteId;
  const ManageAccountsScreen({super.key, required this.instituteId});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  List<dynamic> _accounts = [];
  Institute? _institute;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedAccounts = await SuperAdminCacheService.load('institute_accounts_${widget.instituteId}');
    final cachedInstitute = await SuperAdminCacheService.load('institute_details_${widget.instituteId}');
    if (cachedAccounts != null || cachedInstitute != null) {
      setState(() {
        if (cachedAccounts != null) _accounts = cachedAccounts;
        if (cachedInstitute != null) _institute = Institute.fromJson(cachedInstitute);
      });
    }
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get("superadmin/institutes/${widget.instituteId}/accounts");
      final data = await ApiService.getSuperAdminInstituteDetails(widget.instituteId);
      
      final accountsData = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          if (accountsData['status'] == true) {
            _accounts = accountsData['data']['accounts'] ?? [];
            SuperAdminCacheService.save('institute_accounts_${widget.instituteId}', _accounts);
          } else {
             _accounts = [];
          }
          _institute = data;
          if (data != null) {
            SuperAdminCacheService.save('institute_details_${widget.instituteId}', data.toJson());
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorHandler.getMessage(e);
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_institute != null ? "Accounts: ${_institute!.name}" : "Manage Accounts",
            style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
      ),
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _accounts.isNotEmpty || _institute != null,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
          onRefresh: _fetchAccounts,
          child: _errorMessage != null && _accounts.isEmpty
              ? Center(child: Padding(
                  padding: EdgeInsets.all(context.scale(24.0)),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                ))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.spacing),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.manage_accounts, color: theme.colorScheme.primary, size: context.scale(20)),
                                      SizedBox(width: context.scale(8)),
                                      Text("Account Directory", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                                    ],
                                  ),
                                  SizedBox(height: context.spacing),
                                  _buildTable(context),
                                ],
                              ),
                            ),
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

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SuperAdminSkeleton(width: 200, height: 24),
                  SizedBox(height: context.spacing),
                  ...List.generate(8, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SuperAdminSkeleton(height: 48),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    if (_accounts.isEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.all(context.scale(20.0)),
        child: Text("No accounts found for this institute.", style: TextStyle(fontSize: context.font(14))),
      ));
    }
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: context.screenWidth - (context.isMobile ? context.scale(64) : context.scale(100))),
          child: DataTable(
            columnSpacing: context.scale(24),
            horizontalMargin: context.scale(12),
            dataRowMinHeight: context.scale(48),
            dataRowMaxHeight: context.scale(60),
            headingRowHeight: context.scale(56),
            columns: [
              DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
              DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
              DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
              DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
              DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            ],
            rows: _accounts.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final account = entry.value;
              return DataRow(cells: [
                DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(account['name'] ?? '', style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(account['email'] ?? '', style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(account['phone'] ?? '', style: TextStyle(fontSize: context.font(13)))),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
                    decoration: BoxDecoration(
                      color: (account['status'] == 'live' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(4)),
                    ),
                    child: Text(
                      account['status'] ?? '',
                      style: TextStyle(
                        color: account['status'] == 'live' ? Colors.green : Colors.red,
                        fontSize: context.font(11),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
