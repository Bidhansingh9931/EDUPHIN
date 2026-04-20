import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/staff/add_staff.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Role {
  final int id;
  final String name;
  Role({required this.id, required this.name});
}

class Staff {
  final int id;
  final String name;
  final String designation;
  final String? photo;

  Staff({required this.id, required this.name, required this.designation, this.photo});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Staff',
      photo: json['photo'] ?? json['profile_image'],
    );
  }
}

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StatefulWidget> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  bool _isLoading = true;
  int? _selectedRoleId = 0;
  List<Role> _roles = [];
  List<Staff> _staff = [];
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
      final staffRoles = allRoles.where((role) => role.id != 6).toList();
      final displayRoles = [Role(id: 0, name: "All Staff"), ...staffRoles];

      if (mounted) {
        setState(() {
          _roles = displayRoles;
          _selectedRoleId = 0;
        });
        
        // 2. Load cached staff for 'All Staff' (roleId 0)
        final cachedStaffData = await CacheService.getCache('staff_list_0');
        if (cachedStaffData != null && mounted) {
          setState(() {
            _staff = (cachedStaffData as List).map((json) => Staff.fromJson(json)).toList();
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
        
        await CacheService.setCache('manager_roles', rolesData);

        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        final staffRoles = allRoles.where((role) => role.id != 6).toList();
        final displayRoles = [Role(id: 0, name: "All Staff"), ...staffRoles];

        if (mounted) {
          setState(() {
            _roles = displayRoles;
            _selectedRoleId = _selectedRoleId ?? displayRoles.first.id;
          });
          await _fetchStaffForRole(_selectedRoleId!);
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

  Future<void> _fetchStaffForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Load cache for specific role
    if (_staff.isEmpty) {
      final cachedStaffData = await CacheService.getCache('staff_list_$roleId');
      if (cachedStaffData != null && mounted) {
        setState(() {
          _staff = (cachedStaffData as List).map((json) => Staff.fromJson(json)).toList();
        });
      }
    }

    try {
      List<Staff> allFetchedStaff = [];
      if (roleId == 0) {
        final staffRoleIds = _roles.where((r) => r.id != 0).map((r) => r.id).toList();
        for (int id in staffRoleIds) {
          final response = await ApiService.get('manager/users/$id');
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final List<dynamic> staffData = data['data'];
            allFetchedStaff.addAll(staffData.map((json) => Staff.fromJson(json)).toList());
          }
        }
      } else {
        final response = await ApiService.get('manager/users/$roleId');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> staffData = data['data'];
          allFetchedStaff = staffData.map((json) => Staff.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load staff');
        }
      }

      // Cache the result for this roleId
      await CacheService.setCache('staff_list_$roleId', allFetchedStaff.map((s) => {
        'id': s.id,
        'name': s.name,
        'designation': s.designation,
        'photo': s.photo
      }).toList());

      if (mounted) {
        setState(() {
          _staff = allFetchedStaff;
          _isLoading = false;
        });
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

  Future<void> _downloadStaffList() async {
    if (_staff.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to download.")));
      return;
    }

    List<List<dynamic>> rows = [['ID', 'Name', 'Designation']];
    for (var staffMember in _staff) {
      rows.add([staffMember.id, staffMember.name, staffMember.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/staff_list.csv';
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
            MaterialPageRoute(builder: (context) => const AddStaffPage()),
          );
          if (result == true && mounted) _fetchStaffForRole(_selectedRoleId!);
        },
        label: Text("Add Staff", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      appBar: AppBar(
        title: Text("Staff List", style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(icon: Icon(Icons.download, size: context.scale(24)), onPressed: _downloadStaffList),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomStaffListBox(
                isLoading: _isLoading,
                error: _error,
                staff: _staff,
                roles: _roles,
                selectedRoleId: _selectedRoleId,
                onRoleChanged: (int? newRoleId) {
                  if (newRoleId != null) {
                    setState(() => _selectedRoleId = newRoleId);
                    _fetchStaffForRole(newRoleId);
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

class CustomStaffListBox extends StatelessWidget {
  final bool isLoading;
  final Object? error;
  final List<Staff> staff;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;
  final VoidCallback onRetry;

  const CustomStaffListBox({
    super.key,
    required this.isLoading,
    this.error,
    required this.staff,
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
              hasData: staff.isNotEmpty,
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
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: context.scale(12)),
          child: SkeletonBox(height: context.scale(80), borderRadius: context.scale(12)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.theme;
    if (staff.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.all(context.scale(40)), child: Text("No staff found.", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)))));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
        
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staff.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.scale(16),
              mainAxisSpacing: context.scale(16),
              mainAxisExtent: context.scale(80),
            ),
            itemBuilder: (context, index) => _buildStaffItem(context, staff[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staff.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) => _buildStaffItem(context, staff[index]),
          );
        }
      },
    );
  }

  Widget _buildStaffItem(BuildContext context, Staff staffMember) {
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
            imageUrl: ApiService.getStorageUrl(staffMember.photo),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(staffMember.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(staffMember.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: context.scale(20)),
        ],
      ),
    );
  }
}


