import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'ticket_details.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  static const Color accentColor = Color(0xFF00D1FF);
  static const Color bgColor = Color(0xFF0A0E21);
  static const Color cardColor = Color(0xFF1D2440);

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
        'search': _searchController.text,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };
      final tickets = await ApiService.getAccountantAssignedTickets(filters);
      if (mounted) setState(() => _tickets = tickets);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Assigned Tickets", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: accentColor))
                : _tickets.isEmpty
                    ? _buildEmptyState()
                    : _buildTicketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 16),
          const Text("No assigned tickets found", style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onSubmitted: (_) => _fetchTickets(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search by ID or Title...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSmallDropdown(_selectedPriority, (val) {
                setState(() => _selectedPriority = val!);
                _fetchTickets();
              }, ['all', 'low', 'medium', 'high'], "Priority")),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallDropdown(_selectedStatus, (val) {
                setState(() => _selectedStatus = val!);
                _fetchTickets();
              }, ['all', 'open', 'in_progress', 'resolved'], "Status")),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _fetchTickets,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDropdown(String value, ValueChanged<String?> onChanged, List<String> items, String hint) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: cardColor,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final priorityColor = _getPriorityColor(ticket.priority);
        final statusColor = _getStatusColor(ticket.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString()))),
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text("#${ticket.id}", style: const TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                const SizedBox(width: 12),
                Expanded(child: Text(ticket.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text("By: ${ticket.user?.name ?? 'Unknown'}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(ticket.priority.toUpperCase(), priorityColor),
                    const SizedBox(width: 8),
                    _buildBadge(ticket.status.replaceAll('_', ' ').toUpperCase(), statusColor),
                    const Spacer(),
                    Text(ticket.createdAt, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.redAccent;
      case 'medium': return Colors.orangeAccent;
      case 'low': return Colors.greenAccent;
      default: return Colors.blueAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blueAccent;
      case 'in_progress': return Colors.orangeAccent;
      case 'resolved': return Colors.greenAccent;
      case 'closed': return Colors.white24;
      default: return accentColor;
    }
  }
}
