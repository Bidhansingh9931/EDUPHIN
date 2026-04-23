import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/accountant/add_accountant.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
 // Added responsive helper
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
  final String? photo;

  Accountant({required this.id, required this.name, required this.designation, this.photo});

  factory Accountant.fromJson(Map<String, dynamic> json) {
    return Accountant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'N/A',
      designation: json['designation']?.toString() ?? 'Accountant', // API doesn't provide a specific designation
      photo: (json['photo'] ?? json['profile_image'])?.toString(),
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
  Object? _error;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Accountant> _accountants = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchInitialData());
  }

  Future<void> _loadCachedData() async {
    final rolesCache = await CacheService.getCache('accountant_roles');
    if (rolesCache != null && mounted) {
      final List<dynamic> rolesData = rolesCache;
      final List<Role> allRoles = rolesData
          .map((role) => Role(id: role['role_id'], name: role['name']))
          .toList();
      final accountantRoles = allRoles.where((role) => role.name.toLowerCase().contains('accountant')).toList();

      if (mounted) {
        setState(() {
          _roles = accountantRoles;
          if (_roles.isNotEmpty) _selectedRoleId = _roles.first.id;
        });
      }

      if (_selectedRoleId != null) {
        final accountantCache = await CacheService.getCache('accountants_$_selectedRoleId');
        if (accountantCache != null && mounted) {
          setState(() {
            _accountants = (accountantCache as List).map((json) => Accountant.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    if (_roles.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        await CacheService.setCache('accountant_roles', rolesData);
        
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
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAccountantsForRole(int roleId) async {
    if (!mounted) return;
    if (_accountants.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> accountantsData = data['data'];
        await CacheService.setCache('accountants_$roleId', accountantsData);

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
        setState(() {
          _error = e;
          _isLoading = false;
        });
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
    final theme = context.theme;
    
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
          label: Text("Add Accountant", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
          icon: Icon(Icons.add, size: context.scale(20)),
        ),
        appBar: AppBar(
          title: Text("Accountant List", style: theme.appBarTheme.titleTextStyle),
          actions: [
             IconButton(
                icon: Icon(Icons.download, size: context.scale(24)),
                onPressed: _downloadAccountantList,
                tooltip: "Download CSV",
              ),
          ],
        ),
        body: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _accountants.isNotEmpty || _roles.isNotEmpty,
          error: _error,
          onRetry: _fetchInitialData,
          skeleton: _buildSkeleton(context),
          child: SafeArea(
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
          )),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = context.theme;
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                children: [
                  SkeletonBox(height: context.scale(56), borderRadius: context.scale(12)),
                  SizedBox(height: context.scale(24)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: context.scale(16),
                      mainAxisSpacing: context.scale(16),
                      mainAxisExtent: context.scale(80),
                    ),
                    itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.all(context.scale(12)),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                      child: Row(
                        children: [
                          SkeletonBox(
                            width: context.scale(48),
                            height: context.scale(48),
                            borderRadius: context.scale(24),
                          ),
                          SizedBox(width: context.scale(16)),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SkeletonBox(height: 16),
                                SizedBox(height: 4),
                                SkeletonBox(height: 12, width: 80),
                              ],
                            ),
                          ),
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
    );
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
    final theme = context.theme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Selector
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedRoleId,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: context.scale(24)),
                  onChanged: onRoleChanged,
                  dropdownColor: theme.cardColor,
                  items: roles.map<DropdownMenuItem<int>>((Role role) {
                    return DropdownMenuItem<int>(
                      value: role.id,
                      child: Row(
                        children: [
                          Icon(Icons.badge_outlined, size: context.scale(20), color: theme.colorScheme.primary),
                          SizedBox(width: context.scale(12)),
                          Text(
                            role.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: context.font(16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: context.scale(24)),
            
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.theme;
    
    if (accountants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(40)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_off_outlined, size: context.scale(48), color: theme.colorScheme.outline),
              SizedBox(height: context.scale(16)),
              Text(
                "No accountants found for this role.",
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
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
              crossAxisSpacing: context.scale(16),
              mainAxisSpacing: context.scale(16),
              mainAxisExtent: context.scale(80), // Fixed height for grid items
            ),
            itemBuilder: (context, index) => _buildAccountantItem(context, accountants[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accountants.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) => _buildAccountantItem(context, accountants[index]),
          );
        }
      },
    );
  }

  Widget _buildAccountantItem(BuildContext context, Accountant accountant) {
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.all(context.scale(12)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            radius: context.scale(24),
            imageUrl: ApiService.getStorageUrl(accountant.photo),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accountant.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(16),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  accountant.designation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: context.font(12),
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Action for individual accountant if needed
            },
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: context.scale(20)),
          ),
        ],
      ),
    );
  }
}


