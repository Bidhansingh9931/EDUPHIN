import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/app_drawer.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'institute_management/institute_list.dart';
import 'institute_management/add_institute.dart';
import 'moderator_management/moderator_list.dart';
import 'moderator_management/add_moderators.dart';
import 'system_logs/audit_logs.dart';
import 'system_logs/database_logs.dart';
import 'testimonials.dart';
import 'faqs.dart';
import 'customer_contact.dart';
import 'privacy_policy.dart';
import 'cancellation_policy.dart';
import 'terms_of_service.dart';
import 'super_admin_profile.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSuperAdminDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen)).then((_) => _fetchDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final counts = _dashboardData?['counts'] ?? {};
    final system = _dashboardData?['system'] ?? {};
    final activities = _dashboardData?['recent_activities'] as List? ?? [];
    final roles = _dashboardData?['roles'] as List? ?? [];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Super Admin Dashboard 🌐", style: TextStyle(fontSize: context.font(18))),
            Text("Complete platform oversight and management control",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchDashboard,
            icon: Icon(Icons.refresh, size: context.scale(20)),
          ),
          SizedBox(width: context.scale(8)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboard,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileOverview(context),
                    SizedBox(height: context.spacing),
                    _buildSectionHeader(context, "⚡ Quick Actions"),
                    _buildQuickActions(context),
                    SizedBox(height: context.spacing),
                    _buildStatsGrid(context, counts),
                    SizedBox(height: context.spacing),

                    if (context.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, "🏫 Institute Management"),
                                _buildManagementCard(context, "Institute List", Icons.list, const InstituteListScreen()),
                                _buildManagementCard(context, "Add Institute", Icons.add_business_outlined, const AddInstituteScreen()),
                                SizedBox(height: context.spacing),
                                _buildSectionHeader(context, "👥 Moderators Management"),
                                _buildManagementCard(context, "Moderate List", Icons.people_outline, const ModeratorListScreen()),
                                _buildManagementCard(context, "Add Moderate", Icons.person_add_alt_1_outlined, const AddModeratorScreen()),
                              ],
                            ),
                          ),
                          SizedBox(width: context.spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, "📂 System Logs"),
                                _buildManagementCard(context, "Audit Logs", Icons.history, const AuditLogsScreen()),
                                _buildManagementCard(context, "Database Logs", Icons.storage_outlined, const DatabaseLogsScreen()),
                                SizedBox(height: context.spacing),
                                _buildSectionHeader(context, "📜 Policies & Support"),
                                _buildPolicyGrid(context),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildSectionHeader(context, "🏫 Institute Management"),
                      _buildManagementCard(context, "Institute List", Icons.list, const InstituteListScreen()),
                      _buildManagementCard(context, "Add Institute", Icons.add_business_outlined, const AddInstituteScreen()),
                      SizedBox(height: context.spacing),
                      _buildSectionHeader(context, "👥 Moderators Management"),
                      _buildManagementCard(context, "Moderate List", Icons.people_outline, const ModeratorListScreen()),
                      _buildManagementCard(context, "Add Moderate", Icons.person_add_alt_1_outlined, const AddModeratorScreen()),
                      SizedBox(height: context.spacing),
                      _buildSectionHeader(context, "📂 System Logs"),
                      _buildManagementCard(context, "Audit Logs", Icons.history, const AuditLogsScreen()),
                      _buildManagementCard(context, "Database Logs", Icons.storage_outlined, const DatabaseLogsScreen()),
                      SizedBox(height: context.spacing),
                      _buildPolicyGrid(context),
                    ],

                    SizedBox(height: context.spacing),
                    _buildSectionHeader(context, "🌱 System Health Overview"),
                    _buildHealthOverview(context, system),
                    SizedBox(height: context.spacing),
                    _buildSectionHeader(context, "📊 Platform Statistics"),
                    _buildPlatformStats(context, counts),
                    SizedBox(height: context.spacing),

                    if (context.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, "🕒 Recent System Activity"),
                                _buildRecentActivity(context, activities),
                              ],
                            ),
                          ),
                          SizedBox(width: context.spacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(context, "👥 User Role Distribution"),
                                _buildRoleDistribution(context, roles),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildSectionHeader(context, "🕒 Recent System Activity"),
                      _buildRecentActivity(context, activities),
                      SizedBox(height: context.spacing),
                      _buildSectionHeader(context, "👥 User Role Distribution"),
                      _buildRoleDistribution(context, roles),
                    ],
                    SizedBox(height: context.scale(40)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16.0)),
      child: Row(
        children: [
          Text(
            title,
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.font(18),
            ),
          ),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: Container(
              height: 1,
              color: context.theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.amber, size: context.scale(18)),
              SizedBox(width: context.scale(8)),
              Text("Frequent Actions", style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(2, tablet: 3, desktop: 3),
              crossAxisSpacing: context.spacing,
              mainAxisSpacing: context.spacing,
              childAspectRatio: 1.1,
            ),
            children: [
              QuickActionItem(
                label: "ADD MODERATORS",
                icon: Icons.person_add_alt_1,
                onTap: () => _navigateTo(const AddModeratorScreen()),
                color: theme.colorScheme.primary,
              ),
              QuickActionItem(
                label: "ADD INSTITUTES",
                icon: Icons.business,
                onTap: () => _navigateTo(const AddInstituteScreen()),
                color: theme.colorScheme.secondary,
              ),
              QuickActionItem(
                label: "ADD TESTIMONIALS",
                icon: Icons.rate_review_outlined,
                onTap: () => _navigateTo(const AddTestimonialScreen()),
                color: theme.colorScheme.tertiary,
              ),
              QuickActionItem(
                label: "AUDIT LOGS",
                icon: Icons.history,
                onTap: () => _navigateTo(const AuditLogsScreen()),
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map counts) {
    return GridView.count(
      crossAxisCount: context.isDesktop ? 4 : (context.isTablet ? 3 : 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: context.scale(12),
      crossAxisSpacing: context.scale(12),
      childAspectRatio: context.responsive(1.5, tablet: 1.6, desktop: 1.8),
      children: [
        _buildStatCard(context, counts['accounts']?.toString() ?? "0", "Total Accounts", Icons.group_outlined, const ModeratorListScreen()),
        _buildStatCard(context, counts['institutes']?.toString() ?? "0", "Active Institutes", Icons.apartment, const InstituteListScreen()),
        _buildStatCard(context, counts['students']?.toString() ?? "0", "Total Students", Icons.school_outlined, const InstituteListScreen()),
        _buildStatCard(context, counts['classes']?.toString() ?? "0", "Classes/Sections", Icons.class_outlined, const InstituteListScreen()),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Widget target) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: InkWell(
        onTap: () => _navigateTo(target),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: context.scale(24)),
            SizedBox(height: context.scale(4)),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo(const ManageProfileScreen()),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(context.scale(24)),
            child: Column(
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      radius: context.scale(35),
                    ),
                    SizedBox(width: context.scale(20)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Super Admin",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: context.font(22),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Platform Overseer",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                              fontSize: context.font(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onPrimary.withValues(alpha: 0.7), size: context.scale(18)),
                  ],
                ),
                SizedBox(height: context.scale(24)),
                Container(
                  padding: EdgeInsets.all(context.scale(16)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileInfoItem(context, "Status", "Active", Icons.check_circle_outline),
                      _buildProfileInfoItem(context, "Security", "High", Icons.shield_outlined),
                      _buildProfileInfoItem(context, "Region", "Global", Icons.public),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(BuildContext context, String label, String value, IconData icon) {
    final theme = context.theme;
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.onPrimary, size: context.scale(20)),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: context.font(14)),
        ),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onPrimary.withValues(alpha: 0.6), fontSize: context.font(10)),
        ),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, IconData icon, Widget screen) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      margin: EdgeInsets.only(bottom: context.scale(8)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: context.scale(20)),
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
        trailing: Icon(Icons.arrow_forward_ios, size: context.scale(14)),
        onTap: () => _navigateTo(screen),
      ),
    );
  }

  Widget _buildPolicyGrid(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"name": "Testimonials", "icon": Icons.rate_review_outlined, "screen": const TestimonialsManagementScreen()},
      {"name": "Customer Contact", "icon": Icons.contact_mail_outlined, "screen": const CustomerContactScreen()},
      {"name": "Privacy Policy", "icon": Icons.security, "screen": const PrivacyPolicyScreen()},
      {"name": "Cancellation Policy", "icon": Icons.cancel_outlined, "screen": const CancellationPolicyScreen()},
      {"name": "Terms of Service", "icon": Icons.description_outlined, "screen": const TermsOfServiceScreen()},
      {"name": "FAQ's", "icon": Icons.help_outline, "screen": const FAQManagementScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 3 : 2),
        mainAxisSpacing: context.scale(10),
        crossAxisSpacing: context.scale(10),
        childAspectRatio: context.responsive(2.2, tablet: 2.5, desktop: 3.0),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final theme = context.theme;
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(16)),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
          ),
          child: InkWell(
            onTap: () => _navigateTo(items[index]['screen']),
            borderRadius: BorderRadius.circular(context.scale(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[index]['icon'], color: theme.colorScheme.primary, size: context.scale(18)),
                SizedBox(width: context.scale(8)),
                Flexible(child: Text(items[index]['name'], style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(11)), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthOverview(BuildContext context, Map system) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          children: [
            _buildHealthRow(context, "Database Status", system['db_status'] == true ? "Online" : "Offline", const Color(0xFF10B981)),
            Divider(height: context.scale(24)),
            _buildHealthRow(context, "Total Usage", system['total_usage'] ?? "N/A", theme.colorScheme.secondary),
            Divider(height: context.scale(24)),
            _buildHealthRow(context, "System Uptime", system['uptime'] ?? "N/A", theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, String value, Color color) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: context.scale(8), height: context.scale(8), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: context.scale(8)),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(value, style: TextStyle(color: color, fontSize: context.font(11), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPlatformStats(BuildContext context, Map counts) {
    final theme = context.theme;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          children: [
            _buildStatRow(context, "Events", "Active events and functions", counts['events']?.toString() ?? "0"),
            Divider(height: context.scale(24)),
            _buildStatRow(context, "Exam Types", "Configured exam categories", counts['exam_types']?.toString() ?? "0"),
            Divider(height: context.scale(24)),
            _buildStatRow(context, "Testimonials", "Published user reviews", counts['testimonials']?.toString() ?? "0"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String sub, String value) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
              Text(sub, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: context.font(11))),
            ],
          ),
        ),
        Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(24))),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List activities) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent System Activity", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                TextButton(
                  onPressed: () => _navigateTo(const AuditLogsScreen()),
                  child: Text("VIEW ALL", style: TextStyle(fontSize: context.font(12))),
                ),
              ],
            ),
            SizedBox(height: context.scale(16)),
            if (activities.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.scale(20)),
                child: Text("No recent activity", style: TextStyle(color: theme.hintColor, fontSize: context.font(14))),
              ),
            ...activities.take(3).map((activity) => Column(
                  children: [
                    _buildActivityItem(context, activity['event'] ?? "Activity", activity['created_at'] ?? "N/A", activity['user']?['name'] ?? "User"),
                    Divider(height: context.scale(24)),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String label, String time, String user) {
    final theme = context.theme;
    return Row(
      children: [
        ProfileAvatar(radius: context.scale(18)),
        SizedBox(width: context.scale(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
              Text("$user - $time", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDistribution(BuildContext context, List roles) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          children: roles.map((role) {
            final total = roles.fold(0, (sum, item) => sum + (item['users_count'] as int? ?? 0));
            final count = role['users_count'] as int? ?? 0;
            final percent = total > 0 ? count / total : 0.0;
            return _buildRoleRow(context, role['name'] ?? "Role", count.toString(), percent);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleRow(BuildContext context, String role, String count, double percent) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(12.0)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(role, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
              Text(count, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(11))),
            ],
          ),
          SizedBox(height: context.scale(6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent, 
              backgroundColor: theme.dividerColor, 
              minHeight: context.scale(6),
            ),
          ),
        ],
      ),
    );
  }
}
