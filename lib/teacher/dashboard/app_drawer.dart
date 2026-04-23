import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'teacher_dashboard.dart';
import 'profile.dart';
import 'virtual_id_page.dart';
import 'salary_bank_details.dart';
import 'library_book_page.dart';
import 'lending_books_page.dart';
import 'explore_events.dart';
import 'my_registered_event.dart';
import 'your_support_ticket.dart';
import 'assigned_tickets.dart';
import 'exam_information_page.dart';
import 'marks_entry_page.dart';
import 'exam_schedule_page.dart';
import 'student_material.dart';
import '../../student/examinations/exam_registration.dart';
import 'upload_material_page.dart';
import 'student_leave.dart';
import 'mentored_section.dart';
import 'my_schedule_page.dart';
import 'new_class_schedule.dart';
import 'assignment.dart';
import 'create_assignment.dart';

// Import for other dashboards if needed for navigation
import '../../librarian/librarian_dashboard.dart';
import '../../accountant/dashboard/accountant_dashbard.dart';
import '../../staff/staff_dashboard/staff_dashboard.dart';
import '../../moderator_dashboard/moderator_dashboard.dart';
import '../../manager_dashboard/manager_dashboard.dart';
import '../../counselor/counselor_dashboard.dart';
import '../../superAdmin/super_admin_dashboard.dart';

import '../../superAdmin/super_admin_profile.dart';
import '../../librarian/librarian_profile.dart';
import '../../accountant/dashboard/accountant_profile.dart';
import '../../staff/staff_dashboard/staff_profile.dart';
import '../../manager_dashboard/manager_profile.dart';
import '../../counselor/profile.dart';
import '../../moderator_dashboard/profile.dart';
import '../../student/student_profile.dart';

import '../../student/student_dashboard.dart';
import '../../student/academic/assignments.dart';
import '../../student/academic/lacture_notes.dart';
import '../../student/attendence/view_attendance.dart';
import '../../student/attendence/leave_application.dart';
import '../../student/time_table/week_schedule.dart';
import '../../student/time_table/custom_schedule.dart';
import '../../student/examinations/admit_card.dart';
import '../../student/examinations/exam_result.dart';
import '../../student/library_resources/available_resources.dart';
import '../../student/library_resources/borrowed_books.dart';
import '../../student/event_management/all_event.dart';
import '../../student/event_management/registed_event.dart';
import '../../student/support_ticket/my_ticket.dart';
import '../../student/support_ticket/create_tickets.dart';
import '../../student/fee_details.dart';
import '../../student/faculty_remark.dart';
import '../../student/view_virtual_id_card.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _roleId = 0;
  String _userName = "User Dashboard";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  String? _photoUrl;

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _roleId = prefs.getInt('role_id') ?? 0;
      _userName = prefs.getString('user_name') ?? _getRoleName(_roleId);
      _photoUrl = prefs.getString('user_photo');
    });
  }

  String _getRoleName(int roleId) {
    switch (roleId) {
      case Roles.teacher: return "Teacher Dashboard";
      case Roles.librarian: return "Librarian Dashboard";
      case Roles.accountant: return "Accountant Dashboard";
      case Roles.staff: return "Staff Dashboard";
      case Roles.manager: return "Manager Dashboard";
      case Roles.moderator: return "Moderator Dashboard";
      case Roles.superAdmin: return "Super Admin Dashboard";
      case Roles.student: return "Student Dashboard";
      default: return "Dashboard";
    }
  }

  Widget _getDashboardPage(int roleId) {
    switch (roleId) {
      case Roles.teacher: return const TeacherDashboardPage();
      case Roles.librarian: return const LibrarianDashboard();
      case Roles.accountant: return const AccountantDashboard();
      case Roles.staff: return const StaffDashboard();
      case Roles.moderator: return const ModeratorDashboardPage();
      case Roles.manager: return const ManagerDashboardPage();
      case Roles.counselor: return const CounselorDashboardPage();
      case Roles.superAdmin: return const SuperAdminDashboard();
      case Roles.student: return const StudentDashboard();
      default: return const TeacherDashboardPage(); // Fallback
    }
  }

  String _getProfileTitle(int roleId) {
    switch (roleId) {
      case Roles.manager: return "Manager Profile";
      case Roles.superAdmin: return "Super Admin Profile";
      case Roles.librarian: return "Librarian Profile";
      case Roles.accountant: return "Accountant Profile";
      case Roles.staff: return "Staff Profile";
      case Roles.counselor: return "Counselor Profile";
      case Roles.moderator: return "Moderator Profile";
      case Roles.student: return "Student Profile";
      default: return "My Profile";
    }
  }

  Widget _getProfilePage(int roleId) {
    switch (roleId) {
      case Roles.manager: return ManagerProfilePage();
      case Roles.superAdmin: return const ManageProfileScreen();
      case Roles.librarian: return const LibrarianProfilePage();
      case Roles.accountant: return const AccountantProfile();
      case Roles.staff: return const StaffProfilePage();
      case Roles.counselor: return const CounselorProfilePage();
      case Roles.moderator: return const ModeratorProfilePage();
      case Roles.student: return const StudentProfilePage();
      default: return const ProfilePage();
    }
  }

  Widget _getVirtualIdPage(int roleId) {
    if (roleId == Roles.student) {
      return const ViewVirtualIdCard();
    }
    return const VirtualIdPage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Drawer(
      width: context.isMobile ? null : context.scale(300),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
            ),
            margin: EdgeInsets.zero,
            accountName: Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
            accountEmail: Text("Eduphin Platform", style: TextStyle(fontSize: context.font(14))),
            currentAccountPicture: ProfileAvatar(
              imageUrl: ApiService.getStorageUrl(_photoUrl),
              radius: context.scale(40),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.dashboard_outlined, "Dashboard", () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => _getDashboardPage(_roleId)));
                }),
                
                _expandableSection(
                  title: "My Profile",
                  icon: Icons.person_outline,
                  children: [
                    _drawerItem(context, Icons.account_circle_outlined, _getProfileTitle(_roleId), () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => _getProfilePage(_roleId)));
                    }),
                    _drawerItem(context, Icons.badge_outlined, "Virtual ID Card", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => _getVirtualIdPage(_roleId)));
                    }),
                    if (_roleId == Roles.student)
                      _drawerItem(context, Icons.comment_outlined, "Faculty Remarks", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RemarksPage()));
                      }),
                  ],
                ),

                if (_roleId == Roles.student)
                _expandableSection(
                  title: "Academic",
                  icon: Icons.history_edu_outlined,
                  children: [
                    _drawerItem(context, Icons.assignment_outlined, "Assignments", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsPage()));
                    }),
                    _drawerItem(context, Icons.note_outlined, "Lecture Notes", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage()));
                    }),
                  ],
                ),

                if (_roleId == Roles.student)
                _expandableSection(
                  title: "Attendance",
                  icon: Icons.how_to_reg_outlined,
                  children: [
                    _drawerItem(context, Icons.calendar_month_outlined, "View Attendance", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportPage()));
                    }),
                    _drawerItem(context, Icons.edit_calendar_outlined, "Leave Application", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveApplicationPage()));
                    }),
                  ],
                ),

                if (_roleId == Roles.student)
                _expandableSection(
                  title: "Time Table",
                  icon: Icons.table_chart_outlined,
                  children: [
                    _drawerItem(context, Icons.view_week_outlined, "Week Schedule", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetablePage()));
                    }),
                    _drawerItem(context, Icons.calendar_view_day_outlined, "Custom Schedule", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassSchedulePage()));
                    }),
                  ],
                ),

                if (_roleId == Roles.teacher)
                _expandableSection(
                  title: "Class Management",
                  icon: Icons.class_outlined,
                  children: [
                    _drawerItem(context, Icons.event_busy_outlined, "Student Leaves", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLeaveScreen()));
                    }),
                    _drawerItem(context, Icons.group_outlined, "Mentored Sections", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MentoredSectionsPage()));
                    }),
                  ],
                ),

                if (_roleId == Roles.teacher)
                _expandableSection(
                  title: "Assignments",
                  icon: Icons.assignment_outlined,
                  children: [
                    _drawerItem(context, Icons.view_list_outlined, "View Assignments", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentPage()));
                    }),
                    _drawerItem(context, Icons.add_task_outlined, "Create Assignment", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAssignmentPage()));
                    }),
                  ],
                ),

                _expandableSection(
                  title: "Academic & Exams",
                  icon: Icons.school_outlined,
                  children: [
                    _drawerItem(context, Icons.info_outline, "Exam Information", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamRegistrationPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()));
                      }
                    }),
                    if (_roleId == Roles.student) ...[
                      _drawerItem(context, Icons.badge_outlined, "Admit Card", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmitCardPage()));
                      }),
                      _drawerItem(context, Icons.assessment_outlined, "Exam Result", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamResultPage()));
                      }),
                    ],
                    if (_roleId == Roles.teacher) ...[
                      _drawerItem(context, Icons.schedule_outlined, "Exam Schedule", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamSchedulePage()));
                      }),
                      _drawerItem(context, Icons.edit_note_outlined, "Marks Entry", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksEntryPage()));
                      }),
                    ],
                  ],
                ),

                if (_roleId == Roles.teacher)
                _expandableSection(
                  title: "Study Materials",
                  icon: Icons.library_books_outlined,
                  children: [
                    _drawerItem(context, Icons.folder_open_outlined, "View Materials", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentMaterialPage()));
                    }),
                    _drawerItem(context, Icons.upload_file_outlined, "Upload Material", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadAssignmentPage()));
                    }),
                  ],
                ),

                _expandableSection(
                  title: "Library",
                  icon: Icons.local_library_outlined,
                  children: [
                    _drawerItem(context, Icons.book_outlined, "Browse Books", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBooksPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()));
                      }
                    }),
                    _drawerItem(context, Icons.assignment_return_outlined, "Lending History", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLendingBooksPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()));
                      }
                    }),
                  ],
                ),

                if (_roleId == Roles.teacher)
                _expandableSection(
                  title: "Schedule",
                  icon: Icons.calendar_today_outlined,
                  children: [
                    _drawerItem(context, Icons.view_day_outlined, "My Schedule", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MySchedulePage()));
                    }),
                    _drawerItem(context, Icons.add_alarm_outlined, "New Class Schedule", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewClassSchedulePage()));
                    }),
                  ],
                ),

                _expandableSection(
                  title: "Salary & Finance",
                  icon: Icons.payments_outlined,
                  children: [
                    if (_roleId == Roles.student)
                      _drawerItem(context, Icons.receipt_long_outlined, "Fee Details", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeePage()));
                      }),
                    if (_roleId != Roles.student)
                      _drawerItem(context, Icons.account_balance_outlined, "Salary Details", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankDetailsPage()));
                      }),
                  ],
                ),

                _expandableSection(
                  title: "Events",
                  icon: Icons.event_outlined,
                  children: [
                    _drawerItem(context, Icons.search, "Explore Events", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()));
                      }
                    }),
                    _drawerItem(context, Icons.how_to_reg_outlined, "My Registered Events", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisteredEventsPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventPage()));
                      }
                    }),
                  ],
                ),

                _expandableSection(
                  title: "Support Tickets",
                  icon: Icons.support_agent_outlined,
                  children: [
                    _drawerItem(context, Icons.confirmation_number_outlined, "My Tickets", () {
                      if (_roleId == Roles.student) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportTicketsPage()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()));
                      }
                    }),
                    if (_roleId == Roles.student)
                      _drawerItem(context, Icons.add_comment_outlined, "Create Ticket", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage()));
                      }),
                    if (_roleId != Roles.student)
                      _drawerItem(context, Icons.assignment_ind_outlined, "Assigned Tickets", () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedTicketsPage()));
                      }),
                  ],
                ),

                const Divider(),
                _drawerItem(context, Icons.logout, "Logout", () async {
                  final navigator = Navigator.of(context);
                  try {
                    await ApiService.logout();
                  } catch (_) {}
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }, iconColor: colorScheme.error),
                SizedBox(height: context.spacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    final theme = context.theme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: context.scale(22)),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: context.font(14))),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _expandableSection({required String title, required IconData icon, required List<Widget> children}) {
    final theme = context.theme;
    return ExpansionTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: context.scale(22)),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
      childrenPadding: EdgeInsets.only(left: context.scale(16)),
      shape: const Border(), // Remove default borders
      children: children,
    );
  }
}
