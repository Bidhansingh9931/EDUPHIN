import 'package:eduphin/services/common_widgets.dart';
import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/caching_service.dart';
import 'counselor_models.dart';
import 'profile.dart';
import 'virtual_id.dart';
import 'salary_inforamation.dart';
import 'examination_information.dart';

import 'manage_account/manager.dart';
import 'manage_account/counselor.dart';
import 'manage_account/teacher.dart';
import 'manage_account/librarian.dart';
import 'manage_account/accountant.dart';
import 'manage_account/staff.dart';

import 'manage_classes/classes.dart';
import 'manage_classes/subject.dart';

import 'library/book_catelog.dart';
import 'library/my_book_issue.dart';

import 'event_management/event_information.dart';
import 'event_management/registered_events.dart';

import 'support_ticket/my_ticket.dart';
import 'support_ticket/submit_new_ticket.dart';
import 'support_ticket/assigned_ticket.dart';

import 'class_routine.dart';

class CounselorDashboardPage extends StatefulWidget {
  const CounselorDashboardPage({super.key});

  @override
  State<CounselorDashboardPage> createState() => _CounselorDashboardPageState();
}

class _CounselorDashboardPageState extends State<CounselorDashboardPage> {
  bool _isLoading = true;
  CounselorDashboardData? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchDashboardData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData('counselor_dashboard');
    if (cachedData != null && mounted) {
      setState(() {
        _dashboardData = CounselorDashboardData.fromJson(cachedData);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    if (_dashboardData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final response = await ApiService.get('counselor/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true || data['status'] == 'success') {
          await CachingService.saveData('counselor_dashboard', data);
          if (mounted) {
            setState(() {
              _dashboardData = CounselorDashboardData.fromJson(data);
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = data['message'] ?? "Failed to load dashboard";
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = ApiService.errorMessage(response, "Failed to load dashboard");
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (_errorMessage != null && _dashboardData == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(context.spacing * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: context.scale(60), color: theme.colorScheme.error),
                SizedBox(height: context.spacing),
                Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: context.spacing * 1.5),
                ElevatedButton(
                  onPressed: _fetchDashboardData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Counselor Dashboard",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
            ),
            Text(
              "Overview & Management",
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, size: context.scale(24)),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CounselorProfilePage()),
            ).then((_) => _fetchDashboardData()),
            icon: ProfileAvatar(
              imageUrl: _dashboardData?.userDetail.photo != null ? ApiService.getStorageUrl(_dashboardData!.userDetail.photo) : null,
              radius: context.scale(16),
            ),
          ),
          SizedBox(width: context.scale(8)),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _dashboardData != null,
        skeleton: _buildSkeleton(context),
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(1000)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(context),
                  SizedBox(height: context.spacing * 2),
                  _buildProfilePreview(context),
                  SizedBox(height: context.spacing * 2),
                  _buildSectionHeader(context, "Academic Management", Icons.school_outlined),
                  SizedBox(height: context.spacing),
                  _buildActionGrid(context, [
                    _ActionItem("Classes", Icons.class_outlined, const ManageClassesPage(), theme.colorScheme.primary),
                    _ActionItem("Subjects", Icons.auto_stories_outlined, const SubjectManagementPage(), theme.colorScheme.secondary),
                    _ActionItem("Routines", Icons.calendar_view_day_outlined, const CounselorClassRoutinePage(), theme.colorScheme.tertiary),
                    _ActionItem("Exams", Icons.assignment_outlined, const ExamListPage(), theme.colorScheme.error),
                  ]),
                  SizedBox(height: context.spacing * 2),
                  _buildSectionHeader(context, "Administrative", Icons.admin_panel_settings_outlined),
                  SizedBox(height: context.spacing),
                  _buildActionGrid(context, [
                    _ActionItem("Managers", Icons.manage_accounts_outlined, const InstituteManagerPage(), theme.colorScheme.primary),
                    _ActionItem("Counselors", Icons.support_agent_outlined, const CounselorPage(), theme.colorScheme.secondary),
                    _ActionItem("Teachers", Icons.person_outline, const TeachersPage(), theme.colorScheme.tertiary),
                    _ActionItem("Librarians", Icons.local_library_outlined, const LibrarianPage(), theme.colorScheme.primary),
                    _ActionItem("Accountants", Icons.account_balance_outlined, const AccountantPage(), theme.colorScheme.secondary),
                    _ActionItem("Staff", Icons.badge_outlined, const StaffPage(), theme.colorScheme.tertiary),
                  ]),
                  SizedBox(height: context.spacing * 2),
                  _buildSectionHeader(context, "Campus Life", Icons.local_activity_outlined),
                  SizedBox(height: context.spacing),
                  _buildActionGrid(context, [
                    _ActionItem("Library", Icons.menu_book, const BookCatelogPage(), theme.colorScheme.primary),
                    _ActionItem("Lending", Icons.library_add_check, const MyBookIssuePage(), theme.colorScheme.secondary),
                    _ActionItem("Events", Icons.event_note, const ExploreEventsPage(), theme.colorScheme.tertiary),
                    _ActionItem("My Events", Icons.event_available, const MyRegisteredEventsPage(), theme.colorScheme.secondary),
                  ]),
                  SizedBox(height: context.spacing * 2),
                  _buildSectionHeader(context, "Support & Finance", Icons.headset_mic_outlined),
                  SizedBox(height: context.spacing),
                  _buildSalaryCard(context),
                  SizedBox(height: context.spacing),
                  _buildSupportSection(context),
                  SizedBox(height: context.spacing * 2.5),
                ],
              ),
            ),
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
          Row(
            children: [
              Expanded(child: Skeleton(height: context.scale(100))),
              SizedBox(width: context.spacing),
              Expanded(child: Skeleton(height: context.scale(100))),
            ],
          ),
          SizedBox(height: context.spacing * 2),
          Skeleton(height: context.scale(250), borderRadius: context.scale(20)),
          SizedBox(height: context.spacing * 2),
          Skeleton(width: context.scale(200), height: context.scale(24)),
          SizedBox(height: context.spacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(2, tablet: 4, desktop: 6),
              crossAxisSpacing: context.scale(12),
              mainAxisSpacing: context.scale(12),
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => Skeleton(height: context.scale(80)),
          ),
          SizedBox(height: context.spacing * 2),
          Skeleton(width: context.scale(200), height: context.scale(24)),
          SizedBox(height: context.spacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(2, tablet: 4, desktop: 6),
              crossAxisSpacing: context.scale(12),
              mainAxisSpacing: context.scale(12),
              childAspectRatio: 1.1,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => Skeleton(height: context.scale(80)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Expanded(child: _buildStatItem(context, "Active Classes", "${_dashboardData?.sections.length ?? 0}", Icons.class_rounded, theme.colorScheme.primary)),
        SizedBox(width: context.spacing),
        Expanded(child: _buildStatItem(context, "Open Tickets", "${_dashboardData?.tickets.where((t) => t.status != 'closed').length ?? 0}", Icons.confirmation_number_rounded, theme.colorScheme.error)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: context.scale(18),
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: context.scale(18)),
            ),
            SizedBox(height: context.spacing),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
            ),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final user = _dashboardData?.userDetail;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20.0)),
        child: Column(
          children: [
            ProfileAvatar(
              imageUrl: user?.photo != null ? ApiService.getStorageUrl(user!.photo) : null,
              radius: context.scale(44),
            ),
            SizedBox(height: context.scale(16)),
            Text(
              user?.fullName ?? "Counselor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(20),
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              user?.position ?? "Counselor",
              style: TextStyle(
                fontSize: context.font(14),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: context.scale(24)),
            Wrap(
              spacing: context.scale(16),
              runSpacing: context.scale(12),
              alignment: WrapAlignment.center,
              children: [
                _buildProfileInfoItemDetail(context, Icons.badge_outlined, user?.employeeId ?? "N/A"),
                _buildProfileInfoItemDetail(context, Icons.phone_outlined, user?.phone ?? "N/A"),
                _buildProfileInfoItemDetail(context, Icons.location_on_outlined, "Campus Main"),
              ],
            ),
            SizedBox(height: context.scale(24)),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualIdCardPage())),
                    icon: Icon(Icons.vignette_outlined, size: context.scale(18)),
                    label: Text("VIRTUAL ID", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      foregroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CounselorProfilePage()),
                    ).then((_) => _fetchDashboardData()),
                    icon: Icon(Icons.person_outline, size: context.scale(18)),
                    label: Text("PROFILE", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItemDetail(BuildContext context, IconData icon, String value) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(context.scale(8)),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: context.scale(20), color: colorScheme.primary),
        ),
        SizedBox(height: context.scale(6)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.font(11),
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: context.scale(20)),
        SizedBox(width: context.scale(10)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, List<_ActionItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(2, tablet: 4, desktop: 6),
        crossAxisSpacing: context.scale(12),
        mainAxisSpacing: context.scale(12),
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return QuickActionItem(
          label: item.title.toUpperCase(),
          icon: item.icon,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.page)),
          color: item.color,
        );
      },
    );
  }

  Widget _buildSalaryCard(BuildContext context) {
    final theme = context.theme;
    final salary = _dashboardData?.lastSalary;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankPage())),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary, size: context.scale(20)),
        ),
        title: Text(
          "Monthly Salary",
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
        ),
        subtitle: Text(
          salary != null ? "₹${salary.amount}" : "₹0.00",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: context.font(16),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: context.scale(20)),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        _buildSupportItem(context, "My Tickets", Icons.confirmation_num_outlined, const SupportTicketsPage(), theme.colorScheme.primary),
        SizedBox(height: context.spacing),
        Row(
          children: [
            Expanded(child: _buildSupportItem(context, "Create New", Icons.add_comment_outlined, const CreateSupportTicketPage(), theme.colorScheme.secondary)),
            SizedBox(width: context.spacing),
            Expanded(child: _buildSupportItem(context, "Assigned", Icons.assignment_ind_outlined, const AssignedTicketsPage(), theme.colorScheme.tertiary)),
          ],
        )
      ],
    );
  }

  Widget _buildSupportItem(BuildContext context, String title, IconData icon, Widget page, Color color) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        leading: Icon(icon, color: color, size: context.scale(20)),
        title: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(13)),
        ),
        trailing: Icon(Icons.chevron_right, size: context.scale(16), color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Widget page;
  final Color color;
  _ActionItem(this.title, this.icon, this.page, this.color);
}

