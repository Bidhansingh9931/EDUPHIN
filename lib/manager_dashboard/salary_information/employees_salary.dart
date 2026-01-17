import 'package:flutter/material.dart';

import 'account_details.dart';

class Employee {
  final String name;
  final String info;
  final String role;
  final Color roleColor;
  final String status;
  final Color statusColor;

  Employee({
    required this.name,
    required this.info,
    required this.role,
    required this.roleColor,
    required this.status,
    required this.statusColor,
  });
}

class EmployeesSalaryPage extends StatefulWidget {
  const EmployeesSalaryPage({super.key});

  @override
  State<EmployeesSalaryPage> createState() => _EmployeesSalaryPageState();
}

class _EmployeesSalaryPageState extends State<EmployeesSalaryPage> {
  String? _selectedRole = "All";
  bool _isLoading = true;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
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
    // Simulate API call to fetch employees.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Employee> employees = [
      Employee(
        name: "Ananya Sharma",
        info: "ananya.sharma@example.com",
        role: "Teacher",
        roleColor: Colors.blue,
        status: "Full-time",
        statusColor: Colors.green,
      ),
      Employee(
        name: "Rohan Mehra",
        info: "+91 98765 43210",
        role: "Administrator",
        roleColor: Colors.purple,
        status: "Full-time",
        statusColor: Colors.green,
      ),
      Employee(
        name: "Priya Verma",
        info: "priya.verma@example.com",
        role: "Teacher",
        roleColor: Colors.blue,
        status: "Part-time",
        statusColor: Colors.orange,
      ),
      Employee(
        name: "Vikram Singh",
        info: "+91 91234 56789",
        role: "Support Staff",
        roleColor: Colors.indigo,
        status: "Full-time",
        statusColor: Colors.green,
      ),
      Employee(
        name: "Sonia Gupta",
        info: "sonia.gupta@example.com",
        role: "Librarian",
        roleColor: Colors.teal,
        status: "Full-time",
        statusColor: Colors.green,
      ),
      Employee(
        name: "Amit Kumar",
        info: "+91 99887 76655",
        role: "Teacher",
        roleColor: Colors.blue,
        status: "Part-time",
        statusColor: Colors.orange,
      ),
    ];

    if (mounted) {
      setState(() {
        _allEmployees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    }
  }

  void _filterEmployees() {
    List<Employee> results = _allEmployees;

    // Filter by role
    if (_selectedRole != null && _selectedRole != "All") {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        leading: const Icon(Icons.arrow_back),
        title: const Text("Employees Salary"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white70),
                  hintText: "Search for employees...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            /// Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedRole,
                hint: const Text("Filter by Role", style: TextStyle(color: Colors.white70)),
                isExpanded: true,
                dropdownColor: theme.primaryColor,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                    _filterEmployees();
                  });
                },
                items: <String>["All", "Teacher", "Administrator", "Support Staff", "Librarian"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            /// Employee List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountDetailsPage()),
                      );
                    },
                    child: EmployeeCard(
                      name: employee.name,
                      info: employee.info,
                      role: employee.role,
                      roleColor: employee.roleColor,
                      status: employee.status,
                      statusColor: employee.statusColor,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ---------------- Employee Card ----------------
class EmployeeCard extends StatelessWidget {
  final String name;
  final String info;
  final String role;
  final Color roleColor;
  final String status;
  final Color statusColor;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.info,
    required this.role,
    required this.roleColor,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          /// Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade700,
            child: const Icon(Icons.person, size: 30),
          ),
          const SizedBox(width: 12),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(info,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(role),
                      backgroundColor: roleColor.withAlpha(50),
                      labelStyle: TextStyle(color: roleColor),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(status),
                      backgroundColor: statusColor.withAlpha(50),
                      labelStyle: TextStyle(color: statusColor),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
