import 'package:eduphin/teacher/dashboard/app_drawer.dart';
import 'package:eduphin/teacher/dashboard/profile.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/teacher/dashboard/salary_bank_details.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:eduphin/teacher/dashboard/virtual_id_page.dart';
import 'package:eduphin/teacher/dashboard/your_support_ticket.dart';
import 'package:eduphin/teacher/dashboard/create_new_support_ticket.dart';
import 'package:eduphin/staff/staff_dashboard/student_fee_detail.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'exam_information_page.dart';
import 'explore_events.dart';
import 'library_book_page.dart';
import 'lending_books_page.dart';
import 'my_registered_event.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  TeacherDashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await TeacherCacheService.load('dashboard');
    if (cachedData != null && mounted) {
      setState(() {
        _dashboardData = TeacherDashboardData.fromJson(cachedData);
        _isLoading = false;
      });
    }
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    if (!mounted) return;
    if (_dashboardData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final data = await ApiService.getTeacherDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
          _errorMessage = null;
        });
        await TeacherCacheService.save('dashboard', data.toJson());
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ErrorHandler.getMessage(e);
        setState(() {
          _isLoading = false;
          if (_dashboardData == null) {
            _errorMessage = errorMsg;
          }
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Teacher Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(20),
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              "Overview & Management",
              style: TextStyle(
                fontSize: context.font(11),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ).then((_) => _fetchDashboard()),
            icon: ProfileAvatar(
              imageUrl: ApiService.getStorageUrl(_dashboardData?.userDetail.photo),
              radius: context.scale(16),
            ),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                if (context.mounted) {
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                }
                
                await ApiService.logout();
                
                if (context.mounted) {
                  Navigator.of(context).pop(); // Dismiss loading
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            icon: Icon(Icons.logout, color: colorScheme.error, size: context.scale(22)),
          ),
          SizedBox(width: context.scale(8)),
        ],
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _dashboardData != null,
        skeleton: _buildSkeleton(context),
        child: _dashboardData != null 
          ? _buildDashboardContent(context, _dashboardData!)
          : (_errorMessage != null 
              ? _buildErrorWidget(_errorMessage!) 
              : const Center(child: Text("No data available"))),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherSkeleton(height: context.scale(250), borderRadius: BorderRadius.circular(20)),
          SizedBox(height: context.scale(24)),
          const TeacherSkeleton(height: 20, width: 150),
          SizedBox(height: context.scale(12)),
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: TeacherSkeleton(height: context.scale(100), borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ),
          SizedBox(height: context.scale(24)),
          const TeacherSkeleton(height: 20, width: 150),
          SizedBox(height: context.scale(12)),
          TeacherSkeleton(height: context.scale(150), borderRadius: BorderRadius.circular(20)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(24.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: context.scale(48), color: colorScheme.error),
            SizedBox(height: context.scale(16)),
            Text(
              "Failed to load dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              error,
              style: TextStyle(fontSize: context.font(12), color: colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scale(24)),
            FilledButton(
              onPressed: _fetchDashboard,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text("Retry", style: TextStyle(fontSize: context.font(14))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TeacherDashboardData data) {
    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        padding: context.pagePadding,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1100.0, desktop: 1400.0)),
            child: context.responsive(
              _buildMobileLayout(data),
              tablet: _buildDesktopLayout(data),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(TeacherDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileOverview(data.userDetail),
        SizedBox(height: context.scale(24)),
        _buildSectionHeader("Quick Actions", Icons.bolt),
        SizedBox(height: context.scale(12)),
        _buildQuickActions(),
        SizedBox(height: context.scale(24)),
        _buildSectionHeader("My Salary", Icons.payments_outlined),
        SizedBox(height: context.scale(12)),
        _buildSalaryCard(data),
        SizedBox(height: context.scale(24)),
        _buildSectionHeader("Academic & Library", Icons.school_outlined),
        SizedBox(height: context.scale(12)),
        _buildMenuCard([
          _buildMenuItem("Examination Info", Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()))),
          _buildMenuItem("Available Books", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()))),
          _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()))),
        ]),
        SizedBox(height: context.scale(24)),
        _buildSectionHeader("Events & Support", Icons.event_note_outlined),
        SizedBox(height: context.scale(12)),
        _buildMenuCard([
          _buildMenuItem("Explore Events", Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()))),
          _buildMenuItem("My Registered Events", Icons.how_to_reg_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventPage()))),
          _buildMenuItem("My Support Tickets", Icons.confirmation_number_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()))),
        ]),
        SizedBox(height: context.scale(40)),
      ],
    );
  }

  Widget _buildDesktopLayout(TeacherDashboardData data) {
    final bool isNarrowDesktop = MediaQuery.of(context).size.width < 1100;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildProfileOverview(data.userDetail),
            ),
            SizedBox(width: context.scale(24)),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildSectionHeader("Quick Actions", Icons.bolt),
                  SizedBox(height: context.scale(12)),
                  _buildQuickActions(),
                  SizedBox(height: context.scale(24)),
                  if (isNarrowDesktop) ...[
                    _buildSectionHeader("My Salary", Icons.payments_outlined),
                    SizedBox(height: context.scale(12)),
                    _buildSalaryCard(data),
                    SizedBox(height: context.scale(24)),
                    _buildSectionHeader("Academic & Library", Icons.school_outlined),
                    SizedBox(height: context.scale(12)),
                    _buildMenuCard([
                      _buildMenuItem("Examination Info", Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()))),
                      _buildMenuItem("Available Books", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()))),
                      _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()))),
                    ]),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildSectionHeader("My Salary", Icons.payments_outlined),
                              SizedBox(height: context.scale(12)),
                              _buildSalaryCard(data),
                            ],
                          ),
                        ),
                        SizedBox(width: context.scale(24)),
                        Expanded(
                          child: Column(
                            children: [
                              _buildSectionHeader("Academic & Library", Icons.school_outlined),
                              SizedBox(height: context.scale(12)),
                              _buildMenuCard([
                                _buildMenuItem("Examination Info", Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamInformationPage()))),
                                _buildMenuItem("Available Books", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryBookPage()))),
                                _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingBooksPage()))),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.scale(24)),
        _buildSectionHeader("Events & Support", Icons.event_note_outlined),
        SizedBox(height: context.scale(12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMenuCard([
                _buildMenuItem("Explore Events", Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()))),
                _buildMenuItem("My Registered Events", Icons.how_to_reg_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventPage()))),
              ]),
            ),
            SizedBox(width: context.scale(24)),
            Expanded(
              child: _buildMenuCard([
                _buildMenuItem("My Support Tickets", Icons.confirmation_number_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourSupportTicketPage()))),
                _buildMenuItem("Create New Ticket", Icons.add_circle_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage()))),
              ]),
            ),
          ],
        ),
        SizedBox(height: context.scale(40)),
      ],
    );
  }

  Widget _buildProfileOverview(UserDetail user) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20.0)),
        child: Column(
          children: [
            ProfileAvatar(
              imageUrl: ApiService.getStorageUrl(user.photo),
              radius: context.scale(44),
            ),
            SizedBox(height: context.scale(16)),
            Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(20),
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              user.roleName ?? "Teacher",
              style: TextStyle(
                fontSize: context.font(14),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: context.scale(24)),
            Wrap(
              spacing: context.scale(16),
              runSpacing: context.scale(12),
              alignment: WrapAlignment.center,
              children: [
                _buildProfileInfoItem(Icons.badge_outlined, user.employeeId ?? "N/A"),
                _buildProfileInfoItem(Icons.phone_outlined, user.phone ?? "N/A"),
                _buildProfileInfoItem(Icons.location_on_outlined, "Campus Main"),
              ],
            ),
            SizedBox(height: context.scale(24)),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualIdPage())),
                icon: Icon(Icons.vignette_outlined, size: context.scale(18)),
                label: Text("GENERATE VIRTUAL ID CARD", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String value) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(context.scale(8)),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: context.scale(20), color: colorScheme.primary),
        ),
        SizedBox(height: context.scale(6)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.font(11),
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.font(16),
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: context.scale(12),
      runSpacing: context.scale(12),
      children: [
        _buildResponsiveQuickAction(
          label: "FEE STRUCTURE",
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankDetailsPage())),
        ),
        _buildResponsiveQuickAction(
          label: "STUDENT FEES",
          icon: Icons.payments_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffStudentFeeDetailPage())),
        ),
        _buildResponsiveQuickAction(
          label: "CREATE TICKET",
          icon: Icons.add_circle_outline,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage())),
        ),
      ],
    );
  }

  Widget _buildResponsiveQuickAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Calculate width to fit 3 items per row minus spacing
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = (constraints.maxWidth - (context.scale(12) * 2)) / 3;
        return QuickActionItem(
          label: label,
          icon: icon,
          width: width,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildSalaryCard(TeacherDashboardData data) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final salary = data.lastSalary;

    if (salary == null) {
      return Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scale(24.0)),
          child: Column(
            children: [
              Icon(Icons.money_off, size: context.scale(40), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              SizedBox(height: context.scale(8)),
              Text(
                "No Salary Data",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font(16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isPaid = salary.status.toLowerCase() == 'paid';

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankDetailsPage())),
        borderRadius: BorderRadius.circular(context.scale(20)),
        child: Padding(
          padding: EdgeInsets.all(context.scale(20.0)),
          child: Column(
            children: [
              Text(
                "₹${salary.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: context.font(24),
                ),
              ),
              Text(
                "Last processed payment",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: context.font(12),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                child: Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: _buildSalaryInfoRow(
                          "Status",
                          salary.status,
                          isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                      SizedBox(width: context.scale(8)),
                      Flexible(
                        child: _buildSalaryInfoRow(
                          "Payment Date",
                          salary.paymentDate ?? "Pending",
                          colorScheme.onSurface,
                        ),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryInfoRow(String label, String value, Color valueColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: context.font(11),
          ),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: context.font(12),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx != children.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: context.scale(16),
                  endIndent: context.scale(16),
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(context.scale(8)),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(context.scale(8)),
        ),
        child: Icon(icon, size: context.scale(20), color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: context.font(14),
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: context.scale(18), color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
