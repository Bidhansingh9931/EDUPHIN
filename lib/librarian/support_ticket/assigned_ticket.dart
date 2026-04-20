import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart';
import '../../services/responsive_helper.dart';
import '../librarian_skeleton_widgets.dart';
import '../../services/common_widgets.dart';

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
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  Stream<List<SupportTicket>>? _ticketsStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    setState(() {
      _ticketsStream = ApiService.getLibrarianAssignedTicketsStream({
        'priority': selectedPriority,
        'status': selectedStatus,
        'search': searchQuery,
      }).asBroadcastStream();
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
            key: _refreshKey,
            onRefresh: () async => _refreshStream(),
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
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.md),
                      child: Column(
                        children: [
                          _buildResponsiveRow(context, [
                            TextField(
                              onChanged: (val) {
                                searchQuery = val;
                                _refreshStream();
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
                            _buildDropdown(context, selectedPriority, {
                              "all": "All Priorities",
                              "low": "Low",
                              "medium": "Medium",
                              "high": "High"
                            }, (val) {
                              selectedPriority = val!;
                              _refreshStream();
                            }),
                          ]),
                          SizedBox(height: context.sm),
                          _buildDropdown(context, selectedStatus, {
                            "all": "All Statuses",
                            "open": "Open",
                            "closed": "Closed",
                            "pending": "Pending"
                          }, (val) {
                            selectedStatus = val!;
                            _refreshStream();
                          }),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.md),

                  /// DATA TABLE SECTION
                  StreamBuilder<List<SupportTicket>>(
                    stream: _ticketsStream,
                    builder: (context, snapshot) {
                      return LoadingWrapper<List<SupportTicket>>(
                        isLoading: snapshot.connectionState == ConnectionState.waiting,
                        hasData: snapshot.hasData && (snapshot.data?.isNotEmpty ?? false),
                        error: snapshot.error,
                        skeleton: const TicketSkeleton(),
                        onRetry: _refreshStream,
                        builder: (tickets) {
                          if (tickets.isEmpty) {
                            return Card(
                              elevation: 0,
                              color: colorScheme.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.scale(20)),
                                side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(context.xl),
                                child: const Center(child: Text("No assigned tickets found")),
                              ),
                            );
                          }
                          return Card(
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
                                    "Tickets Assigned to You",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                    dataRowMinHeight: context.scale(60),
                                    dataRowMaxHeight: context.scale(70),
                                    columnSpacing: context.md,
                                    columns: [
                                      DataColumn(label: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      DataColumn(label: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      DataColumn(label: Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                    ],
                                    rows: tickets.map((ticket) => _buildDataRow(context, ticket)).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
        children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.sm), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: entry.key < children.length - 1 ? context.sm : 0),
                  child: entry.value,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDropdown(BuildContext context, String initialValue, Map<String, String> items, Function(String?) onChanged) {
    final colorScheme = context.theme.colorScheme;
    return DropdownButtonFormField<String>(
      value: initialValue,
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
          ).then((_) => _refreshStream());
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
