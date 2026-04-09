import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart';
import '../../services/responsive_helper.dart';

import 'ticket_details.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  String selectedPriority = "all";
  String selectedStatus = "all";
  String searchQuery = "";
  late Future<List<SupportTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _ticketsFuture = ApiService.getLibrarianAssignedTickets({
        'priority': selectedPriority,
        'status': selectedStatus,
        'search': searchQuery,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Column(
            children: [
              /// FILTER SECTION
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResponsiveRow(context, [
                        TextField(
                          onChanged: (val) {
                            setState(() => searchQuery = val);
                            _loadTickets();
                          },
                          decoration: const InputDecoration(
                            hintText: "Search by Title...",
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        _buildDropdown(selectedPriority, {
                          "all": "All Priorities",
                          "low": "Low",
                          "medium": "Medium",
                          "high": "High"
                        }, (val) {
                          setState(() => selectedPriority = val!);
                          _loadTickets();
                        }),
                      ]),
                      const SizedBox(height: 12),
                      _buildDropdown(selectedStatus, {
                        "all": "All Statuses",
                        "open": "Open",
                        "closed": "Closed",
                        "pending": "Pending"
                      }, (val) {
                        setState(() => selectedStatus = val!);
                        _loadTickets();
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// DATA TABLE SECTION
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Tickets Assigned to You", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 1),
                    FutureBuilder<List<SupportTicket>>(
                      future: _ticketsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(child: Text("Error: ${snapshot.error}")),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("No assigned tickets found")),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                            columnSpacing: 25,
                            columns: const [
                              DataColumn(label: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Category", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: snapshot.data!.map((ticket) => _buildDataRow(context, ticket)).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildDropdown(String value, Map<String, String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  DataRow _buildDataRow(BuildContext context, SupportTicket ticket) {
    return DataRow(cells: [
      DataCell(Text(ticket.id.toString())),
      DataCell(Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(_buildBadge(ticket.priority)),
      DataCell(_buildBadge(ticket.status)),
      DataCell(Text(ticket.category ?? "N/A")),
      DataCell(IconButton(
        icon: const Icon(Icons.visibility_outlined, size: 20),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LibrarianTicketDetailsPage(ticketId: ticket.id)),
          ).then((_) => _loadTickets());
        },
      )),
    ]);
  }

  Widget _buildBadge(String text) {
    Color color = Colors.grey;
    if (text.toLowerCase() == 'high' || text.toLowerCase() == 'closed') color = Colors.red;
    if (text.toLowerCase() == 'medium' || text.toLowerCase() == 'pending') color = Colors.orange;
    if (text.toLowerCase() == 'low' || text.toLowerCase() == 'open') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
