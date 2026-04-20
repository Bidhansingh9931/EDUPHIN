import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'staff_models.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<UserDetail>>? _employeesStream;
  String _selectedRoleId = '5'; // Default to Teachers (role 5)
  String _searchQuery = '';

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
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchEmployees() {
    setState(() {
      _employeesStream = ApiService.getStaffEmployeesStream(_selectedRoleId);
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
              onRefresh: () async => _fetchEmployees(),
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
                        StreamBuilder<List<UserDetail>>(
                          stream: _employeesStream,
                          builder: (context, snapshot) {
                            return LoadingWrapper<List<UserDetail>>(
                              snapshot: snapshot,
                              skeleton: _buildSkeleton(context),
                              builder: (employees) {
                                final filtered = employees.where((emp) {
                                  final name = emp.user?.name.toLowerCase() ?? '';
                                  final email = emp.user?.email.toLowerCase() ?? '';
                                  final pos = emp.position?.toLowerCase() ?? '';
                                  final id = emp.id?.toString() ?? '';
                                  final q = _searchQuery.toLowerCase();
                                  return name.contains(q) || email.contains(q) || pos.contains(q) || id.contains(q);
                                }).toList();

                                if (filtered.isEmpty) return _buildEmptyState();
                                return _buildEmployeeGrid(context, filtered);
                              },
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

  Widget _buildEmployeeGrid(BuildContext context, List<UserDetail> employees) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(180),
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
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

  Widget _buildSkeleton(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(180),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: context.theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(16)),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(width: context.scale(44), height: context.scale(44), borderRadius: context.scale(22)),
                    SizedBox(width: context.scale(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(width: context.scale(120), height: context.scale(16)),
                          SizedBox(height: context.scale(8)),
                          Skeleton(width: context.scale(80), height: context.scale(12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(height: 20, color: Colors.transparent),
                Skeleton(width: context.scale(100), height: context.scale(12)),
                SizedBox(height: context.scale(8)),
                Skeleton(width: context.scale(150), height: context.scale(12)),
                SizedBox(height: context.scale(8)),
                Skeleton(width: context.scale(120), height: context.scale(12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
