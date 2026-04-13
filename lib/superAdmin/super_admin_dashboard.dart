import 'package:eduphin/services/responsive_helper.dart';
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
    final theme = Theme.of(context);
    final counts = _dashboardData?['counts'] ?? {};
    final system = _dashboardData?['system'] ?? {};
    final activities = _dashboardData?['recent_activities'] as List? ?? [];
    final roles = _dashboardData?['roles'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Super Admin Dashboard 🌐"),
            Text("Complete platform oversight and management control",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
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
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "⚡ Quick Actions"),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, counts),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "🏫 Institute Management"),
                    _buildManagementCard(context, "Institute List", Icons.list, const InstituteListScreen()),
                    _buildManagementCard(context, "Add Institute", Icons.add_business_outlined, const AddInstituteScreen()),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "👥 Moderators Management"),
                    _buildManagementCard(context, "Moderate List", Icons.people_outline, const ModeratorListScreen()),
                    _buildManagementCard(context, "Add Moderate", Icons.person_add_alt_1_outlined, const AddModeratorScreen()),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "📂 System Logs"),
                    _buildManagementCard(context, "Audit Logs", Icons.history, const AuditLogsScreen()),
                    _buildManagementCard(context, "Database Logs", Icons.storage_outlined, const DatabaseLogsScreen()),
                    const SizedBox(height: 24),
                    _buildPolicyGrid(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "🌱 System Health Overview"),
                    _buildHealthOverview(context, system),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "📊 Platform Statistics"),
                    _buildPlatformStats(context, counts),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "🕒 Recent System Activity"),
                    _buildRecentActivity(context, activities),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "👥 User Role Distribution"),
                    _buildRoleDistribution(context, roles),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildQuickActionBtn(context, "ADD MODERATORS", Icons.person_add_alt_1, () => _navigateTo(const AddModeratorScreen())),
            const SizedBox(height: 8),
            _buildQuickActionBtn(context, "ADD INSTITUTES", Icons.business, () => _navigateTo(const AddInstituteScreen())),
            const SizedBox(height: 8),
            _buildQuickActionBtn(context, "ADD TESTIMONIALS", Icons.rate_review_outlined, () => _navigateTo(const AddTestimonialScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map counts) {
    return GridView.count(
      crossAxisCount: context.isTablet ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, counts['accounts']?.toString() ?? "0", "Total Accounts", Icons.group_outlined, const ModeratorListScreen()),
        _buildStatCard(context, counts['institutes']?.toString() ?? "0", "Active Institutes", Icons.apartment, const InstituteListScreen()),
        _buildStatCard(context, counts['students']?.toString() ?? "0", "Total Students", Icons.school_outlined, const InstituteListScreen()),
        _buildStatCard(context, counts['classes']?.toString() ?? "0", "Classes/Sections", Icons.class_outlined, const InstituteListScreen()),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Widget target) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => _navigateTo(target),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context) {
    final theme = Theme.of(context);
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: theme.colorScheme.primary, size: 40),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Super Admin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Platform Overseer",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileInfoItem("Status", "Active", Icons.check_circle_outline),
                      _buildProfileInfoItem("Security", "High", Icons.shield_outlined),
                      _buildProfileInfoItem("Region", "Global", Icons.public),
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

  Widget _buildProfileInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, IconData icon, Widget screen) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
        title: Text(title, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
        crossAxisCount: context.isTablet ? 3 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        return Card(
          child: InkWell(
            onTap: () => _navigateTo(items[index]['screen']),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[index]['icon'], color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(items[index]['name'], style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthOverview(BuildContext context, Map system) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHealthRow(context, "Database Status", system['db_status'] == true ? "Online" : "Offline", Colors.green),
            const Divider(height: 24),
            _buildHealthRow(context, "Total Usage", system['total_usage'] ?? "N/A", theme.colorScheme.secondary),
            const Divider(height: 24),
            _buildHealthRow(context, "System Uptime", system['uptime'] ?? "N/A", theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRow(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPlatformStats(BuildContext context, Map counts) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(context, "Events", "Active events and functions", counts['events']?.toString() ?? "0"),
            const Divider(height: 24),
            _buildStatRow(context, "Exam Types", "Configured exam categories", counts['exam_types']?.toString() ?? "0"),
            const Divider(height: 24),
            _buildStatRow(context, "Testimonials", "Published user reviews", counts['testimonials']?.toString() ?? "0"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String sub, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(sub, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
            ],
          ),
        ),
        Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List activities) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent System Activity", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _navigateTo(const AuditLogsScreen()),
                  child: const Text("VIEW ALL"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("No recent activity", style: TextStyle(color: theme.hintColor)),
              ),
            ...activities.take(3).map((activity) => Column(
                  children: [
                    _buildActivityItem(context, activity['event'] ?? "Activity", activity['created_at'] ?? "N/A", activity['user']?['name'] ?? "User"),
                    const Divider(height: 24),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String label, String time, String user) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 18, 
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1), 
          child: Icon(Icons.person, color: theme.colorScheme.primary, size: 18)
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text("$user - $time", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDistribution(BuildContext context, List roles) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(role, style: theme.textTheme.bodyMedium),
              Text(count, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent, 
              backgroundColor: theme.dividerColor, 
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
