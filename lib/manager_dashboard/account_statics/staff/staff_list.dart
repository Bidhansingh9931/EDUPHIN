import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/staff/add_staff.dart';
import 'package:eduphin/services/api_service.dart';
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

  Staff({required this.id, required this.name, required this.designation});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Staff',
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

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];

        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        final staffRoles = allRoles.where((role) => role.id != 6).toList();
        final displayRoles = [Role(id: 0, name: "All Staff"), ...staffRoles];

        if (mounted) {
          setState(() {
            _roles = displayRoles;
            _selectedRoleId = displayRoles.first.id;
          });
          await _fetchStaffForRole(_selectedRoleId!);
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

  Future<void> _fetchStaffForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _staff = [];
    });

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

      if (mounted) {
        setState(() {
          _staff = allFetchedStaff;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStaffPage()),
          );
          if (result == true && mounted) _fetchStaffForRole(_selectedRoleId!);
        },
        label: const Text("Add Staff"),
        icon: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Staff List"),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadStaffList),
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
                staff: _staff,
                roles: _roles,
                selectedRoleId: _selectedRoleId,
                onRoleChanged: (int? newRoleId) {
                  if (newRoleId != null) {
                    setState(() => _selectedRoleId = newRoleId);
                    _fetchStaffForRole(newRoleId);
                  }
                },
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
  final List<Staff> staff;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;

  const CustomStaffListBox({
    super.key,
    required this.isLoading,
    required this.staff,
    required this.roles,
    required this.selectedRoleId,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: selectedRoleId,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
              isExpanded: true,
              onChanged: onRoleChanged,
              items: roles.map((role) => DropdownMenuItem(value: role.id, child: Text(role.name))).toList(),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                : _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (staff.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No staff found.")));
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) => _buildStaffItem(context, staff[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staff.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildStaffItem(context, staff[index]),
          );
        }
      },
    );
  }

  Widget _buildStaffItem(BuildContext context, Staff staffMember) {
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
                Text(staffMember.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(staffMember.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
