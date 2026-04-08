import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<LibrarianDashboardData>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${snapshot.error}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text("Retry"),
                    )
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No data found"));
            }

            final data = snapshot.data!;
            final user = data.userDetail;
            final salary = data.lastSalary;

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome, ${user?.fullName ?? 'Librarian'}",
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Librarian / Resource Management",
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.outline, width: 2),
                            image: user?.photo != null
                                ? DecorationImage(
                                    image: NetworkImage("${ApiService.baseImageUrl}/storage/${user!.photo}"),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user?.photo == null
                              ? Center(
                                  child: Text(
                                    user?.firstName?.substring(0, 1).toUpperCase() ?? "L",
                                    style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                )
                              : null,
                        )
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// PROFILE OVERVIEW
                    SectionWrapper(
                      title: "Profile overview",
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LibrarianProfilePage()),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              backgroundImage: user?.photo != null
                                  ? NetworkImage("${ApiService.baseImageUrl}/storage/${user!.photo}")
                                  : null,
                              child: user?.photo == null
                                  ? Text(user?.firstName?.substring(0, 1).toUpperCase() ?? "L",
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold))
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user?.fullName ?? "N/A",
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "(${user?.employeeId ?? 'N/A'})",
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                            ),
                            const SizedBox(height: 20),
                            profileInfo(context, Icons.email_outlined, user?.email ?? "N/A"),
                            profileInfo(context, Icons.phone_outlined, user?.phone ?? "N/A"),
                            profileInfo(context, Icons.location_on_outlined, user?.address ?? "N/A"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Responsive Grid for Stats/Actions
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: context.isTablet ? 2 : 1,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: context.isTablet ? 1.5 : 1.8,
                          children: [
                            /// MY SALARY
                            SectionWrapper(
                              title: "My Salary",
                              icon: Icons.account_balance_wallet_outlined,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    salary != null ? "₹${salary.amount}" : "₹0.00",
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Last paid: ${salary?.paymentDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(salary!.paymentDate!)) : 'N/A'}",
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Status:", style: theme.textTheme.bodySmall),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (salary?.status?.toLowerCase() == 'paid' ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(salary?.status ?? "N/A",
                                            style: TextStyle(
                                                color: salary?.status?.toLowerCase() == 'paid' ? Colors.greenAccent : Colors.orangeAccent,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// BOOKS
                            SectionWrapper(
                              title: "Books (${data.totalBooksQuantity} Total)",
                              icon: Icons.menu_book_outlined,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  navButton(context, "All Books", Icons.arrow_forward_ios, () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllBooksPage()));
                                  }),
                                  const SizedBox(height: 8),
                                  navButton(context, "Add New Books", Icons.arrow_forward_ios, () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewBookPage()));
                                  }),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),

                    const SizedBox(height: 20),

                    /// ISSUED BOOKS
                    SectionWrapper(
                      title: "Issued Books",
                      icon: Icons.assignment_turned_in_outlined,
                      child: Column(
                        children: [
                          navButton(context, "Issue List (${data.issuedBooks.length})", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const IssuedBooksListPage()),
                            );
                          }),
                          const SizedBox(height: 10),
                          navButton(context, "Issue Book", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const IssueBookPage()),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// OVERDUE BOOKS
                    SectionWrapper(
                      title: "Overdue Books (${data.overdueBooks.length})",
                      icon: Icons.info_outline,
                      child: navButton(context, "Overdue List", Icons.arrow_forward_ios, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OverdueBooksPage()),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    /// NAVIGATION GRID
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: context.isTablet ? 3 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 4,
                      children: [
                        fullWidthNavItem(context, "My Lending Books", Icons.people_outline, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyLendingBooksPage()));
                        }),
                        fullWidthNavItem(context, "Examination", Icons.description_outlined, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExaminationListPage()));
                        }),
                        fullWidthNavItem(context, "Salary Details", Icons.payments_outlined, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SalaryBankDetailsPage()));
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// EVENT MANAGEMENT
                    SectionWrapper(
                      title: "Event Management",
                      icon: Icons.event_note_outlined,
                      child: Column(
                        children: [
                          navButton(context, "Event List", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExploreEventsPage()),
                            );
                          }),
                          const SizedBox(height: 10),
                          navButton(context, "Registered Events", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyRegisteredEventsPage()),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SUPPORT TICKETS
                    SectionWrapper(
                      title: "Support Tickets",
                      icon: Icons.help_outline,
                      child: Column(
                        children: [
                          navButton(context, "My Tickets (${data.tickets.length})", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyTicketsPage()),
                            );
                          }),
                          const SizedBox(height: 10),
                          navButton(context, "Create Ticket", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                            );
                          }),
                          const SizedBox(height: 10),
                          navButton(context, "Assigned Tickets (${data.assignedTickets.length})", Icons.arrow_forward_ios, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AssignedTicketsPage()),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// RECENTLY ADDED BOOKS
                    SectionHeader(context, icon: Icons.library_books_outlined, title: "Recently Added Books"),
                    const SizedBox(height: 12),
                    if (data.books.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No books added recently", style: TextStyle(color: Colors.grey)),
                      ))
                    else
                      Column(
                        children: data.books.take(4).map((book) => bookItem(
                          context,
                          book.title,
                          "By ${book.author ?? 'Unknown'}",
                          book.createdAt != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(book.createdAt!)) : "N/A"
                        )).toList(),
                      ),

                    const SizedBox(height: 32),

                    /// RECENTLY ISSUED BOOKS
                    SectionHeader(context, icon: Icons.history_outlined, title: "Recently Issued Books"),
                    const SizedBox(height: 12),
                    if (data.issuedBooks.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No books issued recently", style: TextStyle(color: Colors.grey)),
                      ))
                    else
                      Column(
                        children: data.issuedBooks.take(4).map((ib) => issuedItem(
                          context,
                          ib.bookTitle ?? "Unknown Book",
                          ib.lenderName ?? "Unknown Borrower",
                          ib.issuedAt != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(ib.issuedAt!)) : "N/A"
                        )).toList(),
                      ),

                    const SizedBox(height: 32),

                    /// OVERDUE BOOKS LIST
                    SectionHeader(context, icon: Icons.warning_amber_outlined, title: "Overdue Books"),
                    const SizedBox(height: 12),
                    if (data.overdueBooks.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No overdue books", style: TextStyle(color: Colors.grey)),
                      ))
                    else
                      Column(
                        children: [
                          ...data.overdueBooks.take(3).map((ib) => overdueItem(
                            context,
                            ib.bookTitle ?? "Unknown Book",
                            ib.lenderName ?? "Unknown Borrower",
                            ib.dueDate != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(ib.dueDate!)) : "N/A"
                          )),
                          Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const OverdueBooksPage()));
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: Center(child: Text("View All", style: TextStyle(fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ],
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

  /// HELPER WIDGETS

  Widget profileInfo(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.hintColor, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget navButton(BuildContext context, String text, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: theme.textTheme.bodyMedium),
            Icon(icon, color: theme.hintColor, size: 14),
          ],
        ),
      ),
    );
  }

  Widget fullWidthNavItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }

  Widget bookItem(BuildContext context, String title, String author, String date) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(author, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        trailing: Text(date, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
      ),
    );
  }

  Widget issuedItem(BuildContext context, String title, String borrower, String date) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Issued to: $borrower", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        trailing: Text(date, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
      ),
    );
  }

  Widget overdueItem(BuildContext context, String title, String borrower, String date) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Borrower: $borrower", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        trailing: Text("Overdue:\n$date", textAlign: TextAlign.right, style: TextStyle(color: theme.colorScheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class SectionWrapper extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const SectionWrapper({super.key, required this.title, this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: theme.colorScheme.primary, size: 18),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader(BuildContext context, {super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
