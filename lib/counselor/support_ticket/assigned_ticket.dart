import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';
import 'ticket_details.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  late ColorScheme _colorScheme;
  bool _isLoading = true;
  List<SupportTicket> _tickets = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('counselor/tickets/assigned');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List ticketsData = data['data'] ?? data['tickets'] ?? [];
          _tickets = ticketsData.map((j) => SupportTicket.fromJson(j)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load assigned tickets";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tickets"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTickets,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _colorScheme.primary))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: _colorScheme.error)))
                : _tickets.isEmpty
                    ? _buildEmptyState()
                    : _buildTicketList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open_rounded, size: 80, color: _colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 24),
                Text(
                  "No tickets currently assigned to you.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Once tickets are assigned, they will appear here for your review and action.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final t = _tickets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ID: #${t.id}",
                      style: TextStyle(color: _colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    _buildBadge(t.status?.toUpperCase() ?? "OPEN", _getStatusColor(t.status ?? "")),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  t.title,
                  style: GoogleFonts.roboto(color: _colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.priority_high_rounded, size: 14, color: _colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      "Priority: ${t.priority?.toUpperCase() ?? 'LOW'}",
                      style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded, size: 14, color: _colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      t.createdAt?.split('T')[0] ?? "-",
                      style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: t))).then((_) => _fetchTickets());
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("TAKE ACTION", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case "open": return Colors.blue;
      case "resolved": return Colors.green;
      case "closed": return Colors.grey;
      case "in progress": return Colors.orange;
      default: return Colors.grey;
    }
  }
}
