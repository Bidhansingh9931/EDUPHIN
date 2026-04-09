import 'package:flutter/material.dart';
import '../../teacher/dashboard/app_drawer.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';
import 'salary_detail.dart';
import 'support_tickets.dart';
import 'create_ticket.dart';
import 'assigned_tickets.dart';
import 'event_management.dart';
import 'examinations.dart';
import 'library.dart';
import 'lending_books.dart';
import 'virtual_id_card.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late Future<StaffDashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = ApiService.getStaffDashboard();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardData = ApiService.getStaffDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<StaffDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: context.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load dashboard',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString().replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            final userDetail = data.userDetail;
            final user = userDetail?.user;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: context.pagePadding,
              child: Column(
                children: [
                  _buildWelcomeCard(context, user?.name ?? 'Staff Member', userDetail?.photo),
                  const SizedBox(height: 24),

                  // Responsive Grid for Main Sections
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: context.isTablet ? 2 : 1,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: context.isTablet ? 1.5 : 1.2,
                        children: [
                          _buildProfileOverview(context, userDetail),
                          _buildSupportTicketCard(context),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildLibraryCard(context),
                  const SizedBox(height: 16),
                  _buildExaminationsCard(context),
                  const SizedBox(height: 16),
                  _buildSalaryDetailCard(context),
                  const SizedBox(height: 16),
                  _buildEventManagementCard(context),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name, String? photoUrl) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.primary,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Text(
              "Welcome back, $name!",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Your personalized workspace awaits.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffVirtualIdCard()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.primary,
                minimumSize: const Size(200, 48),
              ),
              icon: const Icon(Icons.badge_rounded),
              label: const Text("VIRTUAL ID CARD"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context, UserDetail? userDetail) {
    final theme = Theme.of(context);
    final user = userDetail?.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Profile Overview",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: userDetail?.photo != null
                  ? NetworkImage('${ApiService.baseUrl}/storage/${userDetail!.photo}')
                  : null,
              child: userDetail?.photo == null
                  ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Staff Name',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'email@example.com',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const Spacer(),
            _buildInfoRow(context, Icons.phone_outlined, userDetail?.phone ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLibraryCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Library Resources",
      icon: Icons.local_library_rounded,
      items: [
        {"title": "Available Books", "page": const StaffLibraryPage()},
        {"title": "Lending Books", "page": const MyLendingBooksPage()},
      ],
    );
  }

  Widget _buildExaminationsCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Academic & Exams",
      icon: Icons.assignment_rounded,
      items: [
        {"title": "Examination Info", "page": const StaffExaminationsPage()},
      ],
    );
  }

  Widget _buildSalaryDetailCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffSalaryDetailPage())),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.payments_rounded, color: theme.colorScheme.primary),
        ),
        title: const Text("Salary Details", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("View your monthly pay stubs"),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildEventManagementCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Events",
      icon: Icons.event_rounded,
      items: [
        {"title": "Upcoming Events", "page": const StaffEventManagementPage()},
      ],
    );
  }

  Widget _buildSupportTicketCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Support Helpdesk",
      icon: Icons.support_agent_rounded,
      items: [
        {"title": "My Tickets", "page": const StaffSupportTicketsPage()},
        {"title": "Create New Ticket", "page": const StaffCreateTicketPage()},
        {"title": "Assigned to Me", "page": const StaffAssignedTicketsPage()},
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required List<Map<String, dynamic>> items}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: items.map((item) => _buildRowItem(context, item["title"], item["page"])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRowItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}
