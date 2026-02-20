import 'dart:async';

import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/add_employee.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'employee_model.dart';
import 'employ_details.dart';

// 3. Dynamic list of roles
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
    required this.instituteId, // Made required to ensure it's passed
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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.instituteName,
                style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ModeratorDashboardPage()),
              ),
              child: const Icon(Icons.home_sharp, size: 30, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 12, screenWidth * 0.04, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
                    decoration: InputDecoration(
                      hintText: "Search employees...",
                      hintStyle: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1B263B),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _navigateAndRefresh,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B263B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
                  ),
                ),
              ],),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: employeeRoles.length,
                itemBuilder: (context, index) {
                  final role = employeeRoles[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: RoleChip(
                      label: role,
                      isSelected: _selectedRole == role,
                      onTap: () => _onRoleSelected(role),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text("Error: $_error", style: TextStyle(color: Colors.red.shade300, fontSize: responsiveFontSize(14))))
                      : _filteredEmployees.isEmpty
                          ? Center(child: Text("No employees found.", style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14))))
                          : LayoutBuilder(builder: (context, constraints) {
                              if (constraints.maxWidth > 600) {
                                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 900 ? 3 : 2);
                                return GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: _filteredEmployees.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 3,
                                  ),
                                  itemBuilder: (context, index) {
                                    return EmployeeCard(_filteredEmployees[index]);
                                  },
                                );
                              } else {
                                return ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  itemCount: _filteredEmployees.length,
                                  itemBuilder: (context, index) {
                                    return EmployeeCard(_filteredEmployees[index]);
                                  },
                                );
                              }
                            }),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard(this.employee, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmployeeDetailsPage(employeeId: employee.id)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1B263B),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF0D1B2A),
              child: Icon(Icons.person_outline_sharp, size: responsiveFontSize(28), color: Colors.white70),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    employee.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.role,
                    style: TextStyle(color: Colors.white70, fontSize: responsiveFontSize(13)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E86D4) : const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
