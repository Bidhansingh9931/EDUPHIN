import 'dart:convert';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'account_details.dart';

class Employee {
  final int id;
  final String name;
  final String info;
  final String role;
  final Color roleColor;

  Employee({
    required this.id,
    required this.name,
    required this.info,
    required this.role,
    required this.roleColor,
  });

  static Color _getColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return Colors.blue;
      case 'administrator':
        return Colors.purple;
      case 'support staff':
        return Colors.indigo;
      case 'librarian':
        return Colors.teal;
      case 'counselor':
        return Colors.orange;
      case 'accountant':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  factory Employee.fromJson(Map<String, dynamic> json, Map<int, String> roleMap) {
    final user = json['user'] ?? {};
    final roleId = json['role_id'];
    final roleName = roleMap[roleId] ?? 'Unknown';

    return Employee(
      id: json['id'] ?? 0,
      name: user['name'] ?? 'No Name',
      info: user['email'] ?? 'No Email',
      role: roleName,
      roleColor: _getColorForRole(roleName),
    );
  }
}

class EmployeesSalaryPage extends StatefulWidget {
  const EmployeesSalaryPage({super.key});

  @override
  State<EmployeesSalaryPage> createState() => _EmployeesSalaryPageState();
}

class _EmployeesSalaryPageState extends State<EmployeesSalaryPage> {
  String _selectedRole = "All";
  bool _isLoading = true;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<String> _roles = ["All"]; // Dynamic list for roles
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/salary/accounts');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> rolesData = data['roles'];
        final Map<int, String> roleMap = {
          for (var role in rolesData)
            if (role['id'] != null && role['name'] != null)
              role['id'] as int: role['name'] as String
        };
        final List<String> roleNames = ["All", ...roleMap.values.toSet()];

        final List<dynamic> accountsData = data['accounts'];
        final List<Employee> employees = accountsData
            .map((account) => Employee.fromJson(account, roleMap))
            .toList();

        setState(() {
          _allEmployees = employees;
          _filteredEmployees = employees;
          _roles = roleNames;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}')),
      );
    }
  }

  void _filterEmployees() {
    List<Employee> results = _allEmployees;

    // Filter by role
    if (_selectedRole != "All") {
      results = results.where((employee) => employee.role == _selectedRole).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((employee) {
        return employee.name.toLowerCase().contains(query) ||
            employee.info.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredEmployees = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Employees Salary"),
        centerTitle: true,
      ),
      body: Padding(
        padding: context.pagePadding.copyWith(bottom: 0),
        child: Column(
          children: [
            /// Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                hintText: "Search for employees...",
                hintStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
            ),

            SizedBox(height: context.sm),

            /// Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: DropdownButton<String>(
                value: _selectedRole,
                hint: Text("Filter by Role", style: TextStyle(color: theme.hintColor)),
                isExpanded: true,
                dropdownColor: theme.colorScheme.surfaceContainerLow,
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
                style: theme.textTheme.bodyLarge,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                      _filterEmployees();
                    });
                  }
                },
                items: _roles
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: context.md),

            /// Employee List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEmployees.isEmpty
                      ? const Center(child: Text("No employees found."))
                      : context.responsive(
                          _buildListView(),
                          tablet: _buildGridView(),
                          desktop: _buildGridView(),
                        ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountDetailsPage(employeeId: employee.id)),
            );
          },
          child: EmployeeCard(
            employee: employee,
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: context.sm),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredEmployees.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: context.sm,
        crossAxisSpacing: context.sm,
        childAspectRatio: 3.2, // Adjust for better card shape
      ),
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountDetailsPage(employeeId: employee.id)),
            );
          },
          child: EmployeeCard(
            employee: employee,
          ),
        );
      },
    );
  }
}

/// ---------------- Employee Card ----------------
class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(14)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          /// Avatar
          ProfileAvatar(
            radius: context.scale(26),
          ),
          const SizedBox(width: 12),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center content for GridView
              children: [
                Text(employee.name, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(employee.info, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: employee.roleColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text(
                    employee.role,
                    style: TextStyle(
                      color: employee.roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
