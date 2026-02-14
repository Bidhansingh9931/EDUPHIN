import 'dart:convert';

import 'package:eduphin/manager_dashboard/recentSupportTickets/assigned_ticket.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'account_statics/accountant/accountant_list.dart';
import 'account_statics/counselor/counselor_list.dart';
import 'account_statics/institute_manager/manager_list.dart';
import 'account_statics/librarian/librarian_list.dart';
import 'account_statics/staff/staff_list.dart';
import 'account_statics/teacher/teacher_list.dart';
import 'events/event_management.dart';
import 'examinations/exam_info.dart';
import 'examinations/exam_result.dart';
import 'feeStructure/fee_Structure/fee_structure.dart';
import 'feeStructure/studentFeeDetails/student_fee_details.dart';
import 'library/available_books.dart';
import 'library/lending_books.dart';
import 'manageClasses/classList/class_list.dart';
import 'manageClasses/schedule/class_schedule_search.dart';
import 'manageClasses/subjectList/subject_list.dart';
import 'manageClasses/timeTable/time_table.dart';
import 'manager_profile.dart';
import 'quick_actions/add_new_class.dart';
import 'quick_actions/add_new_schedule.dart';
import 'quick_actions/add_new_student.dart';
import 'quick_actions/add_new_subject.dart';
import 'recentSupportTickets/ticket_info.dart';
import 'salary_information/employees_salary.dart';
import 'salary_information/my_salary.dart';
import 'studyMaterial/assignments.dart';
import 'studyMaterial/notes.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

// --- Dynamic Models ---
class Profile {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String imageUrl;

  const Profile({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['photo'] ?? '';
    return Profile(
      name: json['name'] ?? 'N/A',
      role: json['role']?['name'] ?? 'Manager', // Role might not be in profile data
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      imageUrl: rawImageUrl.isNotEmpty ? '${ApiService.baseImageUrl}/storage/$rawImageUrl' : '',
    );
  }
}

class RoleSummary {
  final String name;
  final int count;

  RoleSummary({required this.name, required this.count});

  factory RoleSummary.fromJson(Map<String, dynamic> json) {
    return RoleSummary(
      name: json['name'] ?? 'Unknown Role',
      count: json['user_details_count'] ?? 0,
    );
  }
}

class UpcomingEvent {
  final String title;
  final DateTime eventDate;
  final VoidCallback onTap;
  final String date;
  final String day;
  final String fullDate;

  UpcomingEvent({
    required this.title,
    required this.eventDate,
    required this.onTap,
  })  : date = DateFormat('d').format(eventDate),
        day = DateFormat('MMM').format(eventDate),
        fullDate = DateFormat('EEEE, MMMM d').format(eventDate);

  factory UpcomingEvent.fromJson(Map<String, dynamic> json, BuildContext context) {
    return UpcomingEvent(
      title: json['title'] ?? 'Untitled Event',
      eventDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      onTap: () {
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EventManagementPage()));
        }
      },
    );
  }
}

// --- Static Navigation Models ---
class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const QuickAction({required this.label, required this.icon, required this.onTap});
}

class AccountStatistic {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  const AccountStatistic({required this.label, required this.value, required this.icon, required this.onTap});
}

class SalaryInformation {
  final String title;
  final VoidCallback onTap;
  const SalaryInformation({required this.title, required this.onTap});
}

class ManageClass {
  final String title;
  final VoidCallback onTap;
  const ManageClass({required this.title, required this.onTap});
}

class FeeStructure {
  final String title;
  final VoidCallback onTap;
  const FeeStructure({required this.title, required this.onTap});
}

class Examination {
  final String title;
  final VoidCallback onTap;
  const Examination({required this.title, required this.onTap});
}

class Library {
  final String title;
  final VoidCallback onTap;
  const Library({required this.title, required this.onTap});
}

class StudyMaterial {
  final String title;
  final VoidCallback onTap;
  const StudyMaterial({required this.title, required this.onTap});
}

class RecentSupportTicket {
  final String title;
  final VoidCallback onTap;
  const RecentSupportTicket({required this.title, required this.onTap});
}

class DashboardData {
  final Profile profile;
  final List<QuickAction> quickActions;
  final List<AccountStatistic> accountStatistics;
  final List<UpcomingEvent> upcomingEvents;
  final List<SalaryInformation> salaryInformation;
  final List<ManageClass> manageClasses;
  final List<FeeStructure> feeStructure;
  final List<Examination> examinations;
  final List<Library> library;
  final List<StudyMaterial> studyMaterial;
  final List<RecentSupportTicket> recentSupportTickets;

  DashboardData({
    required this.profile,
    required this.quickActions,
    required this.accountStatistics,
    required this.upcomingEvents,
    required this.salaryInformation,
    required this.manageClasses,
    required this.feeStructure,
    required this.examinations,
    required this.library,
    required this.studyMaterial,
    required this.recentSupportTickets,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json, BuildContext context) {
    // Helper to map role names from the API to the right icon and navigation page
    AccountStatistic mapRoleToStatistic(RoleSummary role) {
      final Map<String, dynamic> roleMap = {
        'Manager': {'icon': Icons.person_outline_sharp, 'page': const ManagerListPage()},
        'Counselor': {'icon': Icons.support_agent_sharp, 'page': const CounselorListPage()},
        'Teacher': {'icon': Icons.school_outlined, 'page': const TeacherListPage()},
        'Librarian': {'icon': Icons.local_library, 'page': const LibrarianListPage()},
        'Accountant': {'icon': Icons.account_balance, 'page': const AccountantListPage()},
        'Staff': {'icon': Icons.work, 'page': const StaffListPage()},
      };

      final roleConfig = roleMap[role.name] ?? {'icon': Icons.person, 'page': null};

      return AccountStatistic(
        label: role.name,
        value: role.count.toString(),
        icon: roleConfig['icon'],
        onTap: () {
          if (context.mounted && roleConfig['page'] != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => roleConfig['page']));
          }
        },
      );
    }

    final profileData = json['profile'] != null ? Profile.fromJson(json['profile']) : const Profile(name: 'N/A', role: 'N/A', email: 'N/A', phone: 'N/A', imageUrl: '');
    final rolesData = (json['roles_summary'] as List? ?? []).map((i) => RoleSummary.fromJson(i)).toList();
    final eventsData = (json['events'] as List? ?? []).map((i) => UpcomingEvent.fromJson(i, context)).toList();

    void navigate(Widget page) {
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
    }

    return DashboardData(
      profile: profileData,
      accountStatistics: rolesData.map(mapRoleToStatistic).toList(),
      upcomingEvents: eventsData,
      quickActions: [
        QuickAction(label: "Students", icon: Icons.person_outline_sharp, onTap: () => navigate(const AddNewStudentPage())),
        QuickAction(label: "Add New Class", icon: Icons.book_outlined, onTap: () => navigate(const AddNewClassPage())),
        QuickAction(label: "Add New Subject", icon: Icons.book_rounded, onTap: () => navigate(const AddNewSubjectPage())),
        QuickAction(label: "Add Class Schedule", icon: Icons.calendar_month, onTap: () => navigate(const AddNewSchedulePage())),
      ],
      salaryInformation: [
        SalaryInformation(title: "My Salary", onTap: () => navigate(const MySalaryPage())),
        SalaryInformation(title: "Employees Salary", onTap: () => navigate(const EmployeesSalaryPage())),
      ],
      manageClasses: [
        ManageClass(title: "Class List", onTap: () => navigate(const ClassListPage())),
        ManageClass(title: "Subject List", onTap: () => navigate(const SubjectListPage())),
        ManageClass(title: "Time Table", onTap: () => navigate(const TimeTableClassesPage())),
        ManageClass(title: "Schedule", onTap: () => navigate(const ClassScheduleSearchPage())),
      ],
      feeStructure: [
        FeeStructure(title: "Fee Structure", onTap: () => navigate(const FeeStructurePage())),
        FeeStructure(title: "Student Fee Details", onTap: () => navigate(const StudentFeeDetailsPage())),
      ],
      examinations: [
        Examination(title: "Exam Info", onTap: () => navigate(const ExamInfoPage())),
        Examination(title: "Exam Result", onTap: () => navigate(const ExamResultPage())),
      ],
      library: [
        Library(title: "Available Books", onTap: () => navigate(const AvailableBooksScreen())),
        Library(title: "Lending Books", onTap: () => navigate(const LendingBooksScreen())),
      ],
      studyMaterial: [
        StudyMaterial(title: "Notes", onTap: () => navigate(const NotesPage())),
        StudyMaterial(title: "Assignments", onTap: () => navigate(const AssignmentsPage())),
      ],
      recentSupportTickets: [
        RecentSupportTicket(title: "Ticket Info", onTap: () => navigate(const TicketInfoPage())),
        RecentSupportTicket(title: "Assigned Ticket", onTap: () => navigate(const AssignedTicketsScreen())),
      ],
    );
  }
}


// ───────────────────────────────────────────────────────────
//                         API SERVICE
// ───────────────────────────────────────────────────────────

class DashboardApiService {
  Future<DashboardData> fetchDashboardData(BuildContext context) async {
    try {
      final response = await ApiService.get('manager/dashboard');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          // It's safer to check for `mounted` before using context across async gaps.
          if (context.mounted) {
            return DashboardData.fromJson(responseBody['data'], context);
          }
        }
      }
      // Throw an exception if we reach here, indicating a problem.
      throw Exception('Failed to load dashboard data.');
    } catch (e) {
      // Rethrow to be caught by FutureBuilder
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}

// ───────────────────────────────────────────────────────────
//                      DASHBOARD WIDGET
// ───────────────────────────────────────────────────────────

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  late Future<DashboardData> _dashboardDataFuture;
  final DashboardApiService _apiService = DashboardApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The context is safe to use here, so we pass it along.
    _dashboardDataFuture = _apiService.fetchDashboardData(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                backgroundColor: theme.primaryColor,
                child: Icon(Icons.school, color: theme.colorScheme.onPrimary)),
            const Icon(Icons.notifications),
          ],
        ),
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back, ${data.profile.name.split(' ').first}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10),
                    SearchBar(
                      leading: Icon(Icons.search, color: theme.colorScheme.onSurface),
                      hintText: "Search for students, teachers...",
                      hintStyle: WidgetStateProperty.all(TextStyle(color: theme.hintColor)),
                      elevation: const WidgetStatePropertyAll(2),
                      backgroundColor: WidgetStatePropertyAll(theme.cardColor),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          side: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomProfileBox(profile: data.profile),
                    const SizedBox(height: 20),
                    CustomQuickActionBox(actions: data.quickActions),
                    const SizedBox(height: 20),
                    CustomAccountStaticsBox(statistics: data.accountStatistics),
                    const SizedBox(height: 20),
                    CustomUpcomingEventsBox(events: data.upcomingEvents),
                    const SizedBox(height: 20),
                    CustomSalaryInformationBox(salaryInfo: data.salaryInformation),
                    const SizedBox(height: 20),
                    CustomManageClassesSectionBox(manageClasses: data.manageClasses),
                    const SizedBox(height: 20),
                    CustomFeeStructureBox(feeStructure: data.feeStructure),
                    const SizedBox(height: 20),
                    CustomExaminationsBox(examinations: data.examinations),
                    const SizedBox(height: 20),
                    CustomLibraryBox(library: data.library),
                    const SizedBox(height: 20),
                    CustomStudyMaterialBox(studyMaterial: data.studyMaterial),
                    const SizedBox(height: 20),
                    CustomRecentSupportTicketsBox(tickets: data.recentSupportTickets),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                      CUSTOM WIDGETS
// ───────────────────────────────────────────────────────────

class CustomProfileBox extends StatelessWidget {
  final Profile profile;
  const CustomProfileBox({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagerProfilePage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.onPrimary, size: 30),
                const SizedBox(width: 8),
                Text("Profile Overview", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary))
              ],
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.onPrimary.withAlpha(26), // 10% opacity
              child: profile.imageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profile.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(profile.name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
            Text(profile.role, style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(179))), // 70% opacity
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceAround,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.email, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile.email, style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    Text("Email", style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(179))), // 70% opacity
                  ])
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.phone, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile.phone, style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    Text("Phone", style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(179))), // 70% opacity
                  ])
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomQuickActionBox extends StatelessWidget {
  final List<QuickAction> actions;
  const CustomQuickActionBox({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: action.onTap,
                child: Container(
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [Icon(action.icon, color: theme.primaryColor), const SizedBox(width: 8), Flexible(child: Text(action.label, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis))]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomAccountStaticsBox extends StatelessWidget {
  final List<AccountStatistic> statistics;
  const CustomAccountStaticsBox({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Statics", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statistics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1),
            itemBuilder: (context, index) {
              final stat = statistics[index];
              return InkWell(
                onTap: stat.onTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(stat.icon, color: theme.primaryColor, size: 20), const SizedBox(width: 4), Text(stat.value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor))]),
                    const SizedBox(height: 4),
                    Text(stat.label, style: theme.textTheme.labelMedium, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomUpcomingEventsBox extends StatelessWidget {
  final List<UpcomingEvent> events;
  const CustomUpcomingEventsBox({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Upcoming Events", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final event = events[index];
              return InkWell(
                onTap: event.onTap,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.primaryColor.withAlpha(26), borderRadius: BorderRadius.circular(10)), // 10% opacity
                    child: Column(children: [Text(event.date, style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)), Text(event.day, style: theme.textTheme.labelLarge?.copyWith(color: theme.primaryColor))]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(event.fullDate, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  ]))
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomSalaryInformationBox extends StatelessWidget {
  final List<SalaryInformation> salaryInfo;
  const CustomSalaryInformationBox({super.key, required this.salaryInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Salary Information", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salaryInfo.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final info = salaryInfo[index];
              return InkWell(
                onTap: info.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(info.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomManageClassesSectionBox extends StatelessWidget {
  final List<ManageClass> manageClasses;
  const CustomManageClassesSectionBox({super.key, required this.manageClasses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Manage Classes", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: manageClasses.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, index) {
              final item = manageClasses[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [Icon(Icons.class_, color: theme.colorScheme.primary), const SizedBox(width: 8), Flexible(child: Text(item.title, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis))]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomFeeStructureBox extends StatelessWidget {
  final List<FeeStructure> feeStructure;
  const CustomFeeStructureBox({super.key, required this.feeStructure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Fee Structure", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: feeStructure.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = feeStructure[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomExaminationsBox extends StatelessWidget {
  final List<Examination> examinations;
  const CustomExaminationsBox({super.key, required this.examinations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Examinations", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: examinations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = examinations[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomLibraryBox extends StatelessWidget {
  final List<Library> library;
  const CustomLibraryBox({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Library", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: library.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = library[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomStudyMaterialBox extends StatelessWidget {
  final List<StudyMaterial> studyMaterial;
  const CustomStudyMaterialBox({super.key, required this.studyMaterial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Study Material", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studyMaterial.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = studyMaterial[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomRecentSupportTicketsBox extends StatelessWidget {
  final List<RecentSupportTicket> tickets;
  const CustomRecentSupportTicketsBox({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Support Tickets", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = tickets[index];
              return InkWell(
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: theme.textTheme.titleMedium), const Icon(Icons.arrow_forward_ios, size: 16)]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
