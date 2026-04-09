import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'virtual_id_card.dart';
import 'librarian_models.dart';
import 'books/all_books.dart';
import 'books/add_new_books.dart';
import 'issued_books/issue_list.dart';
import 'issued_books/issue_books.dart';
import 'support_ticket/my_ticket.dart';
import 'support_ticket/create_ticket.dart';
import 'support_ticket/assigned_ticket.dart';
import 'event_management/event_list.dart';
import 'event_management/registered_events.dart';
import 'examination.dart';
import 'librarian_profile.dart';
import 'overdue_books.dart';
import 'lending_books.dart';
import 'salary.dart';

class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({super.key});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  late Future<LibrarianDashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = ApiService.getLibrarianDashboard();
  }

  Future<void> _refreshData() async {
    setState(() {
      _dashboardData = ApiService.getLibrarianDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Librarian Dashboard", style: theme.appBarTheme.titleTextStyle),
            Text("Overview & Management", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianProfilePage())),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_outline, size: 20, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<LibrarianDashboardData>(
        future: _dashboardData,
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
            onPressed: _refreshData,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, LibrarianDashboardData data) {
    final user = data.userDetail;
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Overview Section
          if (user != null) _buildProfileOverview(user),
          const SizedBox(height: 20),

          // Quick Actions
          _buildSectionHeader("Quick Actions", Icons.bolt),
          const SizedBox(height: 12),
          _buildQuickActions(context),
          const SizedBox(height: 24),

          // Salary Section
          _buildSectionHeader("My Salary", Icons.payments_outlined),
          const SizedBox(height: 12),
          _buildSalaryCard(data.lastSalary),
          const SizedBox(height: 24),

          // Library Management Section
          _buildSectionHeader("Library Management", Icons.local_library_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("All Books (${data.totalBooksQuantity})", Icons.book_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllBooksPage()))),
            _buildMenuItem("Issue New Book", Icons.add_box_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueBookPage()))),
            _buildMenuItem("Issued List (${data.issuedBooks.length})", Icons.list_alt_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IssuedBooksListPage()))),
            _buildMenuItem("Overdue Books (${data.overdueBooks.length})", Icons.warning_amber_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OverdueBooksPage())), isWarning: data.overdueBooks.isNotEmpty),
            _buildMenuItem("Lending Books", Icons.assignment_return_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLendingBooksPage()))),
          ]),
          const SizedBox(height: 24),

          // Examinations Section
          _buildSectionHeader("Examinations", Icons.assignment_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("Examination List", Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExaminationListPage()))),
          ]),
          const SizedBox(height: 24),

          // Event Management Section
          _buildSectionHeader("Event Management", Icons.event_note_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("Explore Events", Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreEventsPage()))),
            _buildMenuItem("My Registered Events", Icons.how_to_reg_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegisteredEventsPage()))),
          ]),
          const SizedBox(height: 24),

          // Support Ticket Section
          _buildSectionHeader("Support Helpdesk", Icons.support_agent_outlined),
          const SizedBox(height: 12),
          _buildMenuCard([
            _buildMenuItem("My Tickets (${data.tickets.length})", Icons.confirmation_number_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsPage()))),
            _buildMenuItem("Assigned Tickets (${data.assignedTickets.length})", Icons.assignment_ind_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignedTicketsPage()))),
            _buildMenuItem("Create New Ticket", Icons.add_comment_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketPage()))),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileOverview(UserDetail user) {
    final theme = Theme.of(context);
    final photoUrl = user.photo != null ? "${ApiService.baseImageUrl}/storage/${user.photo}" : null;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianProfilePage())).then((_) => _refreshData()),
        borderRadius: BorderRadius.circular(12),
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
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(user.fullName ?? "Librarian", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text("Librarian", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileInfoItem(Icons.badge_outlined, user.employeeId ?? "N/A"),
                  _buildProfileInfoItem(Icons.phone_outlined, user.phone ?? "N/A"),
                  _buildProfileInfoItem(Icons.location_on_outlined, "Library Dept"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibrarianVirtualIdCardPage())),
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

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _quickActionButton("ADD BOOK", Icons.library_add_outlined, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewBookPage()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickActionButton("ISSUE BOOK", Icons.assignment_turned_in_outlined, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueBookPage()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickActionButton("CREATE TICKET", Icons.add_circle_outline, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketPage()));
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
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(Salary? salary) {
    final theme = Theme.of(context);

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
              Text("₹${salary.amount}", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text("Last processed payment", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSalaryInfoRow("Status", "Paid", Colors.green),
                  _buildSalaryInfoRow("Payment Date", salary.paymentDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary.paymentDate!)) : "N/A", theme.colorScheme.onSurface),
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

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isWarning = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: isWarning ? Colors.red : theme.colorScheme.primary.withValues(alpha: 0.7)),
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: isWarning ? Colors.red : null, fontWeight: isWarning ? FontWeight.bold : null)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
