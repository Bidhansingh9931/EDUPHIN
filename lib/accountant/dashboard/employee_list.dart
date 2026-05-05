import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart' as accountant_model;
import 'salary_slips.dart';

class EmployeeListPage extends StatefulWidget {
  final dynamic roleId;
  const EmployeeListPage({super.key, this.roleId});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  late Stream<List<accountant_model.UserDetail>> _employeeStream;
  dynamic _selectedRoleId;
  String _searchQuery = '';

  Map<dynamic, String> _roles = {
    '3': "Managers",
    '4': "Counselors",
    '5': "Teachers",
    '7': "Librarians",
    '8': "Accountants",
    '9': "Staff",
  };

  @override
  void initState() {
    super.initState();
    // Synchronously initialize state to prevent LateInitializationError during first build
    if (widget.roleId != null && widget.roleId.toString().isNotEmpty) {
      _selectedRoleId = widget.roleId.toString();
    } else {
      _selectedRoleId = _roles.keys.first;
    }
    _fetchEmployees();
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final dynamicRoles = await ApiService.getAccountantRoles();
      if (dynamicRoles.isNotEmpty && mounted) {
        setState(() {
          _roles = dynamicRoles;
          // If the roleId wasn't passed via constructor, update selection to the first dynamic role
          if (widget.roleId == null || widget.roleId.toString().isEmpty) {
            _selectedRoleId = _roles.keys.first;
            _fetchEmployees();
          }
        });
      }
    } catch (e) {
      debugPrint("Roles Fetch Error: $e");
      if (mounted) ErrorHandler.showError(context, e);
    }
  }

  void _fetchEmployees() {
    setState(() {
      _employeeStream = ApiService.getEmployeesByRoleStream(_selectedRoleId)..handleError((error) {
        if (mounted) ErrorHandler.showError(context, error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Directory"),
      ),
      body: Column(
        children: [
          Container(
            height: context.scale(60),
            margin: EdgeInsets.symmetric(vertical: context.scale(8)),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: context.spacing),
              children: _roles.entries.map((entry) {
                final isSelected = _selectedRoleId == entry.key;
                return Padding(
                  padding: EdgeInsets.only(right: context.scale(12)),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRoleId = entry.key);
                        _fetchEmployees();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<accountant_model.UserDetail>>(
              stream: _employeeStream,
              builder: (context, snapshot) {
                return LoadingWrapper<List<accountant_model.UserDetail>>(
                  snapshot: snapshot,
                  onRetry: _fetchEmployees,
                  skeleton: _buildSkeleton(),
                  builder: (employees) {
                    final filteredEmployees = employees
                        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                      e.email?.toLowerCase().contains(_searchQuery.toLowerCase()) == true)
                        .toList();

                    return SingleChildScrollView(
                      padding: context.pagePadding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: context.scale(800)),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(context.scale(20)),
                                  child: TextField(
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    decoration: const InputDecoration(
                                      hintText: "Search by Name or Email",
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                if (filteredEmployees.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(context.scale(40)),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.person_off_outlined, size: context.scale(48), color: theme.hintColor.withValues(alpha: 0.3)),
                                          SizedBox(height: context.scale(16)),
                                          Text("No employees found", style: TextStyle(color: theme.hintColor)),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredEmployees.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final employee = filteredEmployees[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(8)),
                                        onTap: () {
                                          final targetId = employee.encryptedId ?? employee.userId.toString();
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => SalarySlipsPage(employeeId: targetId)));
                                        },
                                        leading: ProfileAvatar(
                                          imageUrl: employee.photo != null ? "${ApiService.baseUrl}/storage/${employee.photo}" : null,
                                          radius: context.scale(20),
                                          borderWidth: 0,
                                        ),
                                        title: Text(employee.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(15))),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: context.scale(4)),
                                            Text(employee.email ?? "No Email", style: TextStyle(color: theme.colorScheme.secondary, fontSize: context.font(12)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            Text(employee.phone ?? "No Phone", style: TextStyle(color: theme.hintColor, fontSize: context.font(12)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                        trailing: Icon(Icons.chevron_right, size: context.scale(20)),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(800)),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(context.scale(20)),
                  child: Skeleton(height: context.scale(48), width: double.infinity, borderRadius: context.scale(12)),
                ),
                const Divider(height: 1),
                ...List.generate(6, (index) => ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(8)),
                  leading: Skeleton(width: context.scale(40), height: context.scale(40), borderRadius: context.scale(20)),
                  title: Skeleton(height: context.font(15), width: context.scale(150)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.scale(4)),
                      Skeleton(height: context.font(12), width: context.scale(180)),
                      SizedBox(height: context.scale(4)),
                      Skeleton(height: context.font(12), width: context.scale(120)),
                    ],
                  ),
                  trailing: Skeleton(width: context.scale(20), height: context.scale(20), borderRadius: context.scale(10)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
