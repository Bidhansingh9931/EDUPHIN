import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/accountant/add_accountant.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart'; // Added responsive helper
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});
}

class Accountant {
  final int id;
  final String name;
  final String designation;

  Accountant({required this.id, required this.name, required this.designation});

  factory Accountant.fromJson(Map<String, dynamic> json) {
    return Accountant(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Accountant', // API doesn't provide a specific designation
    );
  }
}

// ───────────────────────────────────────────────────────────
//                     ACCOUNTANT LIST PAGE
// ───────────────────────────────────────────────────────────

class AccountantListPage extends StatefulWidget {
  const AccountantListPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountantListPageState();
}

class _AccountantListPageState extends State<AccountantListPage> {
  bool _isLoading = true;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Accountant> _accountants = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        
        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        // Filter for roles that are considered 'accountants'
        final accountantRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('accountant')
        ).toList();

        if (accountantRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = accountantRoles;
              _selectedRoleId = accountantRoles.first.id;
            });
            await _fetchAccountantsForRole(_selectedRoleId!); // Fetch accountants for the default role
          }
        } else {
          if (mounted) setState(() => _isLoading = false); // No accountant roles found
        }
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAccountantsForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> accountantsData = data['data'];
        if(mounted){
          setState(() {
            _accountants = accountantsData.map((json) => Accountant.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load accountants for the selected role');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadAccountantList() async {
    if (_accountants.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No accountant data to download.")),
      );
      return;
    }

    // Convert accountant list to CSV
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['ID', 'Name', 'Designation']);
    // Add data rows
    for (var accountant in _accountants) {
      rows.add([accountant.id, accountant.name, accountant.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/accountant_list.csv';
      final file = File(path);

      // Write to file
      await file.writeAsString(csv);

      // Open file
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download accountant list: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAccountantPage()),
            );
            if (result == true && mounted) {
              _fetchAccountantsForRole(_selectedRoleId!); // Refresh list on return
            }
          },
          label: const Text("Add Accountant"),
          icon: const Icon(Icons.add),
          // Theme inherits automatically
        ),
        appBar: AppBar(
          title: const Text("Accountant List"),
          actions: [
             IconButton(
                icon: const Icon(Icons.download),
                onPressed: _downloadAccountantList,
                tooltip: "Download CSV",
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200), // Max width for large desktops
                child: CustomAccountantListBox(
                  isLoading: _isLoading,
                  accountants: _accountants,
                  roles: _roles,
                  selectedRoleId: _selectedRoleId,
                  onRoleChanged: (int? newRoleId) {
                    if (newRoleId != null) {
                      setState(() {
                        _selectedRoleId = newRoleId;
                      });
                      _fetchAccountantsForRole(newRoleId);
                    }
                  },
                ),
              ),
            ),
          ),
        ));
  }
}

// ───────────────────────────────────────────────────────────
//                    ACCOUNTANT LIST BOX
// ───────────────────────────────────────────────────────────

class CustomAccountantListBox extends StatelessWidget {
  final bool isLoading;
  final List<Accountant> accountants;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;

  const CustomAccountantListBox({
    super.key,
    required this.isLoading,
    required this.accountants,
    required this.roles,
    required this.selectedRoleId,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedRoleId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onChanged: onRoleChanged,
                  items: roles.map<DropdownMenuItem<int>>((Role role) {
                    return DropdownMenuItem<int>(
                      value: role.id,
                      child: Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            role.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Accountants List
            isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    if (accountants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_off_outlined, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                "No accountants found for this role.",
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Use Responsive Grid for Tablet/Desktop and List for Mobile
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
        
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accountants.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 80, // Fixed height for grid items
            ),
            itemBuilder: (context, index) => _buildAccountantItem(context, accountants[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accountants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildAccountantItem(context, accountants[index]),
          );
        }
      },
    );
  }

  Widget _buildAccountantItem(BuildContext context, Accountant accountant) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accountant.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  accountant.designation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Action for individual accountant if needed
            },
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
