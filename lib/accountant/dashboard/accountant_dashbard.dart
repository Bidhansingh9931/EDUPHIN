import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/common_widgets.dart';
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
import 'accountant_dashboard_model.dart' as accountant_model;
import '../../services/error_handler.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  Stream<accountant_model.AccountantDashboardData>? _dashboardStream;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardStream = ApiService.getAccountantDashboardStream().handleError((error) {
        if (mounted) ErrorHandler.showError(context, error);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1630) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Financial Overview",
                        style: TextStyle(
                          fontSize: context.font(16),
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : colorScheme.secondary,
                          fontSize: context.font(12),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : Colors.black),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: isDark ? Colors.white : Colors.black),
                        onPressed: () async {
                          try {
                            await ApiService.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                    (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) ErrorHandler.showError(context, e);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<accountant_model.AccountantDashboardData>(
        stream: _dashboardStream,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              await _dashboardStream?.first;
            },
            child: LoadingWrapper<accountant_model.AccountantDashboardData>(
              snapshot: snapshot,
              skeleton: _buildSkeleton(context),
              onRetry: _refreshData,
              builder: (data) => _buildContent(context, data),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, accountant_model.AccountantDashboardData data) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGenerateCardButton(context),
          SizedBox(height: context.md),
          _buildStatsGrid(context, data),
          SizedBox(height: context.md),
          if (context.isTablet || context.isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildQuickActions(context),
                      SizedBox(height: context.md),
                      _buildMySalarySection(context, data.lastSalary),
                      SizedBox(height: context.md),
                      _buildListSection(context, "Institute Salaries", Icons.account_balance_wallet_outlined, data.salaryList, "salary"),
                      SizedBox(height: context.md),
                      _buildListSection(context, "Recent Payments", Icons.history_rounded, data.payments, "payment"),
                      SizedBox(height: context.md),
                      _buildListSection(context, "Fines & Penalties", Icons.gavel_rounded, data.fines, "fine"),
                    ],
                  ),
                ),
                SizedBox(width: context.md),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      _buildProfileOverview(context, data.userDetail),
                      SizedBox(height: context.md),
                      _buildMenuGrid(context, data),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildQuickActions(context),
            SizedBox(height: context.md),
            _buildProfileOverview(context, data.userDetail),
            SizedBox(height: context.md),
            _buildMySalarySection(context, data.lastSalary),
            SizedBox(height: context.md),
            _buildMenuGrid(context, data),
            SizedBox(height: context.md),
            _buildListSection(context, "Institute Salaries", Icons.account_balance_wallet_outlined, data.salaryList, "salary"),
            SizedBox(height: context.md),
            _buildListSection(context, "Recent Payments", Icons.history_rounded, data.payments, "payment"),
            SizedBox(height: context.md),
            _buildListSection(context, "Fines & Penalties", Icons.gavel_rounded, data.fines, "fine"),
          ],
          SizedBox(height: context.xl),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 50, width: double.infinity),
          SizedBox(height: context.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isMobile ? 2 : 4,
            crossAxisSpacing: context.sm,
            mainAxisSpacing: context.sm,
            childAspectRatio: context.isMobile ? 1.0 : 1.4,
            children: List.generate(4, (index) => const Skeleton(borderRadius: 16)),
          ),
          SizedBox(height: context.md),
          const Skeleton(height: 180, width: double.infinity, borderRadius: 16),
          SizedBox(height: context.md),
          const Skeleton(height: 250, width: double.infinity, borderRadius: 16),
          SizedBox(height: context.md),
          const Skeleton(height: 150, width: double.infinity, borderRadius: 16),
          SizedBox(height: context.md),
          const Skeleton(height: 300, width: double.infinity, borderRadius: 16),
        ],
      ),
    );
  }

  Widget _buildGenerateCardButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateVirtualCard())),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF2C3550) : theme.colorScheme.surface,
          foregroundColor: isDark ? Colors.white : theme.colorScheme.primary,
          side: BorderSide(color: isDark ? Colors.white24 : theme.colorScheme.primary.withValues(alpha: 0.3)),
          padding: EdgeInsets.symmetric(vertical: context.isMobile ? 12 : 16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_rounded, size: 20),
              const SizedBox(width: 8),
              const Text("GENERATE VIRTUAL ID CARD"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, accountant_model.AccountantDashboardData data) {
    final isDark = context.isDarkMode;
    double totalPayments = data.payments.fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double instFees = data.instituteFees.fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double classFees = data.classFees.fold(0.0, (sum, item) => sum + double.parse(item.amount));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.responsive(2, tablet: 4, desktop: 4),
      crossAxisSpacing: context.sm,
      mainAxisSpacing: context.sm,
      childAspectRatio: context.responsive(1.0, tablet: 1.3, desktop: 1.5),
      children: [
        _buildStatCard(
          context,
          "₹${NumberFormat('#,##,###').format(totalPayments)}",
          "Top Payments",
          Icons.camera_alt_outlined,
          Colors.purpleAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentFeeDetailPage())),
        ),
        _buildStatCard(
          context,
          "84%",
          "Compliance",
          Icons.trending_up_rounded,
          isDark ? Colors.cyanAccent : Theme.of(context).colorScheme.secondary,
              () {},
        ),
        _buildStatCard(
          context,
          "₹${NumberFormat('#,##,###').format(instFees)}",
          "Institute Fees",
          Icons.account_balance_rounded,
          Colors.orangeAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeeStructurePage())),
        ),
        _buildStatCard(
          context,
          "₹${NumberFormat('#,##,###').format(classFees)}",
          "Class Fees",
          Icons.school_outlined,
          Colors.greenAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeeStructurePage())),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color, VoidCallback onTap) {
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);
    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant, width: 0.5),
      ),
      elevation: isDark ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(context.sm),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: context.scale(20)),
                const SizedBox(height: 12),
                Text(value, style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(color: isDark ? Colors.white70 : theme.hintColor, fontSize: context.font(11)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: isDark ? Colors.amberAccent : theme.colorScheme.primary, size: context.scale(18)),
                  SizedBox(width: context.sm),
                  Text("Quick Actions",
                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            _buildActionButton(context, "FEE STRUCTURE", Icons.account_balance_wallet_outlined, const FeeStructurePage()),
            SizedBox(height: context.sm),
            _buildActionButton(context, "MANAGE STUDENT FEES", Icons.group_add_outlined, const StudentFeeDetailPage()),
            SizedBox(height: context.sm),
            _buildActionButton(context, "+ CREATE TICKET", Icons.add_comment_rounded, const CreateTicketPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Widget page) {
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          foregroundColor: isDark ? Colors.white : theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context, accountant_model.UserDetail user) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: isDark ? Colors.blueAccent : theme.colorScheme.primary, size: context.scale(18)),
                  SizedBox(width: context.sm),
                  Text("Profile Overview",
                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountantProfile())),
                    icon: Icon(Icons.edit_note_rounded, color: isDark ? Colors.blueAccent : theme.colorScheme.primary, size: context.scale(24)),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ProfileAvatar(
                radius: context.scale(36),
                imageUrl: user.photo != null ? "${ApiService.baseUrl}/storage/${user.photo}" : null,
              ),
            ),
            SizedBox(height: context.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(user.name, style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                user.position ?? "Senior Accountant",
                style: TextStyle(color: isDark ? Colors.white70 : theme.colorScheme.secondary, fontSize: context.font(13)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: context.md),
            _buildProfileDetail(context, Icons.badge_outlined, "Employee ID", user.userId.toString()),
            Divider(height: context.md, color: isDark ? Colors.white10 : null),
            _buildProfileDetail(context, Icons.phone_iphone_rounded, "Phone No", user.phone ?? "N/A"),
            Divider(height: context.md, color: isDark ? Colors.white10 : null),
            _buildProfileDetail(context, Icons.calendar_today_rounded, "Joining Date", user.joiningDate ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(4)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isDark ? Colors.white54 : theme.hintColor, size: 18),
            SizedBox(width: context.sm),
            Text(label,
              style: TextStyle(color: isDark ? Colors.white54 : theme.hintColor, fontSize: context.font(14)),
            ),
            const SizedBox(width: 16),
            Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMySalarySection(BuildContext context, accountant_model.Salary? lastSalary) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: isDark ? Colors.greenAccent : theme.colorScheme.primary, size: context.scale(18)),
                  SizedBox(width: context.sm),
                  Text("My Salary",
                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalarySlipsPage())),
                    icon: Icon(Icons.launch_rounded, color: isDark ? Colors.white54 : theme.hintColor, size: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            Center(
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("₹${lastSalary != null ? NumberFormat('#,##,###').format(double.parse(lastSalary.amount)) : '0.00'}",
                        style: TextStyle(fontSize: context.font(28), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ),
                  Text("Last paid: ${lastSalary?.month ?? 'N/A'}", 
                    style: TextStyle(color: isDark ? Colors.white70 : theme.hintColor, fontSize: context.font(14)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                Expanded(
                  child: Text("Status",
                    style: TextStyle(color: isDark ? Colors.white70 : theme.hintColor, fontSize: context.font(14)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text("Paid", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sm),
            Row(
              children: [
                Expanded(
                  child: Text("Payment Date",
                    style: TextStyle(color: isDark ? Colors.white70 : theme.hintColor, fontSize: context.font(14)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(lastSalary?.paymentDate ?? "N/A", 
                    style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, accountant_model.AccountantDashboardData data) {
    final sections = [
      _buildMenuSection(context, "Fee Information", Icons.payments_outlined, [
        _MenuItem("Fee Structure", Icons.chevron_right, const FeeStructurePage()),
        _MenuItem("Student Fee Detail", Icons.chevron_right, const StudentFeeDetailPage()),
      ]),
      _buildMenuSection(context, "Library", Icons.library_books_outlined, [
        _MenuItem("Available Books", Icons.chevron_right, const LibraryBooksPage()),
        _MenuItem("Lending Books", Icons.chevron_right, const LendingBooksPage()),
      ]),
      _buildMenuSection(context, "Examinations", Icons.assignment_outlined, [
        _MenuItem("Examination Information", Icons.chevron_right, const ExamListPage()),
      ]),
      _buildMenuSection(context, "Event Management", Icons.calendar_month_outlined, [
        _MenuItem("Events List", Icons.chevron_right, const EventListPage()),
        _MenuItem("Registered Events", Icons.chevron_right, const EventListPage(showRegisteredOnly: true)),
      ]),
      _buildMenuSection(context, "Support Ticket", Icons.confirmation_number_outlined, [
        _MenuItem("My Ticket", Icons.chevron_right, const SupportTicketsPage()),
        _MenuItem("Submit New Ticket", Icons.chevron_right, const CreateTicketPage()),
        _MenuItem("Assigned Ticket", Icons.chevron_right, const SupportTicketsPage(isAssigned: true)),
      ]),
      _buildMenuSection(context, "Employee Detail", Icons.groups_outlined, [
        _MenuItem("Manager", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Manager"), orElse: () => const MapEntry('', '')).key)),
        _MenuItem("Counselors", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Counselor"), orElse: () => const MapEntry('', '')).key)),
        _MenuItem("Teachers", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Teacher"), orElse: () => const MapEntry('', '')).key)),
        _MenuItem("Librarian", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Librarian"), orElse: () => const MapEntry('', '')).key)),
        _MenuItem("Accountants", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Accountant"), orElse: () => const MapEntry('', '')).key)),
        _MenuItem("Staff", Icons.chevron_right, EmployeeListPage(roleId: data.roles.entries.firstWhere((e) => e.value.contains("Staff"), orElse: () => const MapEntry('', '')).key)),
      ]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          final double itemWidth = (constraints.maxWidth - context.md) / 2;
          return Wrap(
            spacing: context.md,
            runSpacing: context.md,
            children: sections.map((s) => SizedBox(
              width: itemWidth,
              child: s,
            )).toList(),
          );
        }
        return Column(
          children: sections.map((s) => Padding(
            padding: EdgeInsets.only(bottom: context.md),
            child: s,
          )).toList(),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, IconData headerIcon, List<_MenuItem> items) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(headerIcon, color: isDark ? Colors.white70 : theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(title,
                    style: TextStyle(fontSize: context.font(15), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                LayoutBuilder(
                  builder: (context, tileConstraints) {
                    // ListTile crashes if width is too small.
                    if (tileConstraints.maxWidth < 150) {
                      return InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item.page)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(item.title,
                                  style: TextStyle(fontSize: context.font(14), color: isDark ? Colors.white : Colors.black87),
                                ),
                                const SizedBox(width: 8),
                                Icon(item.trailing, color: isDark ? Colors.white38 : theme.hintColor, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return ListTile(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item.page)),
                      title: Text(item.title,
                        style: TextStyle(fontSize: context.font(14), color: isDark ? Colors.white : Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Icon(item.trailing, color: isDark ? Colors.white38 : theme.hintColor, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      dense: true,
                    );
                  },
                ),
                if (index != items.length - 1)
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1), indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, IconData icon, List<dynamic> items, String type) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    Widget targetPage = const Scaffold();
    if (type == "salary") targetPage = const SalarySlipsPage();
    if (type == "payment") targetPage = const StudentFeeDetailPage();
    if (type == "fine") targetPage = const StudentFeeDetailPage();

    return Card(
      color: isDark ? const Color(0xFF2C3550) : null,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: isDark ? Colors.white70 : theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(title,
                      style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: isDark ? Colors.white38 : theme.hintColor, size: 18),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Text("No $type records available.", style: TextStyle(color: isDark ? Colors.white54 : theme.hintColor, fontSize: context.font(13))),
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
                    Divider(height: 1, color: isDark ? Colors.white10 : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mainText, 
                                  style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(subText, 
                                  style: TextStyle(color: isDark ? Colors.white54 : theme.hintColor, fontSize: context.font(12)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(amount,
                              style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                            ),
                          ),
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
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Center(
                  child: Text("+${items.length - 3} more records", style: TextStyle(color: isDark ? Colors.white54 : theme.hintColor, fontSize: context.font(12), fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
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