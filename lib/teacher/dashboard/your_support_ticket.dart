import 'package:eduphin/teacher/dashboard/ticket_details_page.dart';
import 'package:eduphin/teacher/dashboard/create_new_support_ticket.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'common_widgets.dart';

class YourSupportTicketPage extends StatefulWidget {
  const YourSupportTicketPage({super.key});

  @override
  State<YourSupportTicketPage> createState() => _YourSupportTicketPageState();
}

class _YourSupportTicketPageState extends State<YourSupportTicketPage> {
  final Map<String, String?> _filters = {'priority': null, 'status': null};
  final TextEditingController _searchController = TextEditingController();
  Key _listKey = UniqueKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.track_changes_outlined, size: 20),
            SizedBox(width: 12),
            Text("Your Support Tickets"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder<List<SupportTicket>>(
              key: _listKey,
              future: ApiService.getMyTickets(_getCleanFilters()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No tickets found."));
                }

                final tickets = snapshot.data!;
                return _buildTicketsList(tickets);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildActionButton(
              context, 
              "+ CREATE NEW TICKET", 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage())).then((_) => setState(() => _listKey = UniqueKey()))
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
      ],
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 80, child: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticketId: ticket.id))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text(ticket.id.toString())),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: _buildPriorityChip(ticket.priority),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color = Colors.grey;
    if (priority.toLowerCase() == 'high') color = Colors.red;
    else if (priority.toLowerCase() == 'medium') color = Colors.orange;
    else if (priority.toLowerCase() == 'low') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
