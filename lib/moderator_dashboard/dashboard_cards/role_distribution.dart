import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// 1. Data Model (No changes needed)
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

// 2. Data Provider updated to fetch data from the API
class RoleDistributionProvider {
  Future<List<UserRole>> fetchUserRoles() async {
    final response = await ApiService.get('moderator/dashboard');

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        final rolesData = (responseBody['data']['roles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

        if (rolesData.isEmpty) {
          return [];
        }

        final totalUsers = rolesData.fold<int>(0, (sum, role) => sum + ((role['users_count'] as num?)?.toInt() ?? 0));

        if (totalUsers == 0) {
          return rolesData.map((role) {
            final roleName = role['name'] as String? ?? 'Unnamed Role';
            final count = (role['users_count'] as num?)?.toInt() ?? 0;
            return UserRole(
              icon: _getIconForRole(roleName),
              title: roleName,
              count: count,
              percent: 0.0,
              color: _getColorForRole(roleName),
            );
          }).toList();
        }

        return rolesData.map((role) {
          final roleName = role['name'] as String? ?? 'Unnamed Role';
          final count = (role['users_count'] as num?)?.toInt() ?? 0;
          return UserRole(
            icon: _getIconForRole(roleName),
            title: roleName,
            count: count,
            percent: (count / totalUsers) * 100,
            color: _getColorForRole(roleName),
          );
        }).toList();
      } else {
        throw Exception('API call successful but returned no data or indicated failure.');
      }
    } else {
      throw Exception('Failed to load user roles from API.');
    }
  }

  IconData _getIconForRole(String roleName) {
    switch (roleName) {
      case 'Super Admin':
        return Icons.shield;
      case 'Moderator':
        return Icons.gavel;
      case 'Institute Manager':
        return Icons.home_work;
      case 'Counselors':
        return Icons.people;
      case 'Accountants':
        return Icons.account_balance_wallet;
      case 'Staffs':
        return Icons.badge;
      case 'Teachers':
        return Icons.school;
      case 'Students':
        return Icons.person;
      case 'Librarians':
        return Icons.menu_book;
      default:
        return Icons.person_outline;
    }
  }

  Color _getColorForRole(String roleName) {
    const colors = {
      'Super Admin': Colors.blue,
      'Moderator': Colors.purple,
      'Institute Manager': Colors.orange,
      'Counselors': Colors.amber,
      'Accountants': Colors.teal,
      'Staffs': Colors.pink,
      'Teachers': Colors.green,
      'Students': Colors.lightBlue,
      'Librarians': Colors.deepPurpleAccent,
    };
    return colors[roleName] ?? Colors.grey;
  }
}

// 3. Page converted to a StatefulWidget to handle dynamic data
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
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) {
        return baseSize * 1.2;
      } else if (screenWidth > 600) {
        return baseSize * 1.1;
      }
      return baseSize;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E86D4),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "User Distribution",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _refreshData,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<UserRole>>(
                future: _userRolesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No user roles found.',
                          style: TextStyle(color: Colors.white54)),
                    );
                  }

                  final userRoles = snapshot.data!;
                  final totalUsers = userRoles.fold<int>(0, (sum, role) => sum + role.count);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: TotalUsersCard(totalUsers: totalUsers),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 900 ? 3 : 2);
                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.95, // Aspect ratio for grid items
                                ),
                                itemCount: userRoles.length,
                                itemBuilder: (context, index) {
                                  return UserRoleCard(userRoles[index]);
                                },
                              );
                            } else {
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                itemCount: userRoles.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: UserRoleCard(userRoles[index]),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalUsersCard extends StatelessWidget {
  final int totalUsers;

  const TotalUsersCard({super.key, required this.totalUsers});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Users",
            style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(16)),
          ),
          const SizedBox(height: 8),
          Text(
            totalUsers.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFontSize(36),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class UserRoleCard extends StatelessWidget {
  final UserRole role;

  const UserRoleCard(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: role.color.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(role.icon, color: role.color, size: responsiveFontSize(28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  role.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                role.count.toString(),
                style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(16)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: role.percent / 100,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: role.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${role.percent.toStringAsFixed(2)}%",
            style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(12)),
          ),
        ],
      ),
    );
  }
}
