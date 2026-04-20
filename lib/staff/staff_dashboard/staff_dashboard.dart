import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import '../../login_logout/login.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';
import 'salary_detail.dart';
import 'support_tickets.dart';
import 'create_ticket.dart';
import 'assigned_tickets.dart';
import 'event_management.dart';
import 'examinations.dart';
import 'library.dart';
import 'lending_books.dart';
import 'virtual_id_card.dart';
import 'staff_profile.dart';
import 'employee_list.dart';
import 'fee_structure.dart';
import 'student_fee_detail.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late Stream<StaffDashboardData> _dashboardStream;

  @override
  void initState() {
    super.initState();
    // Convert to broadcast stream to allow multiple StreamBuilders (AppBar and Body) to listen
    _dashboardStream = ApiService.getStaffDashboardStream().asBroadcastStream();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardStream = ApiService.getStaffDashboardStream().asBroadcastStream();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leadingWidth: context.scale(70),
        leading: Padding(
          padding: EdgeInsets.only(left: context.scale(12)),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffProfilePage())).then((_) => _refreshData()),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: StreamBuilder<StaffDashboardData>(
                  stream: _dashboardStream,
                  builder: (context, snapshot) {
                    final photoUrl = snapshot.data?.userDetail?.photo;
                    return ProfileAvatar(
                      imageUrl: ApiService.getStorageUrl(photoUrl),
                      radius: context.scale(18),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Staff Dashboard", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(20))),
            Text("Support & Administration Overview", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: "Logout",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<StaffDashboardData>(
          stream: _dashboardStream,
          builder: (context, snapshot) {
            return LoadingWrapper<StaffDashboardData>(
              snapshot: snapshot,
              skeleton: _buildSkeleton(context),
              builder: (data) => _buildContent(context, data),
              onRetry: _refreshData,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StaffDashboardData data) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final userDetail = data.userDetail;
    final user = userDetail?.user;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user?.name ?? 'Staff Member', userDetail?.photo),
              SizedBox(height: context.spacing),

              _buildSectionHeader(context, "Quick Actions", Icons.bolt_outlined),
              SizedBox(height: context.spacing * 0.8),
              _buildQuickActions(context),
              SizedBox(height: context.spacing * 1.5),

              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                  final spacing = context.spacing;
                  final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(width: itemWidth, child: _buildProfileOverview(context, userDetail)),
                      SizedBox(width: itemWidth, child: _buildSupportTicketCard(context)),
                      SizedBox(width: itemWidth, child: _buildLibraryCard(context)),
                      SizedBox(width: itemWidth, child: _buildExaminationsCard(context)),
                      SizedBox(width: itemWidth, child: _buildFeeManagementCard(context)),
                      SizedBox(width: itemWidth, child: _buildSalaryDetailCard(context)),
                      SizedBox(width: itemWidth, child: _buildEventManagementCard(context)),
                    ],
                  );
                },
              ),
              SizedBox(height: context.spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
          SizedBox(height: context.spacing),
          const Skeleton(height: 20, width: 150),
          SizedBox(height: context.spacing * 0.8),
          Row(
            children: [
              Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
              SizedBox(width: context.spacing),
              Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
              SizedBox(width: context.spacing),
              Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
            ],
          ),
          SizedBox(height: context.spacing * 1.5),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final spacing = context.spacing;
              final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(
                  7,
                  (index) => SizedBox(
                    width: itemWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 15, width: 120),
                        const SizedBox(height: 10),
                        Skeleton(height: index == 0 ? 180 : 100, width: double.infinity, borderRadius: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name, String? photoUrl) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.scale(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -context.scale(20),
            top: -context.scale(20),
            child: Icon(
              Icons.dashboard_rounded,
              size: context.scale(150),
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.scale(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                ProfileAvatar(
                  imageUrl: ApiService.getStorageUrl(photoUrl),
                  radius: context.scale(32),
                ),
                    SizedBox(width: context.scale(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: context.font(14),
                            ),
                          ),
                          Text(
                            name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: context.font(24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(20)),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffVirtualIdCard()));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                  ),
                  icon: Icon(Icons.badge_rounded, size: context.scale(20)),
                  label: Text("VIRTUAL ID CARD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: context.font(12))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionItem(
            label: "Employee List",
            icon: Icons.people_alt_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeListPage())),
          ),
        ),
        SizedBox(width: context.spacing),
        Expanded(
          child: QuickActionItem(
            label: "My Profile",
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffProfilePage())).then((_) => _refreshData()),
          ),
        ),
        SizedBox(width: context.spacing),
        Expanded(
          child: QuickActionItem(
            label: "New Ticket",
            icon: Icons.add_task_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffCreateTicketPage())),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOverview(BuildContext context, UserDetail? userDetail) {
    final theme = context.theme;
    final user = userDetail?.user;

    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Details",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
              ),
              IconButton.filledTonal(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffProfilePage())),
                icon: Icon(Icons.edit_outlined, size: context.scale(18)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: context.scale(12)),
          Center(
            child: Column(
              children: [
                ProfileAvatar(
                  imageUrl: ApiService.getStorageUrl(userDetail?.photo),
                  radius: context.scale(32),
                ),
                SizedBox(height: context.scale(8)),
                Text(
                  user?.name ?? 'Staff Name',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? 'email@example.com',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12)),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(height: context.scale(16)),
          _buildInfoRow(context, Icons.phone_android_rounded, userDetail?.phone ?? 'N/A'),
          SizedBox(height: context.scale(4)),
          _buildInfoRow(context, Icons.location_on_outlined, userDetail?.address ?? 'No Address'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: context.scale(14)),
        SizedBox(width: context.scale(8)),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Library Resources",
      icon: Icons.local_library_rounded,
      items: [
        {"title": "Available Books", "page": const StaffLibraryPage()},
        {"title": "Lending Books", "page": const MyLendingBooksPage()},
      ],
    );
  }

  Widget _buildExaminationsCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Academic & Exams",
      icon: Icons.assignment_rounded,
      items: [
        {"title": "Examination Info", "page": const StaffExaminationsPage()},
      ],
    );
  }

  Widget _buildFeeManagementCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Fee Management",
      icon: Icons.account_balance_wallet_rounded,
      items: [
        {"title": "Fee Structure", "page": const StaffFeeStructurePage()},
        {"title": "Student Fee Details", "page": const StaffStudentFeeDetailPage()},
      ],
    );
  }

  Widget _buildSalaryDetailCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Finance & Payroll",
      icon: Icons.payments_rounded,
      items: [
        {"title": "Salary Details", "page": const StaffSalaryDetailPage()},
      ],
    );
  }

  Widget _buildEventManagementCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Events",
      icon: Icons.event_rounded,
      items: [
        {"title": "Upcoming Events", "page": const StaffEventManagementPage()},
      ],
    );
  }

  Widget _buildSupportTicketCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Support Helpdesk",
      icon: Icons.support_agent_rounded,
      items: [
        {"title": "My Tickets", "page": const StaffSupportTicketsPage()},
        {"title": "Create New Ticket", "page": const StaffCreateTicketPage()},
        {"title": "Assigned to Me", "page": const StaffAssignedTicketsPage()},
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(18), color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        SizedBox(width: context.scale(8)),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: context.font(13),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required List<Map<String, dynamic>> items}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(context, title, icon),
        SizedBox(height: context.scale(10)),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(2)),
                    title: Text(item["title"], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: context.font(14))),
                    trailing: Icon(Icons.chevron_right_rounded, size: context.scale(20), color: theme.colorScheme.outlineVariant),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item["page"])),
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: context.scale(16), endIndent: context.scale(16), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
