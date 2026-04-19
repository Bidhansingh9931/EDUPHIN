import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Assigned Tickets", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Filter Tickets", Icons.filter_list_rounded),
                  SizedBox(height: context.md),
                  _buildFilters(context),
                  SizedBox(height: context.xl),
                  _buildSectionHeader("Support Queue", Icons.confirmation_number_outlined),
                  SizedBox(height: context.md),
                  FutureBuilder<List<SupportTicket>>(
                    future: _assignedTicketsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.all(context.scale(32)),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: EdgeInsets.all(context.scale(32)),
                          child: Center(
                            child: Text(
                              "Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      final tickets = snapshot.data!;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                          crossAxisSpacing: context.spacing,
                          mainAxisSpacing: context.spacing,
                          mainAxisExtent: context.scale(260),
                        ),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) => _buildTicketItem(context, tickets[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(18),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.only(top: context.scale(40)),
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(24)),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.scale(60), horizontal: context.scale(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.confirmation_number_outlined, size: context.scale(80), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                SizedBox(height: context.scale(24)),
                Text(
                  "No tickets assigned to you",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: context.font(20),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: context.scale(12)),
                Text(
                  "Try adjusting your filters or check back later for new assignments.",
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
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
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
              controller: _searchController,
              style: TextStyle(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "Search Title...",
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              onSubmitted: (_) => _loadTickets(),
            ),
            SizedBox(height: context.md),
            context.responsive(
              Column(
                children: [
                  _buildFilterDropdown(context, "Priority", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                    setState(() => _selectedPriority = val!);
                    _loadTickets();
                  }),
                  SizedBox(height: context.md),
                  _buildFilterDropdown(context, "Status", _selectedStatus, ["all", "open", "in_progress", "resolved"], (val) {
                    setState(() => _selectedStatus = val!);
                    _loadTickets();
                  }),
                ],
              ),
              tablet: Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(context, "Priority", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                      setState(() => _selectedPriority = val!);
                      _loadTickets();
                    }),
                  ),
                  SizedBox(width: context.md),
                  Expanded(
                    child: _buildFilterDropdown(context, "Status", _selectedStatus, ["all", "open", "in_progress", "resolved"], (val) {
                      setState(() => _selectedStatus = val!);
                      _loadTickets();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.colorScheme.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14), fontWeight: FontWeight.w600),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase().replaceAll('_', ' '), style: TextStyle(fontSize: context.font(13))))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTicketItem(BuildContext context, SupportTicket ticket) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID: #${ticket.id}",
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(12)),
                ),
                _StatusBadge(
                  label: ticket.status.toUpperCase().replaceAll('_', ' '),
                  color: _getStatusColor(ticket.status),
                ),
              ],
            ),
            SizedBox(height: context.md),
            Expanded(
              child: Text(
                ticket.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(color: colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                Icon(Icons.priority_high_rounded, size: context.scale(14), color: _getPriorityColor(ticket.priority)),
                SizedBox(width: context.scale(6)),
                Text(
                  "Priority: ${ticket.priority.toUpperCase()}",
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11), fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: context.scale(14), color: colorScheme.onSurfaceVariant),
                SizedBox(width: context.scale(6)),
                Text(
                  ticket.createdAt.split('T')[0],
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                ),
              ],
            ),
            SizedBox(height: context.md),
            SizedBox(
              width: double.infinity,
              height: context.scale(44),
              child: FilledButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
                  _loadTickets();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: Text("VIEW DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), letterSpacing: 1)),
              ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
      ),
    );
  }
}

