import 'dart:async';
import 'dart:convert';
import 'package:eduphin/moderator_dashboard/dashboard_cards/add_account.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employ_details.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// 1. Data Model for an Account
class Account {
  final int id;
  final String name;
  final String email;

  Account({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
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
    final theme = Theme.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.manage_accounts_rounded),
                title: const Text('Manager'), 
                onTap: () => Navigator.of(context).pop('2')
              ),
              ListTile(
                leading: const Icon(Icons.school_rounded),
                title: const Text('Teacher'), 
                onTap: () => Navigator.of(context).pop('3')
              ),
              ListTile(
                leading: const Icon(Icons.local_library_rounded),
                title: const Text('Librarian'), 
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _allAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && _allAccounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load accounts', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _refreshAccounts, child: const Text("Retry")),
                ],
              ),
            );
          }
          if (_allAccounts.isEmpty) {
            return _buildEmptyState(theme, "No accounts found");
          }

          final accounts = _filteredAccounts;
          if(accounts.isEmpty && _searchController.text.isNotEmpty) {
            return _buildEmptyState(theme, "No results for \"${_searchController.text}\"");
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshAccounts(),
            child: SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 90,
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
        icon: const Icon(Icons.person_add_rounded),
        label: const Text("Add Account"),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: Text(
            account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          account.email,
          style: TextStyle(color: theme.hintColor, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
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
