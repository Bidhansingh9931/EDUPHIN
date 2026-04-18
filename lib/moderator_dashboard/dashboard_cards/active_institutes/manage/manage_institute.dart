import 'dart:async';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/add_employee.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'employee_model.dart';
import 'employ_details.dart';

const List<String> employeeRoles = [
  'All',
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
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final employees = await ApiService.getEmployees(widget.instituteId);
      if (mounted) {
        setState(() {
          _allEmployees = employees;
          _filteredEmployees = employees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load employees: $e')),
        );
      }
    }
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
        onRefresh: _fetchEmployees,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(context)
                      : _filteredEmployees.isEmpty
                          ? _buildEmptyState(context)
                          : SingleChildScrollView(
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
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: context.scale(64), color: colorScheme.error.withValues(alpha: 0.5)),
          SizedBox(height: context.md),
          Text("Failed to load employees", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurface)),
          SizedBox(height: context.scale(24)),
          ElevatedButton.icon(
            onPressed: _fetchEmployees, 
            icon: const Icon(Icons.refresh_rounded),
            label: Text("Retry", style: TextStyle(fontSize: context.font(16))),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
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
                      employee.role,
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
