import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/counselor/add_counselor.dart';
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

class Counselor {
  final int id;
  final String name;
  final String designation;

  Counselor({required this.id, required this.name, required this.designation});

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Counselor', // API doesn't provide a specific designation
    );
  }
}

// ───────────────────────────────────────────────────────────
//                     COUNSELOR LIST PAGE
// ───────────────────────────────────────────────────────────

class CounselorListPage extends StatefulWidget {
  const CounselorListPage({super.key});

  @override
  State<StatefulWidget> createState() => _CounselorListPageState();
}

class _CounselorListPageState extends State<CounselorListPage> {
  bool _isLoading = true;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Counselor> _counselors = [];

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

        // Filter for roles that are considered 'counselors'
        final counselorRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('counselor')
        ).toList();

        if (counselorRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = counselorRoles;
              _selectedRoleId = counselorRoles.first.id;
            });
            await _fetchCounselorsForRole(_selectedRoleId!); // Fetch counselors for the default role
          }
        } else {
          if(mounted) setState(() => _isLoading = false); // No counselor roles found
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

  Future<void> _fetchCounselorsForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> counselorsData = data['data'];
        if(mounted){
          setState(() {
            _counselors = counselorsData.map((json) => Counselor.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load counselors for the selected role');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadCounselorList() async {
    if (_counselors.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No counselor data to download.")),
      );
      return;
    }

    // Convert counselor list to CSV
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['ID', 'Name', 'Designation']);
    // Add data rows
    for (var counselor in _counselors) {
      rows.add([counselor.id, counselor.name, counselor.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/counselor_list.csv';
      final file = File(path);

      // Write to file
      await file.writeAsString(csv);

      // Open file
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download counselor list: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCounselorPage()),
            );
            if (result == true && mounted) {
              _fetchCounselorsForRole(_selectedRoleId!); // Refresh list on return
            }
          },
          label: Text("Add Counselor", style: TextStyle(color: theme.colorScheme.onPrimary)),
          icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          backgroundColor: theme.colorScheme.primary,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Counselor List"),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadCounselorList,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenSize.width * 0.04, screenSize.width * 0.04, screenSize.width * 0.04, 50),
            child: CustomCounselorListBox(
              isLoading: _isLoading,
              counselors: _counselors,
              roles: _roles,
              selectedRoleId: _selectedRoleId,
              onRoleChanged: (int? newRoleId) {
                if (newRoleId != null) {
                  setState(() {
                    _selectedRoleId = newRoleId;
                  });
                  _fetchCounselorsForRole(newRoleId);
                }
              },
            ),
          ),
        ));
  }
}

// ───────────────────────────────────────────────────────────
//                    COUNSELOR LIST BOX
// ───────────────────────────────────────────────────────────

class CustomCounselorListBox extends StatelessWidget {
  final bool isLoading;
  final List<Counselor> counselors;
  final List<Role> roles;
  final int? selectedRoleId;
  final ValueChanged<int?> onRoleChanged;

  const CustomCounselorListBox({
    super.key,
    required this.isLoading,
    required this.counselors,
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
              color: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: selectedRoleId,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
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
                    if (counselors.isEmpty) {
                      return Center(child: Text("No counselors found for this role.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant),));
                    }

                    final isLargeScreen = constraints.maxWidth > 600;
                    if (isLargeScreen) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: counselors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                        ),
                        itemBuilder: (context, index) {
                          return _buildCounselorItem(context, counselors[index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: counselors.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildCounselorItem(context, counselors[index]);
                        },
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCounselorItem(BuildContext context, Counselor counselor) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
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
                  counselor.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  counselor.designation,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
