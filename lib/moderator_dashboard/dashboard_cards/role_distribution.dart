import 'package:eduphin/services/error_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'count': count,
    'percent': percent,
  };

  factory UserRole.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Unnamed Role';
    return UserRole(
      icon: getIconForRole(title),
      title: title,
      count: (json['count'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      color: getColorForRole(title),
    );
  }

  static IconData getIconForRole(String roleName) {
    switch (roleName) {
      case 'Super Admin': return Icons.shield_rounded;
      case 'Moderator': return Icons.gavel_rounded;
      case 'Institute Manager': return Icons.business_rounded;
      case 'Teachers': return Icons.school_rounded;
      case 'Students': return Icons.person_rounded;
      case 'Accountants': return Icons.account_balance_wallet_rounded;
      case 'Staff': return Icons.badge_rounded;
      case 'Counselors': return Icons.support_agent_rounded;
      case 'Librarian': return Icons.local_library_rounded;
      default: return Icons.groups_rounded;
    }
  }

  static Color getColorForRole(String roleName) {
    switch (roleName) {
      case 'Super Admin': return Colors.blue;
      case 'Moderator': return Colors.purple;
      case 'Institute Manager': return Colors.orange;
      case 'Teachers': return Colors.green;
      case 'Students': return Colors.lightBlue;
      case 'Accountants': return Colors.teal;
      case 'Staff': return Colors.indigo;
      case 'Counselors': return Colors.pink;
      case 'Librarian': return Colors.brown;
      default: return Colors.blueGrey;
    }
  }
}

// 2. Data Provider
class RoleDistributionProvider {
  static const String _cacheKey = 'role_distribution';

  Future<List<UserRole>> fetchUserRoles({bool bypassCache = false}) async {
    try {
      final response = await ApiService.get('moderator/dashboard');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success'] == true && responseBody['data'] != null) {
          final rolesData = (responseBody['data']['roles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

          if (rolesData.isEmpty) return [];

          final totalUsers = rolesData.fold<int>(0, (sum, role) => sum + ((role['users_count'] as num?)?.toInt() ?? 0));

          final roles = rolesData.map((role) {
            final roleName = role['name'] as String? ?? 'Unnamed Role';
            final count = (role['users_count'] as num?)?.toInt() ?? 0;
            return UserRole(
              icon: UserRole.getIconForRole(roleName),
              title: roleName,
              count: count,
              percent: totalUsers == 0 ? 0.0 : (count / totalUsers) * 100,
              color: UserRole.getColorForRole(roleName),
            );
          }).toList();

          await CacheHelper.save(_cacheKey, roles.map((e) => e.toJson()).toList());
          return roles;
        }
        throw ApiException(responseBody['message'] ?? 'Failed to load data from API.');
      }
      throw ApiException('Failed to load user roles', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }


  Future<List<UserRole>?> getCachedUserRoles() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null) {
      return (cached as List).map((e) => UserRole.fromJson(e as Map<String, dynamic>)).toList();
    }
    return null;
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
  List<UserRole>? _cachedUserRoles;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedUserRoles = await _provider.getCachedUserRoles();
    if (mounted) {
      setState(() {
        _userRolesFuture = _provider.fetchUserRoles();
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _userRolesFuture = _provider.fetchUserRoles(bypassCache: true);
    });
    try {
      await _userRolesFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("User Distribution", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _refreshData, icon: Icon(Icons.refresh_rounded, size: context.scale(24))),
          SizedBox(width: context.md),
        ],
      ),
      body: FutureBuilder<List<UserRole>>(
        future: _userRolesFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<UserRole>>(
            snapshot: snapshot,
            cachedData: _cachedUserRoles,
            skeleton: const RoleDistributionSkeleton(),
            onRefresh: _refreshData,
            builder: (userRoles) {
              if (userRoles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      SizedBox(height: context.md),
                      Text('No data found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              final totalUsers = userRoles.fold<int>(0, (sum, role) => sum + role.count);

              return RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.scale(1000)),
                      child: Column(
                        children: [
                          _buildTotalUsersCard(context, totalUsers),
                          SizedBox(height: context.lg),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userRoles.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                              crossAxisSpacing: context.md,
                              mainAxisSpacing: context.md,
                              mainAxisExtent: context.scale(140),
                            ),
                            itemBuilder: (context, index) => _buildRoleCard(context, userRoles[index]),
                          ),
                          SizedBox(height: context.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalUsersCard(BuildContext context, int totalUsers) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.lg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: context.scale(15),
            offset: Offset(0, context.scale(8)),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TOTAL REGISTERED USERS", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7), fontSize: context.font(12), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          SizedBox(height: context.sm),
          Text(
            totalUsers.toString(),
            style: TextStyle(color: colorScheme.onPrimary, fontSize: context.font(48), fontWeight: FontWeight.w900),
          ),
          SizedBox(height: context.sm),
          Text("Across all institutes and roles", style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.6), fontSize: context.font(13))),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, UserRole role) {
    final theme = context.theme;
    
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.sm),
                  decoration: BoxDecoration(color: role.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(context.sm)),
                  child: Icon(role.icon, color: role.color, size: context.scale(24)),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                      Text("${role.count} Users", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13))),
                    ],
                  ),
                ),
                Text("${role.percent.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.w900, color: role.color, fontSize: context.font(16))),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.xs),
              child: LinearProgressIndicator(
                value: role.percent / 100,
                minHeight: context.scale(8),
                backgroundColor: role.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(role.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
