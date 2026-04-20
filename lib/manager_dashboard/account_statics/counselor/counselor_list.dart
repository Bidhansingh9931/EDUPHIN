import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/manager_dashboard/account_statics/counselor/add_counselor.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
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
  final String? photo;

  Counselor({required this.id, required this.name, required this.designation, this.photo});

  factory Counselor.fromJson(Map<String, dynamic> json) {
    return Counselor(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Counselor',
      photo: json['photo'] ?? json['profile_image'],
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
  Object? _error;
  int? _selectedRoleId;
  List<Role> _roles = [];
  List<Counselor> _counselors = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchInitialData());
  }

  Future<void> _loadCachedData() async {
    final rolesCache = await CacheService.getCache('counselor_roles');
    if (rolesCache != null && mounted) {
      final List<dynamic> rolesData = rolesCache;
      final List<Role> allRoles = rolesData
          .map((role) => Role(id: role['role_id'], name: role['name']))
          .toList();
      final counselorRoles = allRoles.where((role) => role.name.toLowerCase().contains('counselor')).toList();

      setState(() {
        _roles = counselorRoles;
        if (_roles.isNotEmpty) _selectedRoleId = _roles.first.id;
      });

      if (_selectedRoleId != null) {
        final counselorCache = await CacheService.getCache('counselors_$_selectedRoleId');
        if (counselorCache != null && mounted) {
          setState(() {
            _counselors = (counselorCache as List).map((json) => Counselor.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _roles.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/salary/accounts');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rolesData = data['roles'];
        await CacheService.setCache('counselor_roles', rolesData);

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
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCounselorsForRole(int roleId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = _counselors.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/users/$roleId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> counselorsData = data['data'];
        await CacheService.setCache('counselors_$roleId', counselorsData);

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
        setState(() {
          _error = e;
          _isLoading = false;
        });
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
    final theme = context.theme;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCounselorPage()),
            );
            if (result == true && mounted) _fetchCounselorsForRole(_selectedRoleId!);
          },
          label: Text("Add Counselor", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
          icon: Icon(Icons.add, size: context.scale(20)),
        ),
        appBar: AppBar(
          title: Text("Counselor List", style: theme.appBarTheme.titleTextStyle),
          actions: [
            IconButton(icon: Icon(Icons.download, size: context.scale(24)), onPressed: _downloadCounselorList),
          ],
        ),
        body: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _counselors.isNotEmpty || _roles.isNotEmpty,
          error: _error,
          onRetry: _fetchInitialData,
          skeleton: _buildSkeleton(context),
          child: SafeArea(
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
          )),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                children: [
                  SkeletonBox(height: context.scale(56), borderRadius: context.scale(8)),
                  SizedBox(height: context.scale(24)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: context.scale(16),
                      mainAxisSpacing: context.scale(16),
                      mainAxisExtent: context.scale(80),
                    ),
                    itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.all(context.scale(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: context.scale(24), backgroundColor: Colors.white),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = context.theme;
    if (counselors.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.all(context.scale(40)), child: Text("No counselors found.", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)))));
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
              crossAxisSpacing: context.scale(16),
              mainAxisSpacing: context.scale(16),
              mainAxisExtent: context.scale(80),
            ),
            itemBuilder: (context, index) => _buildCounselorItem(context, counselors[index]),
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: counselors.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) => _buildCounselorItem(context, counselors[index]),
          );
        }
      },
    );
  }

  Widget _buildCounselorItem(BuildContext context, Counselor counselor) {
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
            imageUrl: ApiService.getStorageUrl(counselor.photo),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(counselor.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(counselor.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: context.scale(20)),
        ],
      ),
    );
  }
}


