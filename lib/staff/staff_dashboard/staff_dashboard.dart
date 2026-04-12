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
import 'staff_profile.dart';
import 'employee_list.dart';
import 'fee_structure.dart';
import 'student_fee_detail.dart';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context, user?.name ?? 'Staff Member', userDetail?.photo),
                  const SizedBox(height: 24),

                  Text(
                    "Quick Actions",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // Responsive Grid for Main Sections
                  if (context.isTablet)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildProfileOverview(context, userDetail),
                        _buildSupportTicketCard(context),
                      ],
                    )
                  else ...[
                    _buildProfileOverview(context, userDetail),
                    const SizedBox(height: 16),
                    _buildSupportTicketCard(context),
                  ],

                  const SizedBox(height: 24),
                  _buildLibraryCard(context),
                  const SizedBox(height: 16),
                  _buildExaminationsCard(context),
                  const SizedBox(height: 16),
                  _buildFeeManagementCard(context),
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
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.dashboard_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: photoUrl != null
                          ? NetworkImage('${ApiService.baseUrl}/storage/$photoUrl')
                          : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffVirtualIdCard()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.badge_rounded, size: 20),
                  label: const Text("VIRTUAL ID CARD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionItem(
            context,
            icon: Icons.people_alt_rounded,
            label: "Employee List",
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeListPage())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionItem(
            context,
            icon: Icons.person_outline_rounded,
            label: "My Profile",
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffProfilePage())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionItem(
            context,
            icon: Icons.add_task_rounded,
            label: "New Ticket",
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffCreateTicketPage())),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile Details",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffProfilePage())),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: userDetail?.photo != null
                        ? NetworkImage('${ApiService.baseUrl}/storage/${userDetail!.photo}')
                        : null,
                    child: userDetail?.photo == null
                        ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 30)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Staff Name',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.phone_android_rounded, userDetail?.phone ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.location_on_outlined, userDetail?.address ?? 'No Address'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
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

  Widget _buildFeeManagementCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Fee Management",
      icon: Icons.account_balance_wallet_rounded,
      items: [
        {"title": "Fee Structure", "page": const StaffFeeStructurePage()},
        {"title": "Student Fee Details", "page": const StaffStudentFeeDetailPage()},
      ],
    );
  }

  Widget _buildSalaryDetailCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: "Finance & Payroll",
      icon: Icons.payments_rounded,
      items: [
        {"title": "Salary Details", "page": const StaffSalaryDetailPage()},
      ],
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final int idx = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildRowItem(context, item["title"], item["page"]),
                    if (idx < items.length - 1)
                      Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor.withValues(alpha: 0.05)),
                  ],
                );
              }).toList(),
            ),
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
