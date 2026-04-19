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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: () async => _loadTickets(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTER SECTION
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(20)),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(16)),
                      child: Column(
                        children: [
                          _buildResponsiveRow(context, [
                            TextField(
                              onChanged: (val) {
                                setState(() => searchQuery = val);
                                _loadTickets();
                              },
                              decoration: InputDecoration(
                                hintText: "Search by Title...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                                ),
                              ),
                            ),
                            _buildDropdown(context, selectedPriority, {
                              "all": "All Priorities",
                              "low": "Low",
                              "medium": "Medium",
                              "high": "High"
                            }, (val) {
                              setState(() => selectedPriority = val!);
                              _loadTickets();
                            }),
                          ]),
                          SizedBox(height: context.scale(12)),
                          _buildDropdown(context, selectedStatus, {
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

                  SizedBox(height: context.scale(24)),

                  /// DATA TABLE SECTION
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(20)),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.scale(16)),
                          child: Text(
                            "Tickets Assigned to You",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FutureBuilder<List<SupportTicket>>(
                          future: _ticketsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: EdgeInsets.all(context.scale(40.0)),
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: EdgeInsets.all(context.scale(40.0)),
                                child: Center(child: Text("Error: ${snapshot.error}")),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.all(context.scale(40.0)),
                                child: const Center(child: Text("No assigned tickets found")),
                              );
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                dataRowMinHeight: context.scale(60),
                                dataRowMaxHeight: context.scale(70),
                                columnSpacing: context.scale(24),
                                columns: [
                                  DataColumn(label: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
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
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) {
      return Column(
        children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.scale(12)), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: entry.key < children.length - 1 ? context.scale(12) : 0),
                  child: entry.value,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDropdown(BuildContext context, String value, Map<String, String> items, Function(String?) onChanged) {
    final colorScheme = context.theme.colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      items: items.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(
                  e.value,
                  style: TextStyle(fontSize: context.font(14)),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  DataRow _buildDataRow(BuildContext context, SupportTicket ticket) {
    return DataRow(cells: [
      DataCell(Text(ticket.id.toString(), style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ticket.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
      DataCell(_buildBadge(context, ticket.priority)),
      DataCell(_buildBadge(context, ticket.status)),
      DataCell(Text(ticket.category ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
      DataCell(IconButton.filledTonal(
        icon: Icon(Icons.visibility_outlined, size: context.scale(20)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LibrarianTicketDetailsPage(ticketId: ticket.id)),
          ).then((_) => _loadTickets());
        },
      )),
    ]);
  }

  Widget _buildBadge(BuildContext context, String text) {
    final colorScheme = context.theme.colorScheme;
    Color color = colorScheme.outline;
    if (text.toLowerCase() == 'high' || text.toLowerCase() == 'closed') color = colorScheme.error;
    if (text.toLowerCase() == 'medium' || text.toLowerCase() == 'pending') color = Colors.orange;
    if (text.toLowerCase() == 'low' || text.toLowerCase() == 'open') color = Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: context.font(10),
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
