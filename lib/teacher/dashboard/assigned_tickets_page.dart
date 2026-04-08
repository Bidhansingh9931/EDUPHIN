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
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder<List<SupportTicket>>(
              key: _listKey,
              future: ApiService.getAssignedTickets(_getCleanFilters()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No tickets found."));
                }

                final tickets = snapshot.data!;
                return _buildTicketsTable(tickets);
              },
            ),
          ),
        ],
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
        const SizedBox(height: 12),
        buildDropdown(
          context,
          ['low', 'medium', 'high'],
          _filters['priority'],
          (val) => setState(() => _filters['priority'] = val),
          hint: "All Priorities",
        ),
        const SizedBox(height: 12),
        buildDropdown(
          context,
          ['open', 'in_progress', 'resolved', 'closed'],
          _filters['status'],
          (val) => setState(() => _filters['status'] = val),
          hint: "All Statuses",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey()))),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionButton(
                context, 
                "RESET", 
                () => setState(() {
                  _searchController.clear();
                  _filters['priority'] = null;
                  _filters['status'] = null;
                  _listKey = UniqueKey();
                }),
                isPrimary: false
              )
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTicketsTable(List<SupportTicket> tickets) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columns: const [
            DataColumn(label: Text("#ID")),
            DataColumn(label: Text("Issue By")),
            DataColumn(label: Text("Title")),
            DataColumn(label: Text("Action")),
          ],
          rows: tickets.map((ticket) => DataRow(
            cells: [
              DataCell(Text(ticket.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ticket.user?.name ?? "User", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              )),
              DataCell(SizedBox(width: 150, child: Text(ticket.title, overflow: TextOverflow.ellipsis))),
              DataCell(TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticketId: ticket.id))),
                child: const Text("VIEW"),
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
