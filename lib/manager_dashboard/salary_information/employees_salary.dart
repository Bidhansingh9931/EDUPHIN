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
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        leading: const BackButton(),
        title: const Text("Employees Salary"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Removed bottom padding here
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
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedRole,
                hint: Text("Filter by Role", style: TextStyle(color: theme.hintColor)),
                isExpanded: true,
                dropdownColor: theme.cardColor,
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
                style: theme.textTheme.bodyLarge,
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
                  : LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return _buildGridView();
                      } else {
                        return _buildListView();
                      }
                    }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 50), // Added bottom padding
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountDetailsPage()),
            );
          },
          child: EmployeeCard(
            employee: _filteredEmployees[index],
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 50), // Added bottom padding
      itemCount: _filteredEmployees.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.8, // Adjust for better card shape
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountDetailsPage()),
            );
          },
          child: EmployeeCard(
            employee: _filteredEmployees[index],
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          /// Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(Icons.person, size: 30, color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 12),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center content for GridView
              children: [
                Text(employee.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(employee.info, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(employee.role),
                      backgroundColor: employee.roleColor.withAlpha(35),
                      labelStyle: TextStyle(color: employee.roleColor, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(employee.status),
                      backgroundColor: employee.statusColor.withAlpha(35),
                      labelStyle: TextStyle(color: employee.statusColor, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
