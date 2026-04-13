import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('counselor/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _dashboardData = CounselorDashboardData.fromJson(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load dashboard";
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
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
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
      appBar: AppBar(
        title: const Text("Counselor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(context),
                  const SizedBox(height: 32),
                  _buildProfilePreview(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Academic Management", Icons.school_outlined),
                  const SizedBox(height: 16),
                  _buildActionGrid(context, [
                    _ActionItem("Classes", Icons.class_outlined, const ManageClassesPage(), Colors.orange),
                    _ActionItem("Subjects", Icons.auto_stories_outlined, const SubjectManagementPage(), Colors.blue),
                    _ActionItem("Routines", Icons.calendar_view_day_outlined, const CounselorClassRoutinePage(), Colors.purple),
                    _ActionItem("Exams", Icons.assignment_outlined, const ExamListPage(), Colors.red),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Administrative", Icons.admin_panel_settings_outlined),
                  const SizedBox(height: 16),
                  _buildActionGrid(context, [
                    _ActionItem("Managers", Icons.manage_accounts_outlined, const InstituteManagerPage(), Colors.indigo),
                    _ActionItem("Counselors", Icons.support_agent_outlined, const CounselorPage(), Colors.teal),
                    _ActionItem("Teachers", Icons.person_outline, const TeachersPage(), Colors.cyan),
                    _ActionItem("Librarians", Icons.local_library_outlined, const LibrarianPage(), Colors.amber),
                    _ActionItem("Accountants", Icons.account_balance_outlined, const AccountantPage(), Colors.pink),
                    _ActionItem("Staff", Icons.badge_outlined, const StaffPage(), Colors.lightGreen),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Campus Life", Icons.local_activity_outlined),
                  const SizedBox(height: 16),
                  _buildActionGrid(context, [
                    _ActionItem("Library", Icons.menu_book, const BookCatelogPage(), Colors.blueAccent),
                    _ActionItem("Lending", Icons.library_add_check, const MyBookIssuePage(), Colors.green),
                    _ActionItem("Events", Icons.event_note, const ExploreEventsPage(), Colors.deepOrange),
                    _ActionItem("My Events", Icons.event_available, const MyRegisteredEventsPage(), Colors.pinkAccent),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Support & Finance", Icons.headset_mic_outlined),
                  const SizedBox(height: 16),
                  _buildSalaryCard(context),
                  const SizedBox(height: 16),
                  _buildSupportSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatItem(context, "Active Classes", "${_dashboardData?.sections.length ?? 0}", Icons.class_rounded, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem(context, "Open Tickets", "${_dashboardData?.tickets.where((t) => t.status != 'closed').length ?? 0}", Icons.confirmation_number_rounded, Colors.red)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview(BuildContext context) {
    final theme = Theme.of(context);
    final user = _dashboardData?.userDetail;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                  backgroundImage: const AssetImage('assets/images/girl_image.webp'),
                  foregroundImage: user?.photo != null && user!.photo!.isNotEmpty
                      ? NetworkImage(ApiService.getStorageUrl(user.photo))
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? "Counselor", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                      Text(user?.position ?? "Counselor", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualIdCardPage())),
                  icon: Icon(Icons.qr_code_2, color: theme.colorScheme.onPrimaryContainer, size: 28),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CounselorProfilePage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimaryContainer,
                  foregroundColor: theme.colorScheme.primaryContainer,
                ),
                child: const Text("VIEW FULL PROFILE"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, List<_ActionItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.page)),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryCard(BuildContext context) {
    final salary = _dashboardData?.lastSalary;
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankPage())),
        leading: CircleAvatar(backgroundColor: Colors.green.withValues(alpha: 0.1), child: const Icon(Icons.account_balance_wallet, color: Colors.green)),
        title: const Text("Monthly Salary", style: TextStyle(fontSize: 12)),
        subtitle: Text(salary != null ? "₹${salary.amount}" : "₹0.00", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      children: [
        _buildSupportItem(context, "My Tickets", Icons.confirmation_num_outlined, const SupportTicketsPage(), Colors.blue),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSupportItem(context, "Create New", Icons.add_comment_outlined, const CreateSupportTicketPage(), Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildSupportItem(context, "Assigned", Icons.assignment_ind_outlined, const AssignedTicketsPage(), Colors.purple)),
          ],
        )
      ],
    );
  }

  Widget _buildSupportItem(BuildContext context, String title, IconData icon, Widget page, Color color) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, size: 16),
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
