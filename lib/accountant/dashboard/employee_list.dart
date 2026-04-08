import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';
import 'salary_slips.dart';

class EmployeeListPage extends StatefulWidget {
  final int? roleId;
  const EmployeeListPage({super.key, this.roleId});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  bool _isLoading = true;
  List<UserDetail> _employees = [];
  List<UserDetail> _filteredEmployees = [];
  late int _selectedRoleId;

  final Map<int, String> _roles = {
    3: "Managers",
    4: "Counselors",
    5: "Teachers",
    7: "Librarians",
    8: "Accountants",
    9: "Staff",
  };

  @override
  void initState() {
    super.initState();
    _selectedRoleId = widget.roleId ?? 5;
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('accountants/accounts/$_selectedRoleId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final usersData = data['data']?['users'] ?? data['users'] ?? [];
          
          List usersList = [];
          if (usersData is List) {
            usersList = usersData;
          } else if (usersData is Map) {
            usersList = usersData.values.toList();
          }

          final employees = usersList.map((e) => UserDetail.fromJson(e)).toList();
          if (mounted) {
            setState(() {
              _employees = employees;
              _filteredEmployees = employees;
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to load employees');
        }
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()) || e.email?.toLowerCase().contains(query.toLowerCase()) == true)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Directory"),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _roles.entries.map((entry) {
                final isSelected = _selectedRoleId == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
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
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextField(
                            onChanged: _filterEmployees,
                            decoration: const InputDecoration(
                              hintText: "Search by Name or Email",
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        if (_isLoading)
                          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                        else if (_filteredEmployees.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.person_off_outlined, size: 48, color: theme.hintColor.withValues(alpha: 0.3)),
                                  const SizedBox(height: 16),
                                  Text("No employees found", style: TextStyle(color: theme.hintColor)),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredEmployees.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final employee = _filteredEmployees[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalarySlipsPage(employeeId: employee.userId))),
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Text(employee.name.isNotEmpty ? employee.name[0] : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(employee.email ?? "No Email", style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12)),
                                    Text(employee.phone ?? "No Phone", style: TextStyle(color: theme.hintColor, fontSize: 12)),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 20),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
