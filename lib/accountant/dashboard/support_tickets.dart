import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'create_ticket.dart';
import 'ticket_details.dart';

class SupportTicketsPage extends StatefulWidget {
  final bool isAssigned;
  const SupportTicketsPage({super.key, this.isAssigned = false});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  bool _isLoading = true;
  List<SupportTicket> _tickets = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriority = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final filters = {
        'title': _searchController.text,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };
      final tickets = widget.isAssigned 
          ? await ApiService.getAccountantAssignedTickets(filters)
          : await ApiService.getAccountantTickets(filters);
      if (mounted) setState(() => _tickets = tickets);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAssigned ? "Assigned Tickets" : "Support Tickets"),
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTicketList(context),
          ),
          if (!widget.isAssigned) _buildCreateTicketButton(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, color: Theme.of(context).hintColor.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text("No tickets found", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _fetchTickets(),
              decoration: const InputDecoration(
                hintText: "Search by ID or Title...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSmallDropdown(context, _selectedPriority, (val) {
                  setState(() => _selectedPriority = val!);
                  _fetchTickets();
                }, ['all', 'low', 'medium', 'high'], "Priority")),
                const SizedBox(width: 12),
                Expanded(child: _buildSmallDropdown(context, _selectedStatus, (val) {
                  setState(() => _selectedStatus = val!);
                  _fetchTickets();
                }, ['all', 'open', 'closed', 'resolved'], "Status")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallDropdown(BuildContext context, String value, ValueChanged<String?> onChanged, List<String> items, String label) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _buildTicketList(BuildContext context) {
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 2 : 1,
        mainAxisExtent: 160,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final priorityColor = _getPriorityColor(ticket.priority);
        final statusColor = _getStatusColor(ticket.status);
        final theme = Theme.of(context);

        return Card(
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString()))),
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text("#${ticket.id}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(child: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(ticket.priority.toUpperCase(), priorityColor),
                    const SizedBox(width: 8),
                    _buildBadge(ticket.status.toUpperCase(), statusColor),
                  ],
                ),
                const Spacer(),
                Text(ticket.createdAt, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
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
      case 'open': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.orange;
    }
  }

  Widget _buildCreateTicketButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTicketPage())).then((_) => _fetchTickets());
          },
          icon: const Icon(Icons.add),
          label: const Text("SUBMIT NEW TICKET"),
        ),
      ),
    );
  }
}
