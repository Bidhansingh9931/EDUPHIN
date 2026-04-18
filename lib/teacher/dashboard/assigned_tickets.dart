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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Assigned Tickets", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(20))),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
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
                          padding: EdgeInsets.all(context.scale(24)),
                          child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                        ),
                      );
                    } else if (_tickets.isEmpty) {
                      return Center(child: Text("No tickets assigned to you.", style: TextStyle(fontSize: context.font(14))));
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
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: context.pagePadding.copyWith(bottom: 0),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => _filters['search'] = value,
              onSubmitted: (_) => _loadAssignedTickets(),
              style: TextStyle(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "Search by title...",
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
              ),
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                Expanded(child: _buildFilterDropdown('Priority', ['low', 'medium', 'high'], _filters['priority'] ?? '', (val) {
                  setState(() => _filters['priority'] = val ?? '');
                  _loadAssignedTickets();
                })),
                SizedBox(width: context.md),
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
        initialValue: value.isEmpty ? null : value,
        style: TextStyle(fontSize: context.font(13), color: context.theme.colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: context.font(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i.toUpperCase(), style: TextStyle(fontSize: context.font(11)))))
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.spacing),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
            SizedBox(height: context.scale(12)),
            Row(
              children: [
                _buildChip(context, ticket.status, _getStatusColor(ticket.status)),
                SizedBox(width: context.scale(8)),
                _buildChip(context, ticket.priority, _getPriorityColor(ticket.priority)),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.md),
              child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            _infoRow(context, "Created:", _formatDate(ticket.createdAt)),
            SizedBox(height: context.scale(16)),
            SizedBox(
              width: double.infinity,
              height: context.scale(48),
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TicketPage(ticketId: ticket.id)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  elevation: 0,
                ),
                child: Text("VIEW DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = context.theme;
    return Row(
      children: [
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: context.font(12))),
        SizedBox(width: context.scale(8)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(12), color: theme.colorScheme.onSurface)),
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
      case 'in_progress': return const Color(0xFFF59E0B);
      case 'resolved':
      case 'closed': return const Color(0xFF10B981);
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return const Color(0xFFEF4444);
      case 'medium': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }
}
