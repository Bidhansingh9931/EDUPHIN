import 'package:flutter/material.dart';
import 'package:eduphin/teacher/dashboard/app_drawer.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_dashboard_model.dart';
import 'package:eduphin/student/support_ticket/create_tickets.dart';
import 'package:eduphin/student/support_ticket/my_ticket.dart';
import 'package:eduphin/student/support_ticket/ticket_details.dart';
import 'package:eduphin/student/view_virtual_id_card.dart';
import 'package:eduphin/student/student_profile.dart';
import 'package:eduphin/student/time_table/custom_schedule.dart';
import 'package:eduphin/student/time_table/week_schedule.dart';
import 'package:eduphin/student/attendence/view_attendance.dart';
import 'package:eduphin/student/examinations/exam_registration.dart';
import 'package:eduphin/student/fee_details.dart';
import 'package:eduphin/student/academic/assignments.dart';
import 'package:eduphin/student/academic/lacture_notes.dart';
import 'package:eduphin/student/event_management/all_event.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/student/faculty_remark.dart';
import 'package:eduphin/student/attendence/leave_application.dart';
import 'package:eduphin/student/examinations/admit_card.dart';
import 'package:eduphin/student/examinations/exam_result.dart';
import 'package:eduphin/student/library_resources/available_resources.dart';
import 'package:eduphin/student/library_resources/borrowed_books.dart';
import 'package:eduphin/student/event_management/registed_event.dart';
import 'package:eduphin/services/common_widgets.dart';

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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: context.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, color: colorScheme.error, size: context.scale(64)),
                SizedBox(height: context.scale(20)),
                Text("Dashboard Unavailable", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
                SizedBox(height: context.scale(8)),
                Text(errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontSize: context.font(14)), textAlign: TextAlign.center),
                SizedBox(height: context.scale(32)),
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
        title: Text("EDUPHIN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: context.font(20))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    _buildHeader(context),
                    SizedBox(height: context.xl),

                    // Metrics Grid for responsiveness
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = context.isDesktop ? 4 : (context.isTablet ? 2 : 1);
                        final childAspectRatio = context.isDesktop ? 1.4 : (context.isTablet ? 2.2 : 2.5);

                        if (crossAxisCount > 1) {
                          return GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: context.md,
                              mainAxisSpacing: context.md,
                              childAspectRatio: childAspectRatio,
                            ),
                            children: [
                              _buildAttendanceCard(),
                              _buildSupportCard(),
                              _buildStudyCard(),
                              _buildFeeStatusCard(),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildAttendanceCard(),
                              SizedBox(height: context.md),
                              _buildSupportCard(),
                              SizedBox(height: context.md),
                              _buildStudyCard(),
                              SizedBox(height: context.md),
                              _buildFeeStatusCard(),
                            ],
                          );
                        }
                      },
                    ),

                    SizedBox(height: context.xl),
                    _buildSectionHeader(Icons.bolt, "Quick Actions"),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(2, tablet: 4, desktop: 6),
                        crossAxisSpacing: context.md,
                        mainAxisSpacing: context.md,
                        childAspectRatio: 1.1,
                      ),
                      children: [
                        QuickActionItem(
                          label: "ATTENDANCE",
                          icon: Icons.calendar_today_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportPage())),
                          color: colorScheme.primary,
                        ),
                        QuickActionItem(
                          label: "TIMETABLE",
                          icon: Icons.schedule_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetablePage())),
                          color: colorScheme.secondary,
                        ),
                        QuickActionItem(
                          label: "ADMIT CARD",
                          icon: Icons.vignette_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmitCardPage())),
                          color: colorScheme.tertiary,
                        ),
                        QuickActionItem(
                          label: "EXAM RESULT",
                          icon: Icons.assignment_turned_in_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamResultPage())),
                          color: colorScheme.error,
                        ),
                        QuickActionItem(
                          label: "FEES",
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeePage())),
                          color: colorScheme.primary,
                        ),
                        QuickActionItem(
                          label: "RESOURCES",
                          icon: Icons.library_books_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBooksPage())),
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),

                    SizedBox(height: context.xl),
                    _buildSectionHeader(Icons.calendar_today_outlined, "Upcoming Events", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsPage()));
                    }),
                    _buildUpcomingEvents(),

                    SizedBox(height: context.xl),
                    _buildSectionHeader(Icons.assignment_outlined, "Available Exams", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRegistrationPage()));
                    }),
                    _buildAvailableExams(),

                    SizedBox(height: context.xl),
                    _buildSectionHeader(Icons.book_outlined, "Study Materials", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()));
                    }),
                    _buildStudyMaterials(),

                    SizedBox(height: context.xl),
                    _buildSectionHeader(Icons.list_alt_outlined, "Assignments", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsPage()));
                    }),
                    _buildAssignments(),

                    SizedBox(height: context.xl * 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    String? photoPath = dashboardData?.student?.profileImage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.xl),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // Decorative background element
          Positioned(
            right: -context.scale(20),
            top: -context.scale(20),
            child: Icon(
              Icons.school_outlined,
              size: context.scale(120),
              color: colorScheme.primary.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.lg),
            child: Responsive(
              mobile: Column(
                children: [
                  Row(
                    children: [
                      _buildProfileImage(context, photoPath, radius: 45),
                      SizedBox(width: context.md),
                      Expanded(
                        child: _buildWelcomeText(context, crossAxisAlignment: CrossAxisAlignment.start),
                      ),
                    ],
                  ),
                  SizedBox(height: context.lg),
                  _buildVirtualIdButton(context, fullWidth: true),
                ],
              ),
              tablet: Row(
                children: [
                  _buildProfileImage(context, photoPath, radius: 55),
                  SizedBox(width: context.lg),
                  Expanded(
                    child: _buildWelcomeText(context, crossAxisAlignment: CrossAxisAlignment.start),
                  ),
                  _buildVirtualIdButton(context),
                ],
              ),
              desktop: Row(
                children: [
                  _buildProfileImage(context, photoPath, radius: 65),
                  SizedBox(width: context.xl),
                  Expanded(
                    child: _buildWelcomeText(context, crossAxisAlignment: CrossAxisAlignment.start),
                  ),
                  _buildVirtualIdButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, String? photoPath, {double radius = 50}) {
    final colorScheme = context.theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudentProfilePage()),
      ).then((_) => _fetchDashboardData()),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: ProfileAvatar(
          imageUrl: ApiService.getStorageUrl(photoPath),
          radius: context.scale(radius),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          "Welcome Back,",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: context.font(14),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: context.xs),
        Text(
          dashboardData?.user?.name ?? "Student",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: context.font(26),
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (dashboardData?.student?.studentRollNo != null) ...[
          SizedBox(height: context.xs),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.xs),
            ),
            child: Text(
              "Roll No: ${dashboardData!.student!.studentRollNo}",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: context.font(11),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVirtualIdButton(BuildContext context, {bool fullWidth = false}) {
    final colorScheme = context.theme.colorScheme;
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ViewVirtualIdCard()),
      ).then((_) => _fetchDashboardData()),
      icon: Icon(Icons.vignette_rounded, size: context.scale(18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        minimumSize: Size(fullWidth ? double.infinity : context.scale(180), context.scale(48)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.md)),
      ),
      label: Text(
        "VIRTUAL ID CARD",
        style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.w800, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportPage())),
      child: _buildMetricCard(
        title: "ATTENDANCE",
        value: "${dashboardData?.attendancePercentage.toStringAsFixed(1)}%",
        subtitle: (dashboardData?.attendancePercentage ?? 0) >= 75 ? "Excellent! Meeting target." : "Attendance needs improvement",
        icon: Icons.calendar_today_rounded,
        iconColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildFeeStatusCard() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeePage())),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.md),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("FEE STATUS", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w700, letterSpacing: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Icon(Icons.account_balance_wallet_outlined, color: colorScheme.primary, size: context.scale(32)),
                  ],
                ),
                SizedBox(height: context.xs),
                Text("₹${dashboardData?.due ?? 0}", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(24))),
                Text("Current Due Amount", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13))),
              ],
            ),
            if (context.isMobile) ...[
              SizedBox(height: context.md),
              Row(
                children: [
                  Expanded(child: _buildFeeStat("Total Payable", "₹${dashboardData?.totalPayable ?? 0}")),
                  SizedBox(width: context.lg),
                  Expanded(child: _buildFeeStat("Total Paid", "₹${dashboardData?.totalPaid ?? 0}")),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFeeStat(String label, String value) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: context.scale(4)),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSupportCard() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () {
        if (dashboardData!.tickets.isNotEmpty) {
          final ticket = dashboardData!.tickets.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentTicketDetailsPage(
                ticketId: ticket.encryptedId ?? ticket.id.toString(),
              ),
            ),
          ).then((_) => _fetchDashboardData());
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupportTicketsPage()),
          ).then((_) => _fetchDashboardData());
        }
      },
      child: _buildMetricCard(
        title: "SUPPORT",
        value: "${dashboardData?.tickets.length ?? 0}",
        subtitle: "Active Support Tickets",
        icon: Icons.headset_mic_rounded,
        iconColor: colorScheme.secondary,
        extraText: (dashboardData?.tickets ?? []).isNotEmpty ? "Latest: ${dashboardData!.tickets.first.title}" : "No active tickets",
      ),
    );
  }

  Widget _buildStudyCard() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRegistrationPage())),
      child: _buildMetricCard(
        title: "ACADEMIC SUMMARY",
        value: "${dashboardData?.availableExams.length ?? 0}",
        subtitle: "Available Examinations",
        icon: Icons.auto_graph_rounded,
        iconColor: colorScheme.tertiary,
        extraText: "${dashboardData?.studyMaterials.length ?? 0} Materials • ${dashboardData?.assignments.length ?? 0} Assignments",
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    String? extraText,
  }) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    SizedBox(height: context.xs),
                    Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(24))),
                    Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(icon, color: iconColor ?? colorScheme.primary, size: context.scale(32)),
            ],
          ),
          if (extraText != null && context.isMobile) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.sm),
              child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            ),
            Text(extraText, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: context.font(14)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {VoidCallback? onTap}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Row(
        children: [
          Icon(icon, size: context.scale(22), color: theme.colorScheme.primary),
          SizedBox(width: context.sm),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: context.sm),
            TextButton(
              onPressed: onTap,
              child: Text("See All", style: TextStyle(color: theme.colorScheme.primary, fontSize: context.font(13), fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    if (dashboardData!.events.isEmpty) {
      return _buildCenteredEmptyState(Icons.event_busy_rounded, "No upcoming events scheduled");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              childAspectRatio: 3.5,
            ),
            itemCount: dashboardData!.events.length.clamp(0, 4),
            itemBuilder: (context, index) => _buildEventTile(dashboardData!.events[index]),
          );
        }
        return Column(children: dashboardData!.events.take(2).map((e) => _buildEventTile(e)).toList());
      },
    );
  }

  Widget _buildEventTile(Event event) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: context.isMobile ? context.sm : 0),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.xs),
            decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(context.sm)),
            child: Icon(Icons.event_available_rounded, color: colorScheme.primary, size: context.scale(22)),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(event.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.font(15)), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: context.xs),
                Text(event.eventDate ?? "TBA", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3), size: context.scale(16)),
        ],
      ),
    );
  }

  Widget _buildAvailableExams() {
    if (dashboardData!.availableExams.isEmpty) {
      return _buildCenteredEmptyState(Icons.assignment_turned_in_rounded, "No examinations available");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              childAspectRatio: 3.5,
            ),
            itemCount: dashboardData!.availableExams.length.clamp(0, 4),
            itemBuilder: (context, index) => _buildExamTile(dashboardData!.availableExams[index]),
          );
        }
        return Column(
          children: dashboardData!.availableExams.take(2).map((exam) => _buildExamTile(exam)).toList(),
        );
      },
    );
  }

  Widget _buildExamTile(Exam exam) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    bool isReg = dashboardData!.registeredExamIds.contains(exam.id);
    return Container(
      margin: EdgeInsets.only(bottom: context.isMobile ? context.sm : 0),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(exam.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.font(15)), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: context.xs),
                Text(exam.type ?? "General Exam", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
            decoration: BoxDecoration(
              color: isReg ? const Color(0xFF10B981).withValues(alpha: 0.1) : colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.xs),
              border: Border.all(color: isReg ? const Color(0xFF10B981).withValues(alpha: 0.5) : colorScheme.primary.withValues(alpha: 0.5)),
            ),
            child: Text(
              isReg ? "REGISTERED" : "AVAILABLE",
              style: TextStyle(
                color: isReg ? const Color(0xFF10B981) : colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: context.font(10),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyMaterials() {
    if (dashboardData!.studyMaterials.isEmpty) {
      return _buildCenteredEmptyState(Icons.menu_book_rounded, "No study materials available");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              childAspectRatio: 3.5,
            ),
            itemCount: dashboardData!.studyMaterials.length.clamp(0, 4),
            itemBuilder: (context, index) => _buildStudyMaterialTile(dashboardData!.studyMaterials[index]),
          );
        }
        return Column(
          children: dashboardData!.studyMaterials.take(2).map((item) => _buildStudyMaterialTile(item)).toList(),
        );
      },
    );
  }

  Widget _buildStudyMaterialTile(StudyMaterial item) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: context.isMobile ? context.sm : 0),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.scale(44), height: context.scale(44),
            decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(context.sm)),
            child: Icon(Icons.picture_as_pdf_rounded, color: colorScheme.error, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.font(15)), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: context.xs),
                Text("PDF Document", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAssignments() {
    if (dashboardData!.assignments.isEmpty) {
      return _buildCenteredEmptyState(Icons.checklist_rounded, "No assignments pending");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              childAspectRatio: 3.5,
            ),
            itemCount: dashboardData!.assignments.length.clamp(0, 4),
            itemBuilder: (context, index) => _buildAssignmentTile(dashboardData!.assignments[index]),
          );
        }
        return Column(
          children: dashboardData!.assignments.take(2).map((item) => _buildAssignmentTile(item)).toList(),
        );
      },
    );
  }

  Widget _buildAssignmentTile(Assignment item) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: context.isMobile ? context.sm : 0),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: context.font(15)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3), size: context.scale(18)),
            ],
          ),
          SizedBox(height: context.sm),
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: colorScheme.primary, size: context.scale(14)),
              SizedBox(width: context.xs),
              Expanded(
                child: Text(
                  "Academic Assignment",
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: context.sm),
              Text(
                "View Details",
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), decoration: TextDecoration.underline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredEmptyState(IconData icon, String msg) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.xl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2), size: context.scale(48)),
          SizedBox(height: context.md),
          Text(msg, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
