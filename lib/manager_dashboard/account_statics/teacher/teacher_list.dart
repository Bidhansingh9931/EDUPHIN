import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/teacher/add_teacher.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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

class Teacher {
  final int id;
  final String name;
  final String designation;

  Teacher({required this.id, required this.name, required this.designation});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Teacher',
    );
  }
}

// ───────────────────────────────────────────────────────────
//                       TEACHER LIST PAGE
// ───────────────────────────────────────────────────────────

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<StatefulWidget> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  bool _isLoading = true;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Teacher> _teachers = [];

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

        final teacherRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('teacher')
        ).toList();

        if (teacherRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = teacherRoles;
              _selectedRoleId = teacherRoles.first.id;
            });
            await _fetchTeachersForRole(_selectedRoleId!);
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

  Future<void> _fetchTeachersForRole(int roleId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teachersData = data['data'];
        if(mounted){
          setState(() {
            _teachers = teachersData.map((json) => Teacher.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadTeacherList() async {
    if (_teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to download")));
      return;
    }

    List<List<dynamic>> rows = [['ID', 'Name', 'Designation']];
    for (var teacher in _teachers) {
      rows.add([teacher.id, teacher.name, teacher.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/teacher_list.csv';
      final file = File(path);
      await file.writeAsString(csv);
      await OpenFile.open(path);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Directory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _downloadTeacherList,
            tooltip: "Download CSV",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTeacherPage()),
          );
          if (result == true && mounted) _fetchTeachersForRole(_selectedRoleId!);
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text("Add Teacher"),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => _fetchTeachersForRole(_selectedRoleId!),
            child: SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterCard(context),
                      const SizedBox(height: 24),
                      Text(
                        "Showing ${_teachers.length} results",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _teachers.isEmpty
                        ? _buildEmptyState(theme)
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _teachers.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 80,
                            ),
                            itemBuilder: (context, index) => _buildTeacherCard(context, _teachers[index]),
                          ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedRoleId,
            isExpanded: true,
            icon: const Icon(Icons.filter_list_rounded),
            hint: const Text("Select Role"),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() => _selectedRoleId = newValue);
                _fetchTeachersForRole(newValue);
              }
            },
            items: _roles.map<DropdownMenuItem<int>>((Role role) {
              return DropdownMenuItem<int>(
                value: role.id,
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, Teacher teacher) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: Text(teacher.name[0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(teacher.designation, style: TextStyle(color: theme.hintColor, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text("No teachers found", style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
