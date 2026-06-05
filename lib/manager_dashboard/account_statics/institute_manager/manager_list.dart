import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/institute_manager/add_manager.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Role {
  final int id;
  final String name;
  Role({required this.id, required this.name});
}

class Manager {
  final int id;
  final String name;
  final String designation;
  final String? photo;

  Manager({required this.id, required this.name, required this.designation, this.photo});

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Manager',
      photo: json['photo'] ?? json['profile_image'],
    );
  }
}

class ManagerListPage extends StatefulWidget {
  const ManagerListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ManagerListPageState();
}

class _ManagerListPageState extends State<ManagerListPage> {
  bool _isLoading = true;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Manager> _managers = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    // 1. Load cached roles
    final cachedRolesData = await CacheService.getCache('manager_roles');
    if (cachedRolesData != null) {
      final List<dynamic> rolesData = cachedRolesData;
      final List<Role> allRoles = rolesData
          .map((role) => Role(id: role['role_id'], name: role['name']))
          .toList();
      final managerRoles = allRoles.where((role) => 
        role.name.toLowerCase().contains('manager')
      ).toList();

      if (managerRoles.isNotEmpty && mounted) {
        setState(() {
          _roles = managerRoles;
          _selectedRoleId = managerRoles.first.id;
        });
        // 2. Load cached managers for the first role
        final cachedManagersData = await CacheService.getCache('managers_${_selectedRoleId}');
        if (cachedManagersData != null && mounted) {
          setState(() {
            _managers = (cachedManagersData as List).map((json) => Manager.fromJson(json)).toList();
          });
        }
      }
    }

    // 3. Fetch fresh data
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        
        // Cache roles
        await CacheService.setCache('manager_roles', rolesData);

        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        final managerRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('manager')
        ).toList();

        if (managerRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = managerRoles;
              _selectedRoleId = _selectedRoleId ?? managerRoles.first.id;
            });
            await _fetchManagersForRole(_selectedRoleId!);
          }
        } else {
          if(mounted) setState(() => _isLoading = false);
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

  Future<void> _fetchManagersForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Try to load cache for this specific role if we haven't already (or always to be safe)
    if (_managers.isEmpty) {
      final cachedManagersData = await CacheService.getCache('managers_$roleId');
      if (cachedManagersData != null && mounted) {
        setState(() {
          _managers = (cachedManagersData as List).map((json) => Manager.fromJson(json)).toList();
        });
      }
    }

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> managersData = data['data'];
        
        // Cache managers for this role
        await CacheService.setCache('managers_$roleId', managersData);

        if(mounted){
          setState(() {
            _managers = managersData.map((json) => Manager.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load managers');
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

  Future<void> _downloadManagerList() async {
    if (_managers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to download.")));
      return;
    }

    List<List<dynamic>> rows = [['ID', 'Name', 'Designation']];
    for (var manager in _managers) {
      rows.add([manager.id, manager.name, manager.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/manager_list.csv';
      final file = File(path);
      await file.writeAsString(csv);
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download failed: $e")));
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
            MaterialPageRoute(builder: (context) => const AddManagerPage()),
          );
          if (result == true && mounted) _fetchManagersForRole(_selectedRoleId!);
        },
        label: Text("Add Manager", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      appBar: AppBar(
        title: Text("Manager List", style: theme.appBarTheme.titleTextStyle),
        actions: [
            IconButton(icon: Icon(Icons.download, size: context.scale(24)), onPressed: _downloadManagerList),
          ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomManagerListBox(
                isLoading: _isLoading,
                error: _error,
                managers: _managers,
                roles: _roles,
                selectedRoleId: _selectedRoleId,
                onRoleChanged: (int? newRoleId) {
                  if (newRoleId != null) {
                    setState(() => _selectedRoleId = newRoleId);
                    _fetchManagersForRole(newRoleId);
                  }
                },
                onRetry: _fetchInitialData,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomManagerListBox extends StatelessWidget {
  final bool isLoading;
  final Object? error;
  final List<Manager> managers;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;
  final VoidCallback onRetry;

  const CustomManagerListBox({
    super.key,
    required this.isLoading,
    this.error,
    required this.managers,
    required this.roles,
    required this.selectedRoleId,
    required this.onRoleChanged,
    required this.onRetry,
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
            DropdownButtonFormField<int>(
              value: selectedRoleId,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined, size: context.scale(20)),
                contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16)),
              ),
              isExpanded: true,
              onChanged: onRoleChanged,
              dropdownColor: theme.cardColor,
              items: roles.map((role) => DropdownMenuItem(value: role.id, child: Text(role.name, style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(16))))).toList(),
            ),
            SizedBox(height: context.scale(24)),
            LoadingWrapper(
              isLoading: isLoading,
              hasData: managers.isNotEmpty,
              error: error,
              onRetry: onRetry,
              skeleton: _buildSkeleton(context),
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.scale(16),
              mainAxisSpacing: context.scale(16),
              mainAxisExtent: context.scale(80),
            ),
            itemBuilder: (context, index) => _buildSkeletonItem(context),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) => _buildSkeletonItem(context),
          );
        }
      },
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final theme = context.theme;
    return Container(
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
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.theme;
    if (managers.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.all(context.scale(40)), child: Text("No managers found.", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)))));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
        
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: managers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.scale(16),
              mainAxisSpacing: context.scale(16),
              mainAxisExtent: context.scale(80),
            ),
            itemBuilder: (context, index) => _buildManagerItem(context, managers[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: managers.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) => _buildManagerItem(context, managers[index]),
          );
        }
      },
    );
  }

  Widget _buildManagerItem(BuildContext context, Manager manager) {
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
            imageUrl: ApiService.getStorageUrl(manager.photo),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(manager.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(manager.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: context.scale(20)),
        ],
      ),
    );
  }
}


