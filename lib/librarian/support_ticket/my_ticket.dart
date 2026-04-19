import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart';
import 'create_ticket.dart';

import 'ticket_details.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
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
      _ticketsFuture = ApiService.getLibrarianTickets({
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
        title: const Text("Your Support Tickets"),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.md),
                          child: Column(
                            children: [
                              context.responsive(
                                Column(
                                  children: [
                                    TextField(
                                      onChanged: (val) {
                                        setState(() => searchQuery = val);
                                        _loadTickets();
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search by Title...",
                                        prefixIcon: const Icon(Icons.search),
                                        filled: true,
                                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(context.scale(12)),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(context.scale(12)),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(context.scale(12)),
                                          borderSide: BorderSide(color: colorScheme.primary, width: 1),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                                      ),
                                    ),
                                    SizedBox(height: context.sm),
                                    _buildDropdown(context, selectedPriority, {
                                      "all": "All Priorities",
                                      "low": "Low",
                                      "medium": "Medium",
                                      "high": "High"
                                    }, (val) {
                                      setState(() => selectedPriority = val!);
                                      _loadTickets();
                                    }),
                                  ],
                                ),
                                tablet: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        onChanged: (val) {
                                          setState(() => searchQuery = val);
                                          _loadTickets();
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Search by Title...",
                                          prefixIcon: const Icon(Icons.search),
                                          filled: true,
                                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(context.scale(12)),
                                            borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(context.scale(12)),
                                            borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(context.scale(12)),
                                            borderSide: BorderSide(color: colorScheme.primary, width: 1),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: context.sm),
                                    Expanded(
                                      child: _buildDropdown(context, selectedPriority, {
                                        "all": "All Priorities",
                                        "low": "Low",
                                        "medium": "Medium",
                                        "high": "High"
                                      }, (val) {
                                        setState(() => selectedPriority = val!);
                                        _loadTickets();
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.sm),
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

                      SizedBox(height: context.md),

                      /// DATA TABLE SECTION
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.scale(20)),
                          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(context.md),
                              child: Text(
                                "Recent Tickets",
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
                                    padding: EdgeInsets.all(context.xl),
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                } else if (snapshot.hasError) {
                                  return Padding(
                                    padding: EdgeInsets.all(context.xl),
                                    child: Center(child: Text("Error: ${snapshot.error}")),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.all(context.xl),
                                    child: const Center(child: Text("No tickets found")),
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                    dataRowMinHeight: context.scale(60),
                                    dataRowMaxHeight: context.scale(70),
                                    columnSpacing: context.md,
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          "#ID",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Title",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Priority",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Status",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Category",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "Action",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                        ),
                                      ),
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

              /// BOTTOM BUTTON
              Padding(
                padding: context.pagePadding,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                      );
                      if (result == true) _loadTickets();
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    icon: Icon(Icons.add, size: context.scale(20)),
                    label: Text("CREATE NEW TICKET", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String value, Map<String, String> items, Function(String?) onChanged) {
    final colorScheme = context.theme.colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
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
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.xl),
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
