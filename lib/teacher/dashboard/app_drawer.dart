import 'package:flutter/material.dart';
import 'teacher_dashboard.dart';
import 'profile.dart';
import 'virtual_id_page.dart';
import 'salary_bank_details.dart';
import 'library_book_page.dart';
import 'lending_books_page.dart';
import 'explore_events.dart';
import 'my_registered_event.dart';
import 'your_support_ticket.dart';
import 'assigned_tickets_page.dart';
import 'exam_information_page.dart';
import 'marks_entry_page.dart';
import 'exam_schedule_page.dart';
import 'student_material.dart';
import 'upload_material_page.dart';
import 'student_leave.dart';
import 'mentored_section.dart';
import 'my_schedule_page.dart';
import 'new_class_schedule.dart';
import 'assignment.dart';
import 'create_assignment.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
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
            accountName: const Text("Teacher Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("Eduphin Platform"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
              child: Icon(Icons.person, color: colorScheme.onPrimary, size: 40),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.dashboard_outlined, "Dashboard", () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboardPage()));
                }),
                
                _expandableSection(
                  title: "My Profile",
                  icon: Icons.person_outline,
                  children: [
                    _drawerItem(context, Icons.account_circle_outlined, "View Profile", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    }),
                    _drawerItem(context, Icons.badge_outlined, "Virtual ID Card", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualIdPage()));
                    }),
                  ],
                ),

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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()));
                    }),
                    _drawerItem(context, Icons.schedule_outlined, "Exam Schedule", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamSchedulePage()));
                    }),
                    _drawerItem(context, Icons.edit_note_outlined, "Marks Entry", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksEntryPage()));
                    }),
                  ],
                ),

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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()));
                    }),
                    _drawerItem(context, Icons.assignment_return_outlined, "Lending History", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()));
                    }),
                  ],
                ),

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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()));
                    }),
                    _drawerItem(context, Icons.how_to_reg_outlined, "My Registered Events", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventPage()));
                    }),
                  ],
                ),

                _expandableSection(
                  title: "Support Tickets",
                  icon: Icons.support_agent_outlined,
                  children: [
                    _drawerItem(context, Icons.confirmation_number_outlined, "My Tickets", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()));
                    }),
                    _drawerItem(context, Icons.assignment_ind_outlined, "Assigned Tickets", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedTicketsPage()));
                    }),
                  ],
                ),

                const Divider(),
                _drawerItem(context, Icons.logout, "Logout", () {
                  // Implement logout logic
                }, iconColor: colorScheme.error),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _expandableSection({required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return ExpansionTile(
      leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.only(left: 16),
      shape: const Border(), // Remove default borders
      children: children,
    );
  }
}
