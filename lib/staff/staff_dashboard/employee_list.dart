import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'staff_models.dart';
import 'dart:convert';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserDetail> _employees = [];
  List<UserDetail> _filteredEmployees = [];
  bool _isLoading = true;
  String _selectedRoleId = '5'; // Default to Teachers (role 5)

  final Map<String, String> _roles = {
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
    _fetchEmployees();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterEmployees(_searchController.text);
  }

  Future<void> _fetchEmployees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Trying common staff directory patterns
      final List<String> pathsToTry = [
        'staff/users/$_selectedRoleId',
        'staff/accounts/$_selectedRoleId',
        'staff/employees/$_selectedRoleId',
        'staff/directory/$_selectedRoleId',
      ];

      var response;
      for (String path in pathsToTry) {
        response = await ApiService.get(path);
        debugPrint("Trying staff endpoint $path: ${response.statusCode}");
        if (response.statusCode == 200) break;
      }
      
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle variations: {data: [...]}, {users: [...]}, {employees: [...]}, or direct list
        final payload = data['data'] ?? data;
        final List usersData = payload is List 
            ? payload 
            : (payload['users'] ?? payload['employees'] ?? payload['data'] ?? []);
        
        if (mounted) {
          setState(() {
            _employees = usersData.map((json) => UserDetail.fromJson(json)).toList();
            _filteredEmployees = _employees;
            _isLoading = false;
          });
        }
      } else {
        debugPrint("All staff directory endpoints failed.");
        if (mounted) {
          setState(() {
            _employees = [];
            _filteredEmployees = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Employee directory not found for this role.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees.where((emp) {
        final name = emp.user?.name.toLowerCase() ?? '';
        final email = emp.user?.email.toLowerCase() ?? '';
        final pos = emp.position?.toLowerCase() ?? '';
        final id = emp.id?.toString() ?? '';
        final q = query.toLowerCase();
        return name.contains(q) || email.contains(q) || pos.contains(q) || id.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Employee Directory", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildTopFilters(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchEmployees,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Search & Filter", Icons.filter_list_rounded),
                        SizedBox(height: context.md),
                        _buildSearchCard(context),
                        SizedBox(height: context.xl),
                        _buildSectionHeader("${_roles[_selectedRoleId]} List", Icons.people_outline_rounded),
                        SizedBox(height: context.md),
                        _isLoading 
                            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                            : _filteredEmployees.isEmpty
                                ? _buildEmptyState()
                                : _buildEmployeeGrid(context),
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

  Widget _buildTopFilters(BuildContext context) {
    final theme = context.theme;
    return Container(
      height: context.scale(60),
      color: theme.colorScheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.spacing),
        children: _roles.entries.map((entry) {
          final isSelected = _selectedRoleId == entry.key;
          return Padding(
            padding: EdgeInsets.only(right: context.scale(8)),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: context.theme.hintColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No employees found", style: TextStyle(color: context.theme.hintColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(18),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: context.font(14)),
          decoration: InputDecoration(
            hintText: "Search by name, ID, or department...",
            prefixIcon: Icon(Icons.search, size: context.scale(20)),
            filled: true,
            fillColor: theme.colorScheme.surface,
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
      ),
    );
  }

  Widget _buildEmployeeGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(180),
      ),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final emp = _filteredEmployees[index];
        return _buildEmployeeCard(context, emp);
      },
    );
  }

  Widget _buildEmployeeCard(BuildContext context, UserDetail emp) {
    final theme = context.theme;
    final user = emp.user;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  radius: context.scale(22),
                  imageUrl: ApiService.getStorageUrl(emp.photo),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Unknown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(14),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        emp.position ?? 'Staff',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: context.font(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: context.scale(20)),
            _buildInfoRow(context, Icons.badge_outlined, emp.id?.toString() ?? 'N/A'),
            SizedBox(height: context.scale(4)),
            _buildInfoRow(context, Icons.email_outlined, user?.email ?? 'N/A'),
            SizedBox(height: context.scale(4)),
            _buildInfoRow(context, Icons.phone_outlined, emp.phone ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(14), color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: context.scale(8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.font(12),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

