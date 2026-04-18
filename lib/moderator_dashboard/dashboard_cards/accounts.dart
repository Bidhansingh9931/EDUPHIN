import 'dart:async';
import 'dart:convert';
import 'package:eduphin/moderator_dashboard/dashboard_cards/add_account.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employ_details.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// 1. Data Model for an Account
class Account {
  final int id;
  final String name;
  final String email;
  final String? imageUrl;

  Account({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      imageUrl: ApiService.getStorageUrl(json['photo']),
    );
  }
}

// 2. Data Provider to fetch account data from the API
class AccountProvider {
  Future<List<Account>> fetchAccounts(String instituteId) async {
    try {
      final response = await ApiService.get('moderator/institutes/$instituteId/accounts');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['accounts'] != null) {
          final List<dynamic> accountsJson = data['accounts'];
          return accountsJson.map((json) => Account.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load accounts.');
        }
      } else {
        throw Exception('Failed to load accounts. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch accounts: $e');
    }
  }
}

// 3. StatefulWidget now accepts instituteId
class AccountsPage extends StatefulWidget {
  final String instituteId;
  const AccountsPage({super.key, required this.instituteId});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountProvider _provider = AccountProvider();
  late Future<List<Account>> _accountsFuture;
  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _searchController.addListener(_filterAccounts);
  }

  void _fetchAccounts() {
    _accountsFuture = _provider.fetchAccounts(widget.instituteId);
    _accountsFuture.then((accounts) {
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _filteredAccounts = accounts;
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching accounts: $error')),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAccounts = _allAccounts.where((account) {
        final nameLower = account.name.toLowerCase();
        final emailLower = account.email.toLowerCase();
        return nameLower.contains(query) || emailLower.contains(query);
      }).toList();
    });
  }

  void _refreshAccounts() {
    _fetchAccounts();
  }

  Future<String?> _selectRoleDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final theme = context.theme;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          surfaceTintColor: Colors.transparent,
          title: Text('Select Role', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.md),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.manage_accounts_rounded, size: context.scale(24), color: theme.colorScheme.primary),
                title: Text('Manager', style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurface)),
                onTap: () => Navigator.of(context).pop('2')
              ),
              ListTile(
                leading: Icon(Icons.school_rounded, size: context.scale(24), color: theme.colorScheme.primary),
                title: Text('Teacher', style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurface)), 
                onTap: () => Navigator.of(context).pop('3')
              ),
              ListTile(
                leading: Icon(Icons.local_library_rounded, size: context.scale(24), color: theme.colorScheme.primary),
                title: Text('Librarian', style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurface)), 
                onTap: () => Navigator.of(context).pop('4')
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddAccount() async {
    final selectedRoleId = await _selectRoleDialog();
    if (selectedRoleId == null || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAccountPage(
        instituteId: widget.instituteId,
        roleId: selectedRoleId,
      )),
    );
    if (result == true && mounted) {
      _refreshAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Manage Accounts', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(context.scale(70)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.md, 0, context.md, context.sm),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.sm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allAccounts.isEmpty) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          if (snapshot.hasError && _allAccounts.isEmpty) {
            return Center(
              child: Padding(
                padding: context.pagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: context.scale(48), color: colorScheme.error),
                    SizedBox(height: context.md),
                    Text('Failed to load accounts', style: theme.textTheme.titleMedium?.copyWith(fontSize: context.font(18), color: theme.colorScheme.onSurface)),
                    SizedBox(height: context.lg),
                    ElevatedButton(
                      onPressed: _refreshAccounts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
                      ),
                      child: Text("Retry", style: TextStyle(fontSize: context.font(16))),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_allAccounts.isEmpty) {
            return _buildEmptyState(context, "No accounts found");
          }

          final accounts = _filteredAccounts;
          if(accounts.isEmpty && _searchController.text.isNotEmpty) {
            return _buildEmptyState(context, "No results for \"${_searchController.text}\"");
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshAccounts(),
            child: SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(1200)),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: context.md,
                      mainAxisSpacing: context.md,
                      mainAxisExtent: context.scale(100),
                    ),
                    itemBuilder: (context, index) {
                      return AccountCard(account: accounts[index]);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAccount,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: Icon(Icons.person_add_rounded, size: context.scale(24)),
        label: Text("Add Account", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: context.md),
          Text(message, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        leading: ProfileAvatar(
          imageUrl: account.imageUrl,
          radius: context.scale(20),
        ),
        title: Text(
          account.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(15), color: theme.colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          account.email,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: context.scale(24), color: theme.colorScheme.onSurfaceVariant),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailsPage(employeeId: account.id.toString()),
            ),
          );
        },
      ),
    );
  }
}
