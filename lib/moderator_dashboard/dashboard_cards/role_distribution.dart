import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// 1. Data Model
class UserRole {
  final IconData icon;
  final String title;
  final int count;
  final double percent;
  final Color color;

  UserRole({
    required this.icon,
    required this.title,
    required this.count,
    required this.percent,
    required this.color,
  });
}

// 2. Data Provider
class RoleDistributionProvider {
  Future<List<UserRole>> fetchUserRoles() async {
    final response = await ApiService.get('moderator/dashboard');

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        final rolesData = (responseBody['data']['roles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

        if (rolesData.isEmpty) return [];

        final totalUsers = rolesData.fold<int>(0, (sum, role) => sum + ((role['users_count'] as num?)?.toInt() ?? 0));

        return rolesData.map((role) {
          final roleName = role['name'] as String? ?? 'Unnamed Role';
          final count = (role['users_count'] as num?)?.toInt() ?? 0;
          return UserRole(
            icon: _getIconForRole(roleName),
            title: roleName,
            count: count,
            percent: totalUsers == 0 ? 0.0 : (count / totalUsers) * 100,
            color: _getColorForRole(roleName),
          );
        }).toList();
      }
      throw Exception('Failed to load data from API.');
    }
    throw Exception('Failed to load user roles.');
  }

  IconData _getIconForRole(String roleName) {
    switch (roleName) {
      case 'Super Admin': return Icons.shield_rounded;
      case 'Moderator': return Icons.gavel_rounded;
      case 'Institute Manager': return Icons.business_rounded;
      case 'Teachers': return Icons.school_rounded;
      case 'Students': return Icons.person_rounded;
      case 'Accountants': return Icons.account_balance_wallet_rounded;
      default: return Icons.groups_rounded;
    }
  }

  Color _getColorForRole(String roleName) {
    const colors = {
      'Super Admin': Colors.blue,
      'Moderator': Colors.purple,
      'Institute Manager': Colors.orange,
      'Teachers': Colors.green,
      'Students': Colors.lightBlue,
      'Accountants': Colors.teal,
    };
    return colors[roleName] ?? Colors.blueGrey;
  }
}

class RoleDistributionPage extends StatefulWidget {
  const RoleDistributionPage({super.key});

  @override
  State<RoleDistributionPage> createState() => _RoleDistributionPageState();
}

class _RoleDistributionPageState extends State<RoleDistributionPage> {
  final RoleDistributionProvider _provider = RoleDistributionProvider();
  late Future<List<UserRole>> _userRolesFuture;

  @override
  void initState() {
    super.initState();
    _userRolesFuture = _provider.fetchUserRoles();
  }

  void _refreshData() {
    setState(() {
      _userRolesFuture = _provider.fetchUserRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Distribution"),
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<UserRole>>(
        future: _userRolesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load distribution', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _refreshData, child: const Text("Retry")),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final userRoles = snapshot.data!;
          final totalUsers = userRoles.fold<int>(0, (sum, role) => sum + role.count);

          return SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildTotalUsersCard(context, totalUsers),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userRoles.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 140,
                      ),
                      itemBuilder: (context, index) => _buildRoleCard(context, userRoles[index]),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalUsersCard(BuildContext context, int totalUsers) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withBlue(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL REGISTERED USERS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            totalUsers.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text("Across all institutes and roles", style: TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, UserRole role) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: role.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(role.icon, color: role.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                      Text("${role.count} Users", style: TextStyle(color: theme.hintColor, fontSize: 13)),
                    ],
                  ),
                ),
                Text("${role.percent.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: role.color, fontSize: 16)),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: role.percent / 100,
                minHeight: 8,
                backgroundColor: role.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(role.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
