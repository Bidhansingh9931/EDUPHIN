import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_page.dart';
import 'common_widgets.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  final Map<String, String?> _filters = {'priority': null, 'status': null, 'search': ''};
  final TextEditingController _searchController = TextEditingController();
  Key _listKey = UniqueKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
        leading: IconButton(
          icon: const Icon(Icons.confirmation_number_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterSection(),
                FutureBuilder<List<SupportTicket>>(
                  key: _listKey,
                  future: ApiService.getAssignedTickets(_getCleanFilters()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(context.scale(40)),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.all(context.scale(40)),
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(context.scale(40)),
                        child: const Center(child: Text("No tickets found.")),
                      );
                    }

                    final tickets = snapshot.data!;
                    return _buildTicketsTable(tickets);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _getCleanFilters() {
    final clean = <String, String>{};
    if (_searchController.text.isNotEmpty) clean['search'] = _searchController.text;
    if (_filters['priority'] != null) clean['priority'] = _filters['priority']!;
    if (_filters['status'] != null) clean['status'] = _filters['status']!;
    return clean;
  }

  Widget _buildFilterSection() {
    return buildFilterCard(
      context,
      children: [
        buildTextField(context, _searchController, "Search by Title...", prefixIcon: Icons.search),
        SizedBox(height: context.scale(12)),
        buildResponsiveRow(
          context,
          [
            buildDropdown(
              context,
              ['low', 'medium', 'high'],
              _filters['priority'],
              (val) => setState(() => _filters['priority'] = val),
              hint: "All Priorities",
            ),
            buildDropdown(
              context,
              ['open', 'in_progress', 'resolved', 'closed'],
              _filters['status'],
              (val) => setState(() => _filters['status'] = val),
              hint: "All Statuses",
            ),
          ],
        ),
        SizedBox(height: context.scale(16)),
        buildResponsiveRow(
          context,
          [
            buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey())),
            buildActionButton(
              context, 
              "RESET", 
              () => setState(() {
                _searchController.clear();
                _filters['priority'] = null;
                _filters['status'] = null;
                _listKey = UniqueKey();
              }),
              isPrimary: false
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTicketsTable(List<SupportTicket> tickets) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(context.scale(16)),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: context.scale(24),
            headingRowHeight: context.scale(56),
            dataRowMinHeight: context.scale(56),
            dataRowMaxHeight: context.scale(56),
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
            columns: [
              DataColumn(label: Text("#ID", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Issue By", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Title", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Action", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold))),
            ],
            rows: tickets.map((ticket) {
              return DataRow(
                cells: [
                  DataCell(Text(ticket.id.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ticket.user?.name ?? "User",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: context.scale(200),
                      child: Text(
                        ticket.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: context.font(14)),
                      ),
                    ),
                  ),
                  DataCell(
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticketId: ticket.id))),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        textStyle: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold),
                      ),
                      child: const Text("VIEW"),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
