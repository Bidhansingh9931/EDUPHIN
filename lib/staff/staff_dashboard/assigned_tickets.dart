import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';
import 'ticket_details.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart' show SupportTicket;

class StaffAssignedTicketsPage extends StatefulWidget {
  const StaffAssignedTicketsPage({super.key});

  @override
  State<StaffAssignedTicketsPage> createState() => _StaffAssignedTicketsPageState();
}

class _StaffAssignedTicketsPageState extends State<StaffAssignedTicketsPage> {
  late Future<List<SupportTicket>> _assignedTicketsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriority = "all";
  String _selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _assignedTicketsFuture = ApiService.getStaffAssignedTickets({
        'search': _searchController.text.trim(),
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
      ),
      body: Column(
        children: [
          Padding(
            padding: context.pagePadding,
            child: _buildFilters(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadTickets(),
              child: FutureBuilder<List<SupportTicket>>(
                future: _assignedTicketsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: context.pagePadding,
                        child: Text(
                          "Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.confirmation_number_outlined, size: 64, color: theme.hintColor.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text("No tickets assigned to you", style: TextStyle(color: theme.hintColor)),
                        ],
                      ),
                    );
                  }

                  final tickets = snapshot.data!;
                  return ListView.separated(
                    padding: context.pagePadding,
                    itemCount: tickets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTicketItem(context, tickets[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Title...",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _loadTickets(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildFilterDropdown(context, "Priority", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                  setState(() => _selectedPriority = val!);
                  _loadTickets();
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterDropdown(context, "Status", _selectedStatus, ["all", "open", "in_progress", "resolved"], (val) {
                  setState(() => _selectedStatus = val!);
                  _loadTickets();
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase().replaceAll('_', ' ')))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTicketItem(BuildContext context, SupportTicket ticket) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
          _loadTickets();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "#${ticket.id}",
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(
                          label: ticket.priority.toUpperCase(),
                          color: _getPriorityColor(ticket.priority),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: ticket.status.toUpperCase().replaceAll('_', ' '),
                          color: _getStatusColor(ticket.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'in_progress': return Colors.orange;
      case 'open': return Colors.blue;
      default: return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
