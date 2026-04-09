import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_dashboard_model.dart';
import 'package:eduphin/student/support_ticket/create_tickets.dart';
import 'package:eduphin/student/support_ticket/my_ticket.dart';
import 'package:eduphin/student/view_virtual_id_card.dart';
import 'package:eduphin/student/student_profile.dart';
import 'package:eduphin/student/faculty_remark.dart';
import 'package:eduphin/student/time_table/custom_schedule.dart';
import 'package:eduphin/student/time_table/week_schedule.dart';
import 'package:eduphin/student/attendence/leave_application.dart';
import 'package:eduphin/student/attendence/view_attendance.dart';
import 'package:eduphin/student/examinations/admit_card.dart';
import 'package:eduphin/student/examinations/exam_result.dart';
import 'package:eduphin/student/examinations/exam_registration.dart';
import 'package:eduphin/student/fee_details.dart';
import 'package:eduphin/student/academic/assignments.dart';
import 'package:eduphin/student/academic/lacture_notes.dart';
import 'package:eduphin/student/library_resources/available_resources.dart';
import 'package:eduphin/student/library_resources/borrowed_books.dart';
import 'package:eduphin/student/event_management/all_event.dart';
import 'package:eduphin/student/event_management/registed_event.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool isLoading = true;
  StudentDashboardData? dashboardData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final data = await ApiService.getStudentDashboard();
      setState(() {
        dashboardData = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Responsive sizing logic
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.05 : 20.0;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 64),
                const SizedBox(height: 20),
                Text("Dashboard Unavailable", style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(errorMessage!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _fetchDashboardData,
                  child: const Text("Retry Connection"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eduphin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildIdCardButton(context),
              const SizedBox(height: 32),

              // Statistics Section - Responsive Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 2 : 1,
                    childAspectRatio: isTablet ? 1.8 : 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildAttendanceCard(context),
                      _buildFeeStatusCard(context),
                      _buildSupportCard(context),
                      _buildStudyCard(context),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
              _buildDynamicSections(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome Back,", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text(
                dashboardData?.user?.name ?? "Nisha Rao",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text("Here's your academic overview", style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        _buildAvatar(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 3),
      ),
      child: const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.transparent,
        child: Icon(Icons.person_rounded, size: 32),
      ),
    );
  }

  Widget _buildIdCardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewVirtualIdCard())),
        icon: const Icon(Icons.badge_rounded, size: 20),
        label: const Text("VIEW VIRTUAL ID CARD"),
      ),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "ATTENDANCE",
      value: "${dashboardData?.attendancePercentage.toStringAsFixed(1)}%",
      subtitle: dashboardData!.attendancePercentage >= 75 ? "Excellent! Meeting target." : "Warning: Below 75%.",
      icon: Icons.analytics_rounded,
      accentColor: Colors.greenAccent,
    );
  }

  Widget _buildFeeStatusCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "FEE STATUS",
      value: "₹${dashboardData?.due ?? 0}",
      subtitle: "Current Balance Due",
      icon: Icons.account_balance_wallet_rounded,
      accentColor: Colors.orangeAccent,
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "SUPPORT",
      value: "${dashboardData?.tickets.length ?? 0}",
      subtitle: "Active Support Tickets",
      icon: Icons.headset_mic_rounded,
      accentColor: Colors.blueAccent,
    );
  }

  Widget _buildStudyCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "ACADEMICS",
      value: "${dashboardData?.availableExams.length ?? 0}",
      subtitle: "Upcoming Examinations",
      icon: Icons.auto_graph_rounded,
      accentColor: Colors.purpleAccent,
    );
  }

  Widget _buildDynamicSections(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context, Icons.event_available_rounded, "Upcoming Events", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsPage()));
        }),
        const SizedBox(height: 12),
        _buildUpcomingEvents(),
        const SizedBox(height: 32),

        _buildSectionHeader(context, Icons.assignment_turned_in_rounded, "Available Exams", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamSchedulePage()));
        }),
        const SizedBox(height: 12),
        _buildAvailableExams(),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleLarge),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: const Text("See All"),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    if (dashboardData!.events.isEmpty) return _buildEmptyState("No upcoming events");
    return Column(children: dashboardData!.events.take(2).map((e) => _buildListTile(Icons.event_rounded, Colors.blueAccent, e.title, e.eventDate ?? "")).toList());
  }

  Widget _buildAvailableExams() {
    if (dashboardData!.availableExams.isEmpty) return _buildEmptyState("No exams scheduled");
    return Column(
      children: dashboardData!.availableExams.take(2).map((exam) {
        bool isReg = dashboardData!.registeredExamIds.contains(exam.id);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(exam.type ?? "General"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isReg ? Colors.green : Colors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (isReg ? Colors.green : Colors.blue).withValues(alpha: 0.5)),
              ),
              child: Text(isReg ? "REGISTERED" : "OPEN",
                style: TextStyle(color: isReg ? Colors.green : Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListTile(IconData icon, Color color, String title, String sub) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text(msg, style: const TextStyle(color: Colors.grey))),
    );
  }

  // Optimized Drawer using Theme
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 40)),
            accountName: Text(dashboardData?.user?.name ?? "Student", style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(dashboardData?.user?.email ?? ""),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, "Dashboard", Icons.dashboard_rounded, null, isSelected: true),
                _buildDrawerItem(context, "My Profile", Icons.person_outline_rounded, const StudentProfilePage()),
                const Divider(),
                _buildExpansionTile(context, "Academic", Icons.school_rounded, [
                  _buildDrawerSubItem(context, "Timetable", Icons.calendar_today_rounded, const TimetablePage()),
                  _buildDrawerSubItem(context, "Assignments", Icons.checklist_rounded, const AssignmentsPage()),
                  _buildDrawerSubItem(context, "Results", Icons.auto_graph_rounded, const ExamResultPage()),
                ]),
                _buildDrawerItem(context, "Fees", Icons.payments_rounded, const StudentFeePage()),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await ApiService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, String title, IconData icon, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: children,
    );
  }

  Widget _buildDrawerSubItem(BuildContext context, String title, IconData icon, Widget dest) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32),
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Widget? dest, {bool isSelected = false}) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isSelected,
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
      onTap: () {
        Navigator.pop(context);
        if (dest != null) Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
      },
    );
  }
}
