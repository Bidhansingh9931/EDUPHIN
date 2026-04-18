import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
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
    final colorScheme = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Assigned Tickets", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTickets,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error)))
                : _tickets.isEmpty
                    ? _buildEmptyState()
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: _buildTicketList(),
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = context.theme.colorScheme;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scale(24)),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.scale(60), horizontal: context.scale(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded, size: context.scale(80), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                    SizedBox(height: context.scale(24)),
                    Text(
                      "No tickets currently assigned to you.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: context.font(20),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: context.scale(12)),
                    Text(
                      "Once tickets are assigned, they will appear here for your review and action.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.font(14),
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    final colorScheme = context.theme.colorScheme;
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
        mainAxisExtent: context.scale(280),
      ),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final t = _tickets[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ID: #${t.id}",
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(13)),
                    ),
                    _buildBadge(t.status?.toUpperCase() ?? "OPEN", _getStatusColor(t.status ?? "")),
                  ],
                ),
                SizedBox(height: context.scale(16)),
                Expanded(
                  child: Text(
                    t.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(color: colorScheme.onSurface, fontSize: context.font(18), fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: context.scale(12)),
                Row(
                  children: [
                    Icon(Icons.priority_high_rounded, size: context.scale(14), color: colorScheme.onSurfaceVariant),
                    SizedBox(width: context.scale(6)),
                    Text(
                      "Priority: ${t.priority?.toUpperCase() ?? 'LOW'}",
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded, size: context.scale(14), color: colorScheme.onSurfaceVariant),
                    SizedBox(width: context.scale(6)),
                    Text(
                      t.createdAt?.split('T')[0] ?? "-",
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(24)),
                SizedBox(
                  width: double.infinity,
                  height: context.scale(48),
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: t))).then((_) => _fetchTickets());
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: Text("TAKE ACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
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
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
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
