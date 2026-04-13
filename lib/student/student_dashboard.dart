import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_dashboard_model.dart';
import 'package:eduphin/student/support_ticket/create_tickets.dart';
import 'package:eduphin/student/support_ticket/my_ticket.dart';
import 'package:eduphin/student/support_ticket/ticket_details.dart';
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

  // Theme Colors - Professional Dark UI
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _surface = const Color(0xff2A3450);
  final Color _textSecondary = const Color(0xff8F9BB3);

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
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _primary, strokeWidth: 3)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 20),
                const Text("Dashboard Unavailable", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(errorMessage!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: _fetchDashboardData,
                  child: const Text("Retry Connection", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("EDUPHIN", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: _primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              
              // Metrics Grid/Stack
              _buildAttendanceCard(),
              const SizedBox(height: 16),
              _buildFeeStatusCard(),
              const SizedBox(height: 16),
              _buildSupportCard(),
              const SizedBox(height: 16),
              _buildStudyCard(),
              
              const SizedBox(height: 32),
              _buildSectionHeader(Icons.calendar_today_outlined, "Upcoming Events", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsPage()));
              }),
              _buildUpcomingEvents(),
              
              const SizedBox(height: 32),
              _buildSectionHeader(Icons.assignment_outlined, "Available Exams", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRegistrationPage()));
              }),
              _buildAvailableExams(),

              const SizedBox(height: 32),
              _buildSectionHeader(Icons.book_outlined, "Study Materials", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()));
              }),
              _buildStudyMaterials(),

              const SizedBox(height: 32),
              _buildSectionHeader(Icons.list_alt_outlined, "Assignments", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsPage()));
              }),
              _buildAssignments(),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String? photoPath = dashboardData?.student?.profileImage;

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _primary.withValues(alpha: 0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: _card,
            backgroundImage: const AssetImage('assets/images/girl_image.webp'),
            foregroundImage: photoPath != null && photoPath.isNotEmpty
                ? NetworkImage(ApiService.getStorageUrl(photoPath))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text("Welcome Back!", style: TextStyle(color: _textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(
          dashboardData?.user?.name ?? "Student",
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewVirtualIdCard())),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "VIEW VIRTUAL ID CARD",
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportPage())),
      child: _buildMetricCard(
        title: "ATTENDANCE",
        value: "${dashboardData?.attendancePercentage.toStringAsFixed(1)}%",
        subtitle: (dashboardData?.attendancePercentage ?? 0) >= 75 ? "Excellent! Meeting target." : "Attendance needs improvement",
        icon: Icons.calendar_today_rounded,
        iconColor: const Color(0xff00D68F),
      ),
    );
  }

  Widget _buildFeeStatusCard() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeePage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("FEE STATUS", style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              Icon(Icons.account_balance_wallet_outlined, color: _primary, size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Text("₹${dashboardData?.due ?? 0}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          Text("Current Due Amount", style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFeeStat("Total Payable", "₹${dashboardData?.totalPayable ?? 0}"),
              const SizedBox(width: 40),
              _buildFeeStat("Total Paid", "₹${dashboardData?.totalPaid ?? 0}"),
            ],
          )
        ],
        ),
      ),
    );
  }

  Widget _buildFeeStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  Widget _buildSupportCard() {
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
        iconColor: const Color(0xffFF3D71),
        extraText: dashboardData!.tickets.isNotEmpty ? "Latest: ${dashboardData!.tickets.first.title}" : "No active tickets",
      ),
    );
  }

  Widget _buildStudyCard() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRegistrationPage())),
      child: _buildMetricCard(
        title: "ACADEMIC SUMMARY",
        value: "${dashboardData?.availableExams.length ?? 0}",
        subtitle: "Available Examinations",
        icon: Icons.auto_graph_rounded,
        iconColor: const Color(0xffFFAA00),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
              Icon(icon, color: iconColor ?? _primary, size: 32),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: _textSecondary, fontSize: 13)),
          if (extraText != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10, height: 1),
            ),
            Text(extraText, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _primary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              child: Text("See All", style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    if (dashboardData!.events.isEmpty) {
      return _buildCenteredEmptyState(Icons.event_busy_rounded, "No upcoming events scheduled");
    }
    return Column(children: dashboardData!.events.take(2).map((e) => _buildEventTile(e)).toList());
  }

  Widget _buildEventTile(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.event_available_rounded, color: _primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(event.eventDate ?? "TBA", style: TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildAvailableExams() {
    if (dashboardData!.availableExams.isEmpty) {
      return _buildCenteredEmptyState(Icons.assignment_turned_in_rounded, "No examinations available");
    }
    return Column(
      children: dashboardData!.availableExams.take(2).map((exam) {
        bool isReg = dashboardData!.registeredExamIds.contains(exam.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(exam.type ?? "General Exam", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isReg ? const Color(0xff00D68F).withValues(alpha: 0.1) : _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isReg ? const Color(0xff00D68F).withValues(alpha: 0.5) : _primary.withValues(alpha: 0.5)),
                ),
                child: Text(
                  isReg ? "REGISTERED" : "AVAILABLE",
                  style: TextStyle(
                    color: isReg ? const Color(0xff00D68F) : _primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudyMaterials() {
    if (dashboardData!.studyMaterials.isEmpty) {
      return _buildCenteredEmptyState(Icons.menu_book_rounded, "No study materials available");
    }
    return Column(
      children: dashboardData!.studyMaterials.take(2).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("PDF Document", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssignments() {
    if (dashboardData!.assignments.isEmpty) {
      return _buildCenteredEmptyState(Icons.checklist_rounded, "No assignments pending");
    }
    return Column(
      children: dashboardData!.assignments.take(2).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                  const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: _primary, size: 14),
                  const SizedBox(width: 6),
                  Text("Academic Assignment", style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const Spacer(),
                  const Text("View Details", style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCenteredEmptyState(IconData icon, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white10, size: 48),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: _surface),
            currentAccountPicture: CircleAvatar(
              backgroundColor: _primary,
              backgroundImage: const AssetImage('assets/images/girl_image.webp'),
              foregroundImage: (dashboardData?.student?.profileImage != null && dashboardData!.student!.profileImage!.isNotEmpty)
                  ? NetworkImage(ApiService.getStorageUrl(dashboardData!.student!.profileImage))
                  : null,
            ),
            accountName: Text(dashboardData?.user?.name ?? "Student", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            accountEmail: Text(dashboardData?.user?.email ?? "", style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, "Dashboard", Icons.dashboard_rounded, null, isSelected: true),
                _buildDrawerItem(context, "My Profile", Icons.person_outline_rounded, const StudentProfilePage()),
                _buildDrawerItem(context, "Virtual ID Card", Icons.badge_rounded, const ViewVirtualIdCard()),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.white10)),
        _buildExpansionTile(context, "Academic", Icons.school_rounded, [
                  _buildDrawerSubItem(context, "Weekly Timetable", Icons.calendar_view_week_rounded, const TimetablePage()),
                  _buildDrawerSubItem(context, "Daily Schedule", Icons.calendar_today_rounded, const ClassSchedulePage()),
                  _buildDrawerSubItem(context, "Assignments", Icons.checklist_rounded, const AssignmentsPage()),
                  _buildDrawerSubItem(context, "Study Materials", Icons.menu_book_rounded, const NotesPage()),
                  _buildDrawerSubItem(context, "Faculty Remarks", Icons.comment_rounded, const RemarksPage()),
                ]),
                _buildExpansionTile(context, "Attendance", Icons.fact_check_rounded, [
                  _buildDrawerSubItem(context, "Attendance Report", Icons.analytics_rounded, const AttendanceReportPage()),
                  _buildDrawerSubItem(context, "Leave Applications", Icons.email_rounded, const LeaveApplicationPage()),
                ]),
                _buildExpansionTile(context, "Examinations", Icons.assignment_rounded, [
                  _buildDrawerSubItem(context, "Exam Registration", Icons.app_registration_rounded, const ExamRegistrationPage()),
                  _buildDrawerSubItem(context, "Admit Card", Icons.badge_rounded, const AdmitCardPage()),
                  _buildDrawerSubItem(context, "Exam Results", Icons.grade_rounded, const ExamResultPage()),
                ]),
                _buildExpansionTile(context, "Library", Icons.local_library_rounded, [
                  _buildDrawerSubItem(context, "Available Books", Icons.library_books_rounded, const LibraryBooksPage()),
                  _buildDrawerSubItem(context, "My Lending Books", Icons.book_rounded, const MyLendingBooksPage()),
                ]),
                _buildExpansionTile(context, "Events", Icons.event_rounded, [
                  _buildDrawerSubItem(context, "Explore Events", Icons.search_rounded, const ManageEventsPage()),
                  _buildDrawerSubItem(context, "My Registered Events", Icons.event_available_rounded, const RegisteredEventsPage()),
                ]),
                _buildExpansionTile(context, "Support", Icons.headset_mic_rounded, [
                  _buildDrawerSubItem(context, "My Tickets", Icons.confirmation_number_rounded, const SupportTicketsPage()),
                  _buildDrawerSubItem(context, "Create Ticket", Icons.add_comment_rounded, const CreateSupportTicketPage()),
                ]),
                _buildDrawerItem(context, "Fees", Icons.payments_rounded, const StudentFeePage()),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Colors.white10)),
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        iconColor: _primary,
        collapsedIconColor: Colors.white38,
        children: children,
      ),
    );
  }

  Widget _buildDrawerSubItem(BuildContext context, String title, IconData icon, Widget dest) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32),
      leading: Icon(icon, size: 20, color: Colors.white38),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Widget? dest, {bool isSelected = false}) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: _primary.withValues(alpha: 0.1),
      leading: Icon(icon, color: isSelected ? _primary : Colors.white70),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? _primary : Colors.white, fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        if (dest != null) Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
      },
    );
  }
}
