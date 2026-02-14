import 'dart:async';
import 'dart:convert';
import 'package:eduphin/moderator_dashboard/dashboard_cards/add_account.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employ_details.dart';
import 'package:eduphin/services/api_service.dart';
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
    final future = _provider.fetchAccounts(widget.instituteId);
    if (mounted) {
      setState(() {
        _accountsFuture = future;
      });
    }
    future.then((accounts) {
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _filterAccounts(); // Re-apply filter
        });
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing accounts: $error')),
        );
      }
    });
  }

  Future<String?> _selectRoleDialog() async {
    final theme = Theme.of(context);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Select Role', style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text('Manager', style: theme.textTheme.bodyLarge), onTap: () => Navigator.of(context).pop('2')),
              ListTile(title: Text('Teacher', style: theme.textTheme.bodyLarge), onTap: () => Navigator.of(context).pop('3')),
              ListTile(title: Text('Librarian', style: theme.textTheme.bodyLarge), onTap: () => Navigator.of(context).pop('4')),
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Accounts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                filled: true,
                fillColor: isDarkMode ? theme.colorScheme.surface : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && _allAccounts.isEmpty) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)));
          }
          if (_allAccounts.isEmpty) {
            return Center(child: Text('No accounts found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)));
          }

          final accounts = _filteredAccounts;
          if(accounts.isEmpty && _searchController.text.isNotEmpty) {
            return Center(child: Text('No accounts found for your search.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)));
          }


          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 900 ? 3 : 2);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(screenSize.width * 0.04, screenSize.width * 0.04, screenSize.width * 0.04, 50),
                  itemCount: accounts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, index) {
                    return AccountCard(
                      account: accounts[index],
                      isGridView: true,
                    );
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 50),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    return AccountCard(
                      account: accounts[index],
                      isGridView: false,
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAccount,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final Account account;
  final bool isGridView;

  const AccountCard({
    super.key,
    required this.account,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    double responsiveFontSize(double baseSize) {
      if (screenSize.width > 1200) return baseSize * 1.2;
      if (screenSize.width > 600) return baseSize * 1.1;
      return baseSize;
    }

    final cardContent = isGridView
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: responsiveFontSize(22),
                backgroundColor: theme.scaffoldBackgroundColor,
                child: Icon(Icons.person_outline, color: theme.colorScheme.onSurface, size: responsiveFontSize(24)),
              ),
              const SizedBox(height: 12),
              Text(
                account.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(14),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                account.email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: responsiveFontSize(12),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        : ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.scaffoldBackgroundColor,
              child: Icon(Icons.person_outline, color: theme.colorScheme.onSurface, size: responsiveFontSize(22)),
            ),
            title: Text(
              account.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(16),
              ),
            ),
            subtitle: Text(
              account.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: responsiveFontSize(14),
              ),
            ),
          );

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: isGridView ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: screenSize.width * 0.04, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailsPage(employeeId: account.id.toString()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isGridView ? 16 : 8),
          child: cardContent,
        ),
      ),
    );
  }
}
