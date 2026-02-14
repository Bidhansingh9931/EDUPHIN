import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/staff/add_staff.dart';
import 'package:eduphin/services/api_service.dart';
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

class Staff {
  final int id;
  final String name;
  final String designation;

  Staff({required this.id, required this.name, required this.designation});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation:
          json['designation'] ?? 'Staff', // API doesn't provide a specific designation
    );
  }
}

// ───────────────────────────────────────────────────────────
//                       STAFF LIST PAGE
// ───────────────────────────────────────────────────────────

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StatefulWidget> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  bool _isLoading = true;
  int? _selectedRoleId = 0; // 0 for "All Staff"
  List<Role> _roles = [];
  List<Staff> _staff = [];

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

        // Filter for roles that are considered 'staff' (e.g., not students)
        final staffRoles = allRoles
            .where((role) =>
                role.id != 6 // Assuming 6 is Student
                )
            .toList();

        // Add "All Staff" option
        final displayRoles = [Role(id: 0, name: "All Staff"), ...staffRoles];

        if (mounted) {
          setState(() {
            _roles = displayRoles;
            _selectedRoleId = displayRoles.first.id;
          });
          await _fetchStaffForRole(
              _selectedRoleId!); // Fetch staff for the default role
        }
      } else {
        throw Exception('Failed to load roles');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
        // "All Staff" selected
        final staffRoleIds =
            _roles.where((r) => r.id != 0).map((r) => r.id).toList();
        for (int id in staffRoleIds) {
          final response = await ApiService.get('manager/users/$id');
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final List<dynamic> staffData = data['data'];
            allFetchedStaff.addAll(
                staffData.map((json) => Staff.fromJson(json)).toList());
          }
        }
      } else {
        final response = await ApiService.get('manager/users/$roleId');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> staffData = data['data'];
          allFetchedStaff =
              staffData.map((json) => Staff.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load staff for the selected role');
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadStaffList() async {
    if (_staff.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No staff data to download.")),
      );
      return;
    }

    // Convert staff list to CSV
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['ID', 'Name', 'Designation']);
    // Add data rows
    for (var staffMember in _staff) {
      rows.add([staffMember.id, staffMember.name, staffMember.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/staff_list.csv';
      final file = File(path);

      // Write to file
      await file.writeAsString(csv);

      // Open file
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download staff list: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStaffPage()),
          );
          if (result == true && mounted) {
            _fetchStaffForRole(_selectedRoleId!); // Refresh list on return
          }
        },
        label: Text("Add Staff",
            style: TextStyle(color: theme.colorScheme.onPrimary)),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Staff List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadStaffList,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenSize.width * 0.04,
              screenSize.width * 0.04, screenSize.width * 0.04, 50),
          child: CustomStaffListBox(
            isLoading: _isLoading,
            staff: _staff,
            roles: _roles,
            selectedRoleId: _selectedRoleId,
            onRoleChanged: (int? newRoleId) {
              if (newRoleId != null) {
                setState(() {
                  _selectedRoleId = newRoleId;
                });
                _fetchStaffForRole(newRoleId);
              }
            },
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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.scaffoldBackgroundColor
                  : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: selectedRoleId,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface),
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
                    if (staff.isEmpty) {
                      return Center(
                          child: Text(
                        "No staff found for this role.",
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ));
                    }

                    final isLargeScreen = constraints.maxWidth > 600;
                    if (isLargeScreen) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: staff.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                        ),
                        itemBuilder: (context, index) {
                          return _buildStaffItem(context, staff[index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: staff.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildStaffItem(context, staff[index]);
                        },
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStaffItem(BuildContext context, Staff staffMember) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child:
                Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  staffMember.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  staffMember.designation,
                  style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
