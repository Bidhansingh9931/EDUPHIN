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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instituteName),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ModeratorDashboardPage()), (route) => false),
            icon: const Icon(Icons.dashboard_rounded),
          ),
          const SizedBox(width: 8),
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
                          decoration: const InputDecoration(
                            hintText: "Search employees...",
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _navigateAndRefresh,
                        icon: const Icon(Icons.person_add_rounded),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: employeeRoles.length,
                      itemBuilder: (context, index) {
                        final role = employeeRoles[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(role, style: TextStyle(fontSize: 12, fontWeight: _selectedRole == role ? FontWeight.bold : FontWeight.normal)),
                            selected: _selectedRole == role,
                            onSelected: (bool selected) => _onRoleSelected(role),
                            backgroundColor: colorScheme.surface,
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedRole == role ? colorScheme.primary : colorScheme.outline.withOpacity(0.2))),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(theme)
                      : _filteredEmployees.isEmpty
                          ? _buildEmptyState(theme)
                          : SingleChildScrollView(
                              padding: context.pagePadding,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredEmployees.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 80,
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

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("Failed to load employees", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchEmployees, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("No employees found", style: TextStyle(fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeDetailsPage(employeeId: employee.id)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(employee.name[0].toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employee.role,
                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
