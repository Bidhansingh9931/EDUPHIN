import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart';

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
          // Based on AccountController.php index method:
          // 'data' => [ 'accounts' => $accounts, 'roles' => $roles, 'institute' => $institute ]
          if (accountsData['status'] == true) {
            _accounts = accountsData['data']['accounts'] ?? [];
          } else {
             _accounts = [];
          }
          _institute = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_institute != null ? "Accounts: ${_institute!.name}" : "Manage Accounts"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ))
              : SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.manage_accounts, color: theme.colorScheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text("Account Directory", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTable(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTable(BuildContext context) {
    if (_accounts.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No accounts found for this institute."),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _accounts.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final account = entry.value;
          return DataRow(cells: [
            DataCell(Text(index.toString())),
            DataCell(Text(account['name'] ?? '')),
            DataCell(Text(account['email'] ?? '')),
            DataCell(Text(account['phone'] ?? '')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (account['status'] == 'live' ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  account['status'] ?? '',
                  style: TextStyle(
                    color: account['status'] == 'live' ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
