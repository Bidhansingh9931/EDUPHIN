import 'package:eduphin/manager_dashboard/account_statics/accountant/accountant_list.dart';
import 'package:eduphin/manager_dashboard/account_statics/institute_manager/manager_list.dart';
import 'package:eduphin/manager_dashboard/events/event_management.dart';
import 'package:eduphin/manager_dashboard/manageClasses/schedule/class_schedule_search.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/subject_list.dart';
import 'package:eduphin/manager_dashboard/manageClasses/timeTable/time_table.dart';
import 'package:eduphin/manager_dashboard/quick_actions/add_new_class.dart';
import 'package:eduphin/manager_dashboard/quick_actions/add_new_schedule.dart';
import 'package:eduphin/manager_dashboard/quick_actions/add_new_student.dart';
import 'package:eduphin/manager_dashboard/quick_actions/add_new_subject.dart';
import 'package:eduphin/manager_dashboard/recentSupportTickets/ticket_info.dart';
import 'package:eduphin/manager_dashboard/salary_information/employees_salary.dart';
import 'package:eduphin/manager_dashboard/salary_information/my_salary.dart';
import 'package:eduphin/manager_dashboard/studyMaterial/assignments.dart';
import 'package:eduphin/manager_dashboard/studyMaterial/notes.dart';
import 'package:flutter/material.dart';

import 'account_statics/counselor/counselor_list.dart';
import 'account_statics/librarian/librarian_list.dart';
import 'account_statics/staff/staff_list.dart';
import 'account_statics/teacher/teacher_list.dart';
import 'examinations/exam_info.dart';
import 'examinations/exam_result.dart';
import 'feeStructure/fee_Structure/fee_structure.dart';
import 'feeStructure/studentFeeDetails/student_fee_details.dart';
import 'library/available_books.dart';
import 'library/lending_books.dart';
import 'manageClasses/classList/class_list.dart';
import 'manager_profile.dart';

// Data Models
class Profile {
  final String name;
  final String role;
  final String email;
  final String phone;
  final String imageUrl;

  Profile({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });
}

class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class AccountStatistic {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  AccountStatistic({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
}

class UpcomingEvent {
  final String title;
  final String date;
  final String day;
  final VoidCallback onTap;

  UpcomingEvent({
    required this.title,
    required this.date,
    required this.day,
    required this.onTap,
  });
}

class SalaryInformation {
  final String title;
  final VoidCallback onTap;

  SalaryInformation({
    required this.title,
    required this.onTap,
  });
}

class ManageClass {
  final String title;
  final VoidCallback onTap;

  ManageClass({
    required this.title,
    required this.onTap,
  });
}

class FeeStructure {
  final String title;
  final VoidCallback onTap;

  FeeStructure({
    required this.title,
    required this.onTap,
  });
}

class Examination {
  final String title;
  final VoidCallback onTap;

  Examination({
    required this.title,
    required this.onTap,
  });
}

class Library {
  final String title;
  final VoidCallback onTap;

  Library({
    required this.title,
    required this.onTap,
  });
}

class StudyMaterial {
  final String title;
  final VoidCallback onTap;

  StudyMaterial({
    required this.title,
    required this.onTap,
  });
}

class RecentSupportTicket {
  final String title;
  final VoidCallback onTap;

  RecentSupportTicket({
    required this.title,
    required this.onTap,
  });
}
class Transport {
  final String title;
  final VoidCallback onTap;

  Transport({
    required this.title,
    required this.onTap,
  });
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
  final List<Transport> transport;
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
    required this.transport,
    required this.recentSupportTickets,
  });
}

// Mock API Service
class MockDashboardApiService {
  Future<DashboardData> fetchDashboardData(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    return DashboardData(
      profile: Profile(
        name: "Rajeev K.Malhotra",
        role: "General Manager",
        email: "raj@iias",
        phone: "9812345678",
        imageUrl: "assets/images/random_boy.jpg",
      ),
      quickActions: [
        QuickAction(label: "Students", icon: Icons.person_outline_sharp, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewStudentPage()))),
        QuickAction(label: "Add New Class", icon: Icons.book_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewClassPage()))),
        QuickAction(label: "Add New Subject", icon: Icons.book_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewSubjectPage()))),
        QuickAction(label: "Add Class Schedule", icon: Icons.calendar_month, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewSchedulePage()))),
      ],
      accountStatistics: [
        AccountStatistic(label: "Institute Manager", value: "1", icon: Icons.person_outline_sharp, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerListPage()))),
        AccountStatistic(label: "Counselors", value: "2", icon: Icons.support_agent_sharp, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CounselorListPage()))),
        AccountStatistic(label: "Teacher", value: "2", icon: Icons.school_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherListPage()))),
        AccountStatistic(label: "Librarian", value: "2", icon: Icons.local_library, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LibrarianListPage()))),
        AccountStatistic(label: "Accountants", value: "2", icon: Icons.account_balance, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountantListPage()))),
        AccountStatistic(label: "Staff", value: "2", icon: Icons.work, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffListPage()))),
      ],
      upcomingEvents: [
        UpcomingEvent(title: "Annual Financial Literacy Working 2025", date: "12", day: "Dec", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventManagementPage()))),
        UpcomingEvent(title: "Campus Cultural Fest 2025", date: "03", day: "Jan", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventManagementPage()))),
      ],
      salaryInformation: [
        SalaryInformation(title: "My Salary", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MySalaryPage()))),
        SalaryInformation(title: "Employees Salary", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeesSalaryPage()))),
      ],
      manageClasses: [
        ManageClass(title: "Class List", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClassListPage()))),
        ManageClass(title: "Subject List", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectListPage()))),
        ManageClass(title: "Time Table", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimeTableClassesPage()))),
        ManageClass(title: "Schedule", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClassScheduleSearchPage()))),
      ],
      feeStructure: [
        FeeStructure(title: "Fee Structure", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FeeStructurePage()))),
        FeeStructure(title: "Student Fee Details", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentFeeDetailsPage()))),
      ],
      examinations: [
        Examination(title: "Exam Info", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExamInfoPage()))),
        Examination(title: "Exam Result", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExamResultPage()))),
      ],
      library: [
        Library(title: "Available Books", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AvailableBooksScreen()))),
        Library(title: "Lending Books", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LendingBooksScreen()))),
      ],
      studyMaterial: [
        StudyMaterial(title: "Notes", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage()))),
        StudyMaterial(title: "Assignments", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AssignmentsPage()))),
      ],
      transport: [
        Transport(title: "Vehicle Tracking", onTap: () {}),
        Transport(title: "Vehicle Details", onTap: () {}),
      ],
      recentSupportTickets: [
        RecentSupportTicket(title: "Ticket Info", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketInfoPage()))),
        RecentSupportTicket(title: "Assigned Ticket", onTap: () {}),
      ],
    );
  }
}

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  late Future<DashboardData> _dashboardDataFuture;
  final MockDashboardApiService _apiService = MockDashboardApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                child: Image.asset('assets/images/eduphin_logo_bg.png', height: 40, width: 40)),
            Icon(Icons.notifications, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
                      leading:
                      Icon(Icons.search, color: theme.colorScheme.onSurface),
                      hintText: "Search for students, teachers...",
                      hintStyle: WidgetStateProperty.all(TextStyle(
                        color: theme.hintColor,
                      )),
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
                    // const SizedBox(height: 20),
                    // CustomTransportBox(transport: data.transport),
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

class CustomProfileBox extends StatelessWidget {
  final Profile profile;
  const CustomProfileBox({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ManagerProfilePage())),
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
                Text("Profile Overview",
                    style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary))
              ],
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(profile.imageUrl),
            ),
            const SizedBox(height: 8),
            Text(profile.name,
                style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary)),
            Text(profile.role, style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceAround,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.email, style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                        Text("Email", style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.phone, style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                        Text("Phone", style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomQuickActionBox extends StatelessWidget {
  final List<QuickAction> actions;
  const CustomQuickActionBox({super.key, required this.actions});

  Widget _buildActionItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_attraction_outlined,
                  color: theme.colorScheme.onPrimary, size: 30),
              const SizedBox(width: 8),
              Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary),
              )
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.0,
                ),
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return InkWell(
                    onTap: action.onTap,
                    child: _buildActionItem(context, action.icon, action.label),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class CustomAccountStaticsBox extends StatelessWidget {
  final List<AccountStatistic> statistics;
  const CustomAccountStaticsBox({super.key, required this.statistics});

  Widget _buildStatisticItem(
      BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 4),
          Text(value, style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180)),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              Icon(Icons.person_outline_sharp, color: theme.colorScheme.onPrimary),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Account Statics",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statistics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final statistic = statistics[index];
                return InkWell(
                  onTap: statistic.onTap,
                  child: _buildStatisticItem(
                      context, statistic.icon, statistic.value, statistic.label),
                );
              },
            );
          }),
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
    final textTheme = theme.textTheme;
    return InkWell(
      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EventManagementPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 30, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text("Upcoming Events",
                    style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(event.date,
                              style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                          Text(event.day,
                              style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Friday, December 12", // This should be dynamic
                              style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.money, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Salary Information",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: salaryInfo.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = salaryInfo[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

class CustomManageClassesSectionBox extends StatelessWidget {
  final List<ManageClass> manageClasses;
  const CustomManageClassesSectionBox({super.key, required this.manageClasses});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_work_outlined, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Manage Classes",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: manageClasses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = manageClasses[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

class CustomFeeStructureBox extends StatelessWidget {
  final List<FeeStructure> feeStructure;
  const CustomFeeStructureBox({super.key, required this.feeStructure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_sharp, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Fee Structure",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: feeStructure.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = feeStructure[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

class CustomExaminationsBox extends StatelessWidget {
  final List<Examination> examinations;
  const CustomExaminationsBox({super.key, required this.examinations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.app_registration, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Examinations",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: examinations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = examinations[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

class CustomLibraryBox extends StatelessWidget {
  final List<Library> library;
  const CustomLibraryBox({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_library, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Library",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: library.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = library[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

class CustomStudyMaterialBox extends StatelessWidget {
  final List<StudyMaterial> studyMaterial;
  const CustomStudyMaterialBox({super.key, required this.studyMaterial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_sharp, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Study Material",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studyMaterial.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = studyMaterial[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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

// class CustomTransportBox extends StatelessWidget {
//   final List<Transport> transport;
//   const CustomTransportBox({super.key, required this.transport});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: theme.primaryColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.directions_bus, size: 30, color: theme.colorScheme.onPrimary),
//               const SizedBox(width: 8),
//               Text("Transport",
//                   style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
//             ],
//           ),
//           const SizedBox(
//             height: 16,
//           ),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: transport.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final item = transport[index];
//               return Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.onPrimary.withAlpha(25),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: InkWell(
//                   onTap: item.onTap,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(item.title,
//                           style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
//                       Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),

class CustomRecentSupportTicketsBox extends StatelessWidget {
  final List<RecentSupportTicket> tickets;
  const CustomRecentSupportTicketsBox({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Recent Support Tickets",
                  style: textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = tickets[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: item.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title,
                          style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      Icon(Icons.arrow_forward_ios_sharp,size: 20,color: theme.colorScheme.onPrimary,),
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
