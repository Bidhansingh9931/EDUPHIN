import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/tickets.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:intl/intl.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  Future<void>? _ticketsFuture;
  List<SupportTicket> _tickets = [];
  String? _error;

  final Map<String, String> _filters = {'priority': '', 'status': '', 'search': ''};

  @override
  void initState() {
    super.initState();
    _loadAssignedTickets();
  }

  Future<void> _loadAssignedTickets() async {
    setState(() {
      _ticketsFuture = _fetchAssignedTickets();
    });
  }

  Future<void> _fetchAssignedTickets() async {
    try {
      final tickets = await ApiService.getAssignedTickets(_filters);
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load assigned tickets: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _tickets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  );
                } else if (_tickets.isEmpty) {
                  return const Center(child: Text("No tickets assigned to you."));
                }
                return RefreshIndicator(
                  onRefresh: _loadAssignedTickets,
                  child: ListView.builder(
                    padding: context.pagePadding,
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) => TicketCard(ticket: _tickets[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => _filters['search'] = value,
              onSubmitted: (_) => _loadAssignedTickets(),
              decoration: const InputDecoration(
                hintText: "Search by title...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildFilterDropdown('Priority', ['low', 'medium', 'high'], _filters['priority'] ?? '', (val) {
                  setState(() => _filters['priority'] = val ?? '');
                  _loadAssignedTickets();
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterDropdown('Status', ['open', 'in_progress', 'resolved', 'closed'], _filters['status'] ?? '', (val) {
                   setState(() => _filters['status'] = val ?? '');
                  _loadAssignedTickets();
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildFilterDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
     return DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i.toUpperCase(), style: const TextStyle(fontSize: 12))))
            .toList(),
        onChanged: onChanged,
      );
   }
}

class TicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(context, ticket.status, _getStatusColor(ticket.status)),
                const SizedBox(width: 8),
                _buildChip(context, ticket.priority, _getPriorityColor(ticket.priority)),
              ],
            ),
            const Divider(height: 24),
            _infoRow(context, "Created:", _formatDate(ticket.createdAt)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TicketPage(ticketId: ticket.id)),
                  );
                },
                child: const Text("VIEW DETAILS"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    );
  }
  
  String _formatDate(String dateStr) {
    try {
      return DateFormat.yMMMd().format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'resolved':
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.amber;
      default: return Colors.grey;
    }
  }
}
