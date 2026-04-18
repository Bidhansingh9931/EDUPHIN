import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/manager_dashboard/recentSupportTickets/assigned_ticket.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
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
import 'library/book_requests.dart';
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
    return Profile(
      name: json['name'] ?? 'N/A',
      role: json['role']?['name'] ?? 'Manager', // Role might not be in profile data
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      imageUrl: ApiService.getStorageUrl(json['photo']),
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
      final name = role.name.toLowerCase();
      Widget? page;
      IconData icon = Icons.person;

      // Robust matching to handle "Manager" vs "Institute Manager", plural forms, etc.
      if (name.contains('manager')) {
        page = const ManagerListPage();
        icon = Icons.person_outline_sharp;
      } else if (name.contains('counselor')) {
        page = const CounselorListPage();
        icon = Icons.support_agent_sharp;
      } else if (name.contains('teacher')) {
        page = const TeacherListPage();
        icon = Icons.school_outlined;
      } else if (name.contains('librarian')) {
        page = const LibrarianListPage();
        icon = Icons.local_library;
      } else if (name.contains('accountant')) {
        page = const AccountantListPage();
        icon = Icons.account_balance;
      } else if (name.contains('staff')) {
        page = const StaffListPage();
        icon = Icons.work;
      }

      return AccountStatistic(
        label: role.name,
        value: role.count.toString(),
        icon: icon,
        onTap: () {
          if (context.mounted && page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
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
        Library(title: "Book Requests", onTap: () => navigate(const BookRequestsScreen())),
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
  void initState() {
    super.initState();
    // Move API call to initState to prevent multiple triggers during lifecycle changes
    _dashboardDataFuture = _apiService.fetchDashboardData(context);
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = context.theme;
    return SearchBar(
      leading: Icon(Icons.search, color: theme.hintColor, size: context.scale(20)),
      hintText: "Search for students, teachers...",
      hintStyle: WidgetStateProperty.all(theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(context.scale(12))),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _dashboardDataFuture = _apiService.fetchDashboardData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FutureBuilder<DashboardData>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Manager Dashboard", style: theme.appBarTheme.titleTextStyle),
                Text("Institution Overview", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, size: context.scale(24)),
                onPressed: () {},
              ),
                if (snapshot.hasData)
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerProfilePage())).then((_) => _retry()),
                    icon: ProfileAvatar(
                      imageUrl: snapshot.data!.profile.imageUrl,
                      radius: context.scale(16),
                    ),
                  ),
              SizedBox(width: context.scale(8)),
            ],
          ),
          body: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<DashboardData> snapshot) {
    final theme = context.theme;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}"),
            SizedBox(height: context.spacing),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (snapshot.hasData) {
      final data = snapshot.data!;
      return SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome back, ${data.profile.name.split(' ').first}",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(24),
                    )),
                SizedBox(height: context.spacing),
                _buildSearchBar(context),
                SizedBox(height: context.scale(24)),
                CustomProfileBox(profile: data.profile),
                SizedBox(height: context.scale(24)),
                CustomQuickActionBox(actions: data.quickActions),
                SizedBox(height: context.scale(24)),
                CustomAccountStaticsBox(statistics: data.accountStatistics),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Upcoming Events", Icons.event_note),
                SizedBox(height: context.scale(12)),
                CustomUpcomingEventsBox(events: data.upcomingEvents),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Salary Information", Icons.account_balance_wallet_outlined),
                SizedBox(height: context.scale(12)),
                CustomSalaryInformationBox(salaryInfo: data.salaryInformation),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Manage Classes", Icons.class_outlined),
                SizedBox(height: context.scale(12)),
                CustomManageClassesSectionBox(manageClasses: data.manageClasses),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Fee Structure", Icons.payments_outlined),
                SizedBox(height: context.scale(12)),
                CustomFeeStructureBox(feeStructure: data.feeStructure),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Examinations", Icons.assignment_outlined),
                SizedBox(height: context.scale(12)),
                CustomExaminationsBox(examinations: data.examinations),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Library", Icons.local_library_outlined),
                SizedBox(height: context.scale(12)),
                CustomLibraryBox(library: data.library),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Study Material", Icons.book_outlined),
                SizedBox(height: context.scale(12)),
                CustomStudyMaterialBox(studyMaterial: data.studyMaterial),
                SizedBox(height: context.scale(24)),
                _buildSectionHeader(context, "Recent Support Tickets", Icons.confirmation_number_outlined),
                SizedBox(height: context.scale(12)),
                CustomRecentSupportTicketsBox(tickets: data.recentSupportTickets),
                SizedBox(height: context.scale(40)),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Center(child: Text("No data available"));
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(18),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerProfilePage())),
          borderRadius: BorderRadius.circular(context.scale(20)),
          child: Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(
                  imageUrl: profile.imageUrl,
                  radius: context.scale(44),
                ),
                SizedBox(height: context.scale(16)),
                Text(
                  profile.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(20),
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  profile.role,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: context.font(14),
                  ),
                ),
                SizedBox(height: context.spacing),
                Wrap(
                  spacing: context.spacing,
                  runSpacing: context.spacing,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildProfileInfoItem(context, Icons.email_rounded, profile.email),
                    _buildProfileInfoItem(context, Icons.phone_rounded, profile.phone),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(BuildContext context, IconData icon, String value) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.scale(30)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.scale(16), color: colorScheme.primary),
          SizedBox(width: context.scale(8)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: context.font(12),
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomQuickActionBox extends StatelessWidget {
  final List<QuickAction> actions;
  const CustomQuickActionBox({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: context.scale(20), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text(
              "Quick Actions",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(18),
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: context.scale(12)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.responsive(2, tablet: 4, desktop: 4),
            childAspectRatio: 1.1,
            crossAxisSpacing: context.scale(12),
            mainAxisSpacing: context.scale(12),
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return QuickActionItem(
              label: action.label.toUpperCase(),
              icon: action.icon,
              onTap: action.onTap,
            );
          },
        ),
      ],
    );
  }
}

class CustomAccountStaticsBox extends StatelessWidget {
  final List<AccountStatistic> statistics;
  const CustomAccountStaticsBox({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(context.scale(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Statistics",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: context.font(18),
            ),
          ),
          SizedBox(height: context.spacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: statistics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.isDesktop ? 6 : (context.isTablet ? 3 : 3),
              crossAxisSpacing: context.scale(10),
              mainAxisSpacing: context.scale(10),
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final stat = statistics[index];
              return InkWell(
                onTap: stat.onTap,
                child: Container(
                  padding: EdgeInsets.all(context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(context.scale(12)),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(stat.icon, color: theme.colorScheme.primary, size: context.scale(18)),
                          SizedBox(width: context.scale(4)),
                          Flexible(
                            child: Text(
                              stat.value,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: context.font(18),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(4)),
                      Text(
                        stat.label,
                        style: theme.textTheme.labelMedium?.copyWith(fontSize: context.font(11)),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
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
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          separatorBuilder: (context, index) => Divider(height: context.scale(24), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          itemBuilder: (context, index) {
            final event = events[index];
            return InkWell(
              onTap: event.onTap,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.scale(10)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                    child: Column(
                      children: [
                        Text(event.date, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(18))),
                        Text(event.day, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontSize: context.font(12))),
                      ],
                    ),
                  ),
                  SizedBox(width: context.spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(event.fullDate, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: context.scale(20), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomSalaryInformationBox extends StatelessWidget {
  final List<SalaryInformation> salaryInfo;
  const CustomSalaryInformationBox({super.key, required this.salaryInfo});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: salaryInfo.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final info = salaryInfo[index];
            return InkWell(
              onTap: info.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(info.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomManageClassesSectionBox extends StatelessWidget {
  final List<ManageClass> manageClasses;
  const CustomManageClassesSectionBox({super.key, required this.manageClasses});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: manageClasses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isDesktop ? 4 : (context.isTablet ? 3 : 2),
            childAspectRatio: 2.8,
            crossAxisSpacing: context.scale(12),
            mainAxisSpacing: context.scale(12),
          ),
          itemBuilder: (context, index) {
            final item = manageClasses[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                padding: EdgeInsets.all(context.scale(10)),
                child: Row(
                  children: [
                    Icon(Icons.class_rounded, color: theme.colorScheme.primary, size: context.scale(18)),
                    SizedBox(width: context.scale(8)),
                    Flexible(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(13), fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomFeeStructureBox extends StatelessWidget {
  final List<FeeStructure> feeStructure;
  const CustomFeeStructureBox({super.key, required this.feeStructure});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feeStructure.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final item = feeStructure[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomExaminationsBox extends StatelessWidget {
  final List<Examination> examinations;
  const CustomExaminationsBox({super.key, required this.examinations});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: examinations.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final item = examinations[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomLibraryBox extends StatelessWidget {
  final List<Library> library;
  const CustomLibraryBox({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: library.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final item = library[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomStudyMaterialBox extends StatelessWidget {
  final List<StudyMaterial> studyMaterial;
  const CustomStudyMaterialBox({super.key, required this.studyMaterial});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: studyMaterial.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final item = studyMaterial[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomRecentSupportTicketsBox extends StatelessWidget {
  final List<RecentSupportTicket> tickets;
  const CustomRecentSupportTicketsBox({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
          itemBuilder: (context, index) {
            final item = tickets[index];
            return InkWell(
              onTap: item.onTap,
              child: Container(
                padding: EdgeInsets.all(context.scale(14)),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(15), fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_ios, size: context.scale(14), color: theme.colorScheme.primary),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
