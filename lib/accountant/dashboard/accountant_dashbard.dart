import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'accountant_profile.dart';
import 'generate_virtual_card.dart';
import 'fee_structure.dart';
import 'student_fee_detail.dart';
import 'employee_list.dart';
import 'salary_slips.dart';
import 'library_books.dart';
import 'lending_books.dart';
import 'support_tickets.dart';
import 'create_ticket.dart';
import 'event_list.dart';
import 'exam_list.dart';
import 'accountant_dashboard_model.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  late Future<AccountantDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardFuture = ApiService.getAccountantDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Financial Overview & Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Dashboard",
              style: TextStyle(color: colorScheme.secondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<AccountantDashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text("Error: ${snapshot.error}"),
                    TextButton(onPressed: _refreshData, child: const Text("Retry")),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No data found"));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGenerateCardButton(context),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, data),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildProfileOverview(context, data.userDetail),
                  const SizedBox(height: 24),
                  _buildMySalarySection(context, data.lastSalary),
                  const SizedBox(height: 24),
                  _buildMenuSection(context, "Fee Information", Icons.payments_outlined, [
                    _MenuItem("Fee Structure", Icons.chevron_right, const FeeStructurePage()),
                    _MenuItem("Student Fee Detail", Icons.chevron_right, const StudentFeeDetailPage()),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, "Library", Icons.library_books_outlined, [
                    _MenuItem("Available Books", Icons.chevron_right, const LibraryBooksPage()),
                    _MenuItem("Lending Books", Icons.chevron_right, const LendingBooksPage()),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, "Examinations", Icons.assignment_outlined, [
                    _MenuItem("Examination Information", Icons.chevron_right, const ExamListPage()),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, "Event Management", Icons.calendar_month_outlined, [
                    _MenuItem("Events List", Icons.chevron_right, const EventListPage()),
                    _MenuItem("Registered Events", Icons.chevron_right, const EventListPage(showRegisteredOnly: true)),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, "Support Ticket", Icons.confirmation_number_outlined, [
                    _MenuItem("My Ticket", Icons.chevron_right, const SupportTicketsPage()),
                    _MenuItem("Submit New Ticket", Icons.chevron_right, const CreateTicketPage()),
                    _MenuItem("Assigned Ticket", Icons.chevron_right, const SupportTicketsPage(isAssigned: true)),
                  ]),
                  const SizedBox(height: 12),
                  _buildMenuSection(context, "Employee Detail", Icons.groups_outlined, [
                    _MenuItem("Manager", Icons.chevron_right, const EmployeeListPage(roleId: 3)),
                    _MenuItem("Counselors", Icons.chevron_right, const EmployeeListPage(roleId: 4)),
                    _MenuItem("Teachers", Icons.chevron_right, const EmployeeListPage(roleId: 5)),
                    _MenuItem("Librarian", Icons.chevron_right, const EmployeeListPage(roleId: 7)),
                    _MenuItem("Accountants", Icons.chevron_right, const EmployeeListPage(roleId: 8)),
                    _MenuItem("Staff", Icons.chevron_right, const EmployeeListPage(roleId: 9)),
                  ]),
                  const SizedBox(height: 24),
                  _buildListSection(context, "Institute Salaries", Icons.account_balance_wallet_outlined, data.salaryList, "salary"),
                  const SizedBox(height: 16),
                  _buildListSection(context, "Recent Payments", Icons.history_rounded, data.payments, "payment"),
                  const SizedBox(height: 16),
                  _buildListSection(context, "Fines & Penalties", Icons.gavel_rounded, data.fines, "fine"),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenerateCardButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateVirtualCard())),
        icon: const Icon(Icons.credit_card_rounded, size: 20),
        label: const Text("GENERATE VIRTUAL ID CARD"),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AccountantDashboardData data) {
    final theme = Theme.of(context);
    double totalPayments = data.payments.fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double instFees = data.instituteFees.fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double classFees = data.classFees.fold(0.0, (sum, item) => sum + double.parse(item.amount));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.isTablet ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, "₹${NumberFormat('#,##,###').format(totalPayments)}", "Top Payments", Icons.camera_alt_outlined, Colors.purpleAccent),
        _buildStatCard(context, "84%", "Compliance", Icons.trending_up_rounded, theme.colorScheme.secondary),
        _buildStatCard(context, "₹${NumberFormat('#,##,###').format(instFees)}", "Institute Fees", Icons.account_balance_rounded, Colors.orangeAccent),
        _buildStatCard(context, "₹${NumberFormat('#,##,###').format(classFees)}", "Class Fees", Icons.school_outlined, Colors.greenAccent),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            FittedBox(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Text(label, style: TextStyle(color: theme.hintColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButton(context, "FEE STRUCTURE", Icons.account_balance_wallet_outlined, const FeeStructurePage()),
            const SizedBox(height: 8),
            _buildActionButton(context, "MANAGE STUDENT FEES", Icons.group_add_outlined, const StudentFeeDetailPage()),
            const SizedBox(height: 8),
            _buildActionButton(context, "+ CREATE TICKET", Icons.add_comment_rounded, const CreateTicketPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Widget page) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context, UserDetail user) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                const Text("Profile Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountantProfile())),
                  child: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: user.photo != null ? NetworkImage("${ApiService.baseUrl}/storage/${user.photo}") : null,
              child: user.photo == null ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary) : null,
            ),
            const SizedBox(height: 12),
            Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Senior Accountant", style: TextStyle(color: theme.colorScheme.secondary, fontSize: 13)),
            const SizedBox(height: 20),
            _buildProfileDetail(context, Icons.badge_outlined, "Employee ID", user.userId.toString()),
            const Divider(height: 24),
            _buildProfileDetail(context, Icons.phone_iphone_rounded, "Phone No", user.phone ?? "N/A"),
            const Divider(height: 24),
            _buildProfileDetail(context, Icons.calendar_today_rounded, "Joining Date", user.joiningDate ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.hintColor, size: 18),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMySalarySection(BuildContext context, Salary? lastSalary) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                const Text("My Salary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalarySlipsPage())),
                  child: Icon(Icons.launch_rounded, color: theme.hintColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text("₹${lastSalary != null ? NumberFormat('#,##,###').format(double.parse(lastSalary.amount)) : '0.00'}", 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text("Last paid: ${lastSalary?.month ?? 'N/A'}", style: TextStyle(color: theme.hintColor, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text("Status", style: TextStyle(color: theme.hintColor, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Text("Paid", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text("Payment Date", style: TextStyle(color: theme.hintColor, fontSize: 14)),
                const Spacer(),
                Text(lastSalary?.paymentDate ?? "N/A", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, IconData headerIcon, List<_MenuItem> items) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(headerIcon, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...items.map((item) => ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item.page)),
                title: Text(item.title, style: const TextStyle(fontSize: 14)),
                trailing: Icon(item.trailing, color: theme.hintColor, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
                visualDensity: VisualDensity.compact,
              )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, IconData icon, List<dynamic> items, String type) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (items.isEmpty)
             Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text("No $type records available.", style: TextStyle(color: theme.hintColor, fontSize: 13)),
            )
          else
            ...items.take(3).map((item) {
              String mainText = "";
              String subText = "";
              String amount = "";

              if (type == "salary") {
                mainText = item.month ?? "Salary Record";
                subText = "Salary Paid";
                amount = "₹${NumberFormat('#,##,###').format(double.parse(item.amount))}";
              } else if (type == "payment") {
                mainText = item.date;
                subText = "Payment Received";
                amount = "₹${NumberFormat('#,##,###').format(double.parse(item.amount))}";
              } else if (type == "fine") {
                mainText = item.reason;
                subText = item.date;
                amount = "₹${NumberFormat('#,##,###').format(double.parse(item.amount))}";
              }

              return Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mainText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(subText, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            }),
          if (items.length > 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Center(
                child: Text("+${items.length - 3} more records", 
                  style: TextStyle(color: theme.hintColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData trailing;
  final Widget page;
  _MenuItem(this.title, this.trailing, this.page);
}
