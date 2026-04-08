import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/institute_manager/add_manager.dart';
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

class Manager {
  final int id;
  final String name;
  final String designation;

  Manager({required this.id, required this.name, required this.designation});

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Manager',
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

        final managerRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('manager')
        ).toList();

        if (managerRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = managerRoles;
              _selectedRoleId = managerRoles.first.id;
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchManagersForRole(int roleId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> managersData = data['data'];
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddManagerPage()),
          );
          if (result == true && mounted) _fetchManagersForRole(_selectedRoleId!);
        },
        label: const Text("Add Manager"),
        icon: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Manager List"),
        actions: [
            IconButton(icon: const Icon(Icons.download), onPressed: _downloadManagerList),
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
                managers: _managers,
                roles: _roles,
                selectedRoleId: _selectedRoleId,
                onRoleChanged: (int? newRoleId) {
                  if (newRoleId != null) {
                    setState(() => _selectedRoleId = newRoleId);
                    _fetchManagersForRole(newRoleId);
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

class CustomManagerListBox extends StatelessWidget {
  final bool isLoading;
  final List<Manager> managers;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;

  const CustomManagerListBox({
    super.key,
    required this.isLoading,
    required this.managers,
    required this.roles,
    required this.selectedRoleId,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
    if (managers.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No managers found.")));
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) => _buildManagerItem(context, managers[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: managers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildManagerItem(context, managers[index]),
          );
        }
      },
    );
  }

  Widget _buildManagerItem(BuildContext context, Manager manager) {
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
                Text(manager.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(manager.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
