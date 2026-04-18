import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/teacher/add_teacher.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
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
  final String? photo;

  Teacher({required this.id, required this.name, required this.designation, this.photo});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Teacher',
      photo: json['photo'] ?? json['profile_image'],
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
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Directory", style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined, size: context.scale(24)),
            onPressed: _downloadTeacherList,
            tooltip: "Download CSV",
          ),
          SizedBox(width: context.scale(8)),
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
        icon: Icon(Icons.person_add_rounded, size: context.scale(20)),
        label: Text("Add Teacher", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
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
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterCard(context),
                      SizedBox(height: context.scale(24)),
                      Text(
                        "Showing ${_teachers.length} results",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: context.font(12)),
                      ),
                      SizedBox(height: context.scale(12)),
                      _teachers.isEmpty
                        ? _buildEmptyState(context)
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _teachers.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                              crossAxisSpacing: context.scale(16),
                              mainAxisSpacing: context.scale(16),
                              mainAxisExtent: context.scale(80),
                            ),
                            itemBuilder: (context, index) => _buildTeacherCard(context, _teachers[index]),
                          ),
                      SizedBox(height: context.scale(100)),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedRoleId,
            isExpanded: true,
            icon: Icon(Icons.filter_list_rounded, size: context.scale(24)),
            hint: Text("Select Role", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
            dropdownColor: theme.cardColor,
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
                    Icon(Icons.school_outlined, size: context.scale(20), color: colorScheme.primary),
                    SizedBox(width: context.scale(12)),
                    Text(role.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(4)),
        leading: ProfileAvatar(
          radius: context.scale(20),
          imageUrl: ApiService.getStorageUrl(teacher.photo),
        ),
        title: Text(teacher.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
        subtitle: Text(teacher.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
        trailing: IconButton(
          icon: Icon(Icons.more_vert_rounded, size: context.scale(20)),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(60)),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: context.scale(64), color: theme.hintColor.withValues(alpha: 0.3)),
            SizedBox(height: context.scale(16)),
            Text("No teachers found", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: context.font(16))),
          ],
        ),
      ),
    );
  }
}

