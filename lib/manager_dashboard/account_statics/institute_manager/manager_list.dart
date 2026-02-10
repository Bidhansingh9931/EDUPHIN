import 'dart:convert';

import 'package:eduphin/manager_dashboard/account_statics/institute_manager/add_manager.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

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
      designation: json['designation'] ?? 'Manager', // API doesn't provide a specific designation
    );
  }
}

// ───────────────────────────────────────────────────────────
//                       MANAGER LIST PAGE
// ───────────────────────────────────────────────────────────

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
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch roles first to populate the dropdown
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        
        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        // Filter for roles that are considered 'managers'
        final managerRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('manager')
        ).toList();

        if (managerRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = managerRoles;
              _selectedRoleId = managerRoles.first.id;
            });
            await _fetchManagersForRole(_selectedRoleId!); // Fetch managers for the default role
          }
        } else {
          setState(() => _isLoading = false); // No manager roles found
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
    setState(() {
      _isLoading = true;
    });

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
        throw Exception('Failed to load managers for the selected role');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
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
            MaterialPageRoute(builder: (context) => const AddManagerPage()),
          );
          if (result == true && mounted) {
            _fetchManagersForRole(_selectedRoleId!); // Refresh list on return
          }
        },
        label: const Text("Add Manager"),
        icon: const Icon(Icons.add),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Manager List",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.download),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
          child: CustomManagerListBox(
            isLoading: _isLoading,
            managers: _managers,
            roles: _roles,
            selectedRoleId: _selectedRoleId,
            onRoleChanged: (int? newRoleId) {
              if (newRoleId != null) {
                setState(() {
                  _selectedRoleId = newRoleId;
                });
                _fetchManagersForRole(newRoleId);
              }
            },
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                      MANAGER LIST BOX
// ───────────────────────────────────────────────────────────

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: selectedRoleId,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: onRoleChanged,
              items: roles.map<DropdownMenuItem<int>>((Role role) {
                return DropdownMenuItem<int>(
                  value: role.id,
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline), // Prefix icon
                      const SizedBox(width: 8),
                      Text(
                        role.name,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (managers.isEmpty) {
                      return const Center(child: Text("No managers found for this role.", style: TextStyle(color: Colors.white),));
                    }

                    final isLargeScreen = constraints.maxWidth > 600;
                    if (isLargeScreen) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: managers.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                        ),
                        itemBuilder: (context, index) {
                          return _buildManagerItem(context, managers[index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: managers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildManagerItem(context, managers[index]);
                        },
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildManagerItem(BuildContext context, Manager manager) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  manager.name,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  manager.designation,
                  style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(180)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
