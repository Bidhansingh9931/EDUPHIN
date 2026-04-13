import 'package:eduphin/teacher/dashboard/app_drawer.dart';
import 'package:eduphin/teacher/dashboard/profile.dart';
import 'package:eduphin/teacher/dashboard/salary_bank_details.dart';
import 'package:eduphin/teacher/dashboard/virtual_id_page.dart';
import 'package:eduphin/teacher/dashboard/your_support_ticket.dart';
import 'package:eduphin/teacher/dashboard/create_new_support_ticket.dart';
import 'package:eduphin/staff/staff_dashboard/fee_structure.dart';
import 'package:eduphin/staff/staff_dashboard/student_fee_detail.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'exam_information_page.dart';
import 'explore_events.dart';
import 'library_book_page.dart';
import 'lending_books_page.dart';
import 'my_registered_event.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  late Future<TeacherDashboardData> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = ApiService.getTeacherDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Teacher Dashboard", style: theme.appBarTheme.titleTextStyle),
            Text("Overview & Management", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_outline, size: 20, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<TeacherDashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildDashboardContent(context, snapshot.data!);
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text("Failed to load dashboard", style: Theme.of(context).textTheme.titleMedium),
          Text(error, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() { _dashboardDataFuture = ApiService.getTeacherDashboard(); }),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TeacherDashboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() { _dashboardDataFuture = ApiService.getTeacherDashboard(); });
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Overview Section
          _buildProfileOverview(data.userDetail),
          const SizedBox(height: 20),

          // Quick Actions
          _buildSectionHeader("Quick Actions", Icons.bolt),
          const SizedBox(height: 12),
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Salary Section
          _buildSectionHeader("My Salary", Icons.payments_outlined),
          const SizedBox(height: 12),
          _buildSalaryCard(data),
          const SizedBox(height: 24),

          // Library Section
          _buildSectionHeader("Library", Icons.local_library_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("Available Books", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()))),
            _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()))),
          ]),
          const SizedBox(height: 24),

          // Examinations Section
          _buildSectionHeader("Examinations", Icons.assignment_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("Examination Information", Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()))),
          ]),
          const SizedBox(height: 24),

          // Event Management Section
          _buildSectionHeader("Event Management", Icons.event_note_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("Explore Events", Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()))),
            _buildMenuItem("My Registered Events", Icons.how_to_reg_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventPage()))),
          ]),
          const SizedBox(height: 24),

          // Support Ticket Section
          _buildSectionHeader("Support Ticket", Icons.support_agent_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("My Tickets", Icons.confirmation_number_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()))),
            _buildMenuItem("Assigned Tickets", Icons.assignment_ind_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()))),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileOverview(UserDetail user) {
    final theme = Theme.of(context);
    final photoUrl = user.photo != null ? ApiService.getStorageUrl(user.photo) : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: const AssetImage('assets/images/girl_image.webp'),
                  foregroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(user.roleName ?? "Teacher", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileInfoItem(Icons.badge_outlined, user.employeeId ?? "N/A"),
                _buildProfileInfoItem(Icons.phone_outlined, user.phone ?? "N/A"),
                _buildProfileInfoItem(Icons.location_on_outlined, "Campus Main"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualIdPage())),
              icon: const Icon(Icons.vignette_outlined, size: 18),
              label: const Text("GENERATE VIRTUAL ID CARD"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _quickActionButton("FEE STRUCTURE", Icons.account_balance_wallet_outlined, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffFeeStructurePage()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickActionButton("STUDENT FEES", Icons.payments_outlined, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffStudentFeeDetailPage()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickActionButton("CREATE TICKET", Icons.add_circle_outline, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage()));
        })),
      ],
    );
  }

  Widget _quickActionButton(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(TeacherDashboardData data) {
    final theme = Theme.of(context);
    final salary = data.lastSalary;

    if (salary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("No Salary Data", style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 8),
              const Text("Your salary details will appear here once processed."),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankDetailsPage())),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("₹${salary.amount.toStringAsFixed(2)}", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text("Last processed payment", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSalaryInfoRow("Status", salary.status, salary.status.toLowerCase() == 'paid' ? Colors.green : Colors.orange),
                  _buildSalaryInfoRow("Payment Date", salary.paymentDate ?? "Pending", theme.colorScheme.onSurface),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryInfoRow(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx != children.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
