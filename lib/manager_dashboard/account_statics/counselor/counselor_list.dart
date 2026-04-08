import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/counselor/add_counselor.dart';
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

class Counselor {
  final int id;
  final String name;
  final String designation;

  Counselor({required this.id, required this.name, required this.designation});

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Counselor',
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
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        
        final List<Role> allRoles = rolesData
            .map((role) => Role(id: role['role_id'], name: role['name']))
            .toList();

        final counselorRoles = allRoles.where((role) => 
          role.name.toLowerCase().contains('counselor')
        ).toList();

        if (counselorRoles.isNotEmpty) {
          if (mounted) {
            setState(() {
              _roles = counselorRoles;
              _selectedRoleId = counselorRoles.first.id;
            });
            await _fetchCounselorsForRole(_selectedRoleId!);
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
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
    setState(() => _isLoading = true);

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
        throw Exception('Failed to load counselors');
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to download.")));
      return;
    }

    List<List<dynamic>> rows = [['ID', 'Name', 'Designation']];
    for (var counselor in _counselors) {
      rows.add([counselor.id, counselor.name, counselor.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/counselor_list.csv';
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
              MaterialPageRoute(builder: (context) => const AddCounselorPage()),
            );
            if (result == true && mounted) _fetchCounselorsForRole(_selectedRoleId!);
          },
          label: const Text("Add Counselor"),
          icon: const Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text("Counselor List"),
          actions: [
            IconButton(icon: const Icon(Icons.download), onPressed: _downloadCounselorList),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: CustomCounselorListBox(
                  isLoading: _isLoading,
                  counselors: _counselors,
                  roles: _roles,
                  selectedRoleId: _selectedRoleId,
                  onRoleChanged: (int? newRoleId) {
                    if (newRoleId != null) {
                      setState(() => _selectedRoleId = newRoleId);
                      _fetchCounselorsForRole(newRoleId);
                    }
                  },
                ),
              ),
            ),
          ),
        ));
  }
}

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
    if (counselors.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No counselors found.")));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
        
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: counselors.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 80,
            ),
            itemBuilder: (context, index) => _buildCounselorItem(context, counselors[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: counselors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildCounselorItem(context, counselors[index]),
          );
        }
      },
    );
  }

  Widget _buildCounselorItem(BuildContext context, Counselor counselor) {
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
                Text(counselor.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(counselor.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
