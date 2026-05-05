import 'dart:async';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/add_employee.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'employee_model.dart';
import 'employ_details.dart';

const List<String> employeeRoles = [
  'All',
  'Moderator',
  'Principal',
  'Institute Manager',
  'Counselors',
  'Librarian',
  'Administrator',
  'IT Support',
  'Head of Mathematics',
  'Science Teacher',
  'Art Teacher',
  'Physical Education',
];

// 1. Data Provider to fetch employee data
class EmployeeProvider {
  String getCacheKey(String instituteId) => 'employees_list_$instituteId';

  Future<List<Employee>> fetchEmployees(String instituteId, {bool bypassCache = false}) async {
    if (!bypassCache) {
      final cached = await getCachedEmployees(instituteId);
      if (cached != null) return cached;
    }
    final data = await ApiService.getEmployees(instituteId);
    await CacheHelper.save(getCacheKey(instituteId), data.map((e) => e.toJson()).toList());
    return data;
  }

  Future<List<Employee>?> getCachedEmployees(String instituteId) async {
    final cached = await CacheHelper.load(getCacheKey(instituteId));
    if (cached != null) {
      return (cached as List).map((e) => Employee.fromJson(e)).toList();
    }
    return null;
  }
}

class ManageInstitute extends StatefulWidget {
  final String instituteName;
  final String instituteId;

  const ManageInstitute({
    super.key,
    this.instituteName = "Global Tech Academy",
    required this.instituteId,
  });

  @override
  State<StatefulWidget> createState() => _ManageInstitutePageState();
}

class _ManageInstitutePageState extends State<ManageInstitute> {
  final EmployeeProvider _provider = EmployeeProvider();
  final _searchController = TextEditingController();

  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  String _selectedRole = 'All';
  late Future<List<Employee>> _employeesFuture;
  List<Employee>? _cachedEmployees;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadInitialData() async {
    _cachedEmployees = await _provider.getCachedEmployees(widget.instituteId);
    if (_cachedEmployees != null) {
      _allEmployees = _cachedEmployees!;
      _applyFiltersNoState();
    }
    if (mounted) {
      setState(() {
        _employeesFuture = _provider.fetchEmployees(widget.instituteId);
      });
    }
  }

  Future<void> _fetchEmployees({bool bypassCache = false}) async {
    setState(() {
      _employeesFuture = _provider.fetchEmployees(widget.instituteId, bypassCache: bypassCache);
    });
    await _employeesFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        final nameMatches = employee.name.toLowerCase().contains(query);
        final roleMatches = _selectedRole == 'All' || employee.role == _selectedRole;
        return nameMatches && roleMatches;
      }).toList();
    });
  }

  void _applyFiltersNoState() {
    final query = _searchController.text.toLowerCase();
    _filteredEmployees = _allEmployees.where((employee) {
      final nameMatches = employee.name.toLowerCase().contains(query);
      final roleMatches = _selectedRole == 'All' || employee.role == _selectedRole;
      return nameMatches && roleMatches;
    }).toList();
  }

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
    _applyFilters();
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEmployeePage(instituteId: widget.instituteId),
      ),
    );

    if (result == true && mounted) {
      _fetchEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instituteName, style: TextStyle(fontSize: context.font(20))),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ModeratorDashboardPage()), (route) => false),
            icon: Icon(Icons.dashboard_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchEmployees(bypassCache: true),
        child: Column(
          children: [
            Padding(
              padding: context.pagePadding.copyWith(bottom: 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontSize: context.font(14)),
                          decoration: InputDecoration(
                            hintText: "Search employees...",
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              borderSide: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.md),
                      IconButton.filled(
                        onPressed: _navigateAndRefresh,
                        icon: Icon(Icons.person_add_rounded, size: context.scale(24)),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          padding: EdgeInsets.all(context.scale(12)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.md),
                  SizedBox(
                    height: context.scale(40),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: employeeRoles.length,
                      itemBuilder: (context, index) {
                        final role = employeeRoles[index];
                        final isSelected = _selectedRole == role;
                        return Padding(
                          padding: EdgeInsets.only(right: context.scale(8)),
                          child: FilterChip(
                            label: Text(role, style: TextStyle(fontSize: context.font(12), color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selected: isSelected,
                            onSelected: (bool selected) => _onRoleSelected(role),
                            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            selectedColor: colorScheme.primary,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(20)), 
                              side: BorderSide(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant)
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            Expanded(
              child: FutureBuilder<List<Employee>>(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  return ModeratorLoadingWrapper<List<Employee>>(
                    snapshot: snapshot,
                    cachedData: _cachedEmployees,
                    skeleton: const ListSkeleton(),
                    onRefresh: () => _fetchEmployees(bypassCache: true),
                    builder: (employees) {
                      _allEmployees = employees;
                      _applyFiltersNoState();

                      if (_filteredEmployees.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return SingleChildScrollView(
                        padding: context.pagePadding,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: context.scale(1200)),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredEmployees.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                crossAxisSpacing: context.md,
                                mainAxisSpacing: context.md,
                                mainAxisExtent: context.scale(80),
                              ),
                              itemBuilder: (context, index) {
                                return EmployeeCard(employee: _filteredEmployees[index]);
                              },
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: context.scale(64), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: context.md),
          Text("No employees found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeDetailsPage(employeeId: employee.id)),
          );
        },
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: context.scale(20),
                backgroundColor: colorScheme.primaryContainer,
                child: Text(employee.name[0].toUpperCase(), style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: context.font(14))),
              ),
              SizedBox(width: context.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      employee.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employee.email ?? employee.role, // Use email if available, else role
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: context.scale(20), color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
