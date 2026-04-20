import 'package:eduphin/librarian/books/all_books.dart';
import 'package:eduphin/librarian/support_ticket/assigned_ticket.dart';
import 'package:eduphin/librarian/support_ticket/create_ticket.dart';
import 'package:eduphin/librarian/examination.dart';
import 'package:eduphin/librarian/event_management/event_list.dart';
import 'package:eduphin/librarian/issued_books/issue_books.dart';
import 'package:eduphin/librarian/issued_books/issue_list.dart';
import 'package:eduphin/librarian/librarian_profile.dart';
import 'package:eduphin/librarian/virtual_id_card.dart';
import 'package:eduphin/librarian/lending_books.dart';
import 'package:eduphin/librarian/event_management/registered_events.dart';
import 'package:eduphin/librarian/support_ticket/my_ticket.dart';
import 'package:eduphin/librarian/overdue_books.dart';
import 'package:eduphin/librarian/salary.dart';
import 'package:eduphin/librarian/librarian_models.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({super.key});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  late Stream<LibrarianDashboardData> _dashboardStream;

  @override
  void initState() {
    super.initState();
    _dashboardStream = ApiService.getLibrarianDashboardStream().asBroadcastStream();
  }

  void _refreshData() {
    setState(() {
      _dashboardStream = ApiService.getLibrarianDashboardStream().asBroadcastStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Librarian Dashboard",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(20),
          ),
        ),
        actions: [
          StreamBuilder<LibrarianDashboardData>(
            stream: _dashboardStream,
            builder: (context, snapshot) {
              final user = snapshot.data?.userDetail;
              if (user?.photo == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(right: context.md),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianProfilePage())).then((_) => _refreshData()),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                  child: ProfileAvatar(
                    imageUrl: ApiService.getStorageUrl(user!.photo),
                    radius: context.scale(18),
                    borderWidth: 1.5,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: StreamBuilder<LibrarianDashboardData>(
          stream: _dashboardStream,
          builder: (context, snapshot) {
            return LoadingWrapper<LibrarianDashboardData>(
              snapshot: snapshot,
              skeleton: _buildSkeleton(context),
              onRetry: _refreshData,
              builder: (data) => _buildDashboardContent(data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(height: context.scale(180), borderRadius: 24),
            SizedBox(height: context.xl),
            const Skeleton(height: 20, width: 120),
            SizedBox(height: context.md),
            Row(
              children: [
                Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
                SizedBox(width: context.sm),
                Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
                SizedBox(width: context.sm),
                Expanded(child: Skeleton(height: context.scale(80), borderRadius: 20)),
              ],
            ),
            SizedBox(height: context.xl),
            const Skeleton(height: 20, width: 150),
            SizedBox(height: context.md),
            Skeleton(height: context.scale(150), borderRadius: 24),
            SizedBox(height: context.xl),
            Skeleton(height: context.scale(300), borderRadius: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(LibrarianDashboardData data) {
    final user = data.userDetail;
    final isDesktop = context.responsive<bool>(false, tablet: true, desktop: true);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: context.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user != null) _buildProfileOverview(user),
                            SizedBox(height: context.xl),
                            _buildSectionHeader("Quick Actions", Icons.bolt_outlined),
                            SizedBox(height: context.md),
                            _buildQuickActions(context),
                          ],
                        ),
                      ),
                      SizedBox(width: context.lg),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Earnings Overview", Icons.payments_outlined),
                            SizedBox(height: context.md),
                            _buildSalaryCard(data.lastSalary),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  if (user != null) _buildProfileOverview(user),
                  SizedBox(height: context.xl),
                  _buildSectionHeader("Quick Actions", Icons.bolt_outlined),
                  SizedBox(height: context.md),
                  _buildQuickActions(context),
                  SizedBox(height: context.xl),
                  _buildSectionHeader("Earnings Overview", Icons.payments_outlined),
                  SizedBox(height: context.md),
                  _buildSalaryCard(data.lastSalary),
                ],
                SizedBox(height: context.xl),
                _buildResponsiveGrid(context, data),
                SizedBox(height: context.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, LibrarianDashboardData data) {
    final sections = [
      _buildSectionCard("Library Management", Icons.local_library_outlined, [
        _buildMenuItem("All Books (${data.totalBooksQuantity})", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllBooksPage()))),
        _buildMenuItem("Issue New Book", Icons.add_box_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueBookPage()))),
        _buildMenuItem("Issued List (${data.issuedBooks.length})", Icons.list_alt_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssuedBooksListPage()))),
        _buildMenuItem("Overdue Books (${data.overdueBooks.length})", Icons.warning_amber_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OverdueBooksPage())), isWarning: data.overdueBooks.isNotEmpty),
        _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLendingBooksPage()))),
      ]),
      _buildSectionCard("Support Helpdesk", Icons.support_agent_outlined, [
        _buildMenuItem("My Tickets (${data.tickets.length})", Icons.confirmation_number_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsPage()))),
        _buildMenuItem("Assigned Tickets (${data.assignedTickets.length})", Icons.assignment_ind_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedTicketsPage()))),
        _buildMenuItem("Create New Ticket", Icons.add_comment_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketPage()))),
      ]),
      _buildSectionCard("Other Services", Icons.more_horiz_outlined, [
        _buildMenuItem("Examination List", Icons.assignment_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExaminationListPage()))),
        _buildMenuItem("Explore Events", Icons.event_note_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()))),
        _buildMenuItem("My Registered Events", Icons.how_to_reg_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventsPage()))),
      ]),
    ];

    final columns = context.responsive<int>(1, tablet: 2, desktop: 3);

    if (columns == 1) {
      return Column(
        children: sections.map((s) => Padding(padding: EdgeInsets.only(bottom: context.xl), child: s)).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columns, (colIdx) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: colIdx < columns - 1 ? context.lg : 0),
            child: Column(
              children: List.generate(sections.length, (secIdx) {
                if (secIdx % columns == colIdx) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: context.xl),
                    child: sections[secIdx],
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(title, icon),
        SizedBox(height: context.md),
        _buildMenuCard(items),
      ],
    );
  }

  Widget _buildProfileOverview(UserDetail user) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianProfilePage())).then((_) => _refreshData()),
        borderRadius: BorderRadius.circular(context.scale(24)),
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    imageUrl: ApiService.getStorageUrl(user.photo),
                    radius: context.scale(35),
                  ),
                  SizedBox(width: context.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(20))),
                        Text("Librarian • Library Department", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.md),
              Container(
                padding: EdgeInsets.all(context.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileInfoItem(Icons.badge_outlined, user.employeeId ?? "N/A", "ID"),
                    _buildProfileInfoItem(Icons.phone_outlined, user.phone ?? "N/A", "Phone"),
                  ],
                ),
              ),
              SizedBox(height: context.md),
              FilledButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianVirtualIdCardPage())),
                icon: const Icon(Icons.vignette_outlined),
                label: const Text("VIRTUAL ID CARD"),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, context.scale(52)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem(IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: context.scale(18), color: theme.colorScheme.primary),
        SizedBox(height: context.xs),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12))),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: context.font(10))),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: context.xs, bottom: context.xs),
      child: Row(
        children: [
          Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
          SizedBox(width: context.sm),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: context.font(17),
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: QuickActionItem(
            label: "All Books",
            icon: Icons.library_books_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllBooksPage())),
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: context.sm),
        Expanded(
          child: QuickActionItem(
            label: "Issue Book",
            icon: Icons.assignment_turned_in_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueBookPage())),
            color: theme.colorScheme.secondary,
          ),
        ),
        SizedBox(width: context.sm),
        Expanded(
          child: QuickActionItem(
            label: "Support",
            icon: Icons.add_circle_outline,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketPage())),
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryCard(Salary? salary) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryBankDetailsPage())),
        borderRadius: BorderRadius.circular(context.scale(24)),
        child: Padding(
          padding: EdgeInsets.all(context.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (salary == null) ...[
                Icon(Icons.payments_outlined, size: context.scale(40), color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                SizedBox(height: context.sm),
                Text("No Records", style: theme.textTheme.titleMedium),
                Text("No recent salary data", style: theme.textTheme.bodySmall),
              ] else ...[
                Text("₹${salary.amount}",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: context.font(26),
                    )),
                Text("Last Processed Payment", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                SizedBox(height: context.lg),
                Container(
                  padding: EdgeInsets.all(context.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSalaryInfoRow("Status", "Paid", Colors.green),
                      _buildSalaryInfoRow("Date", salary.paymentDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary.paymentDate!)) : "N/A", theme.colorScheme.onSurface),
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryInfoRow(String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: context.font(10))),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor, fontSize: context.font(12))),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.scale(24)),
        child: Column(
          children: children.asMap().entries.map((entry) {
            int idx = entry.key;
            Widget child = entry.value;
            return Column(
              children: [
                child,
                if (idx != children.length - 1) 
                  Divider(height: 1, thickness: 0.5, indent: context.md, endIndent: context.md, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isWarning = false}) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
      leading: Container(
        padding: EdgeInsets.all(context.sm),
        decoration: BoxDecoration(
          color: (isWarning ? theme.colorScheme.error : theme.colorScheme.primary).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: context.scale(18), color: isWarning ? theme.colorScheme.error : theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isWarning ? FontWeight.w800 : FontWeight.w600, 
        fontSize: context.font(14),
        color: theme.colorScheme.onSurface,
      )),
      trailing: Icon(Icons.chevron_right_rounded, size: context.scale(20), color: theme.colorScheme.outlineVariant),
    );
  }
}
