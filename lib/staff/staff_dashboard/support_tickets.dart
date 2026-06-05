import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/common_widgets.dart';
import 'staff_models.dart';
import 'create_ticket.dart';
import 'ticket_details.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart' show SupportTicket;
import 'package:eduphin/services/responsive_helper.dart';

class StaffSupportTicketsPage extends StatefulWidget {
  const StaffSupportTicketsPage({super.key});

  @override
  State<StaffSupportTicketsPage> createState() => _StaffSupportTicketsPageState();
}

class _StaffSupportTicketsPageState extends State<StaffSupportTicketsPage> {
  late Stream<List<SupportTicket>> _ticketsStream;
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
      _ticketsStream = ApiService.getStaffTicketsStream({
        'title': _searchController.text.trim(),
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Support Tickets"),
        actions: [
          IconButton(
            onPressed: _loadTickets,
            icon: Icon(Icons.refresh_rounded, size: context.scale(20)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(context),
                  SizedBox(height: context.scale(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ticket History",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(16),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffCreateTicketPage()));
                          if (context.mounted) _loadTickets();
                        },
                        icon: Icon(Icons.add_rounded, size: context.scale(18)),
                        label: Text("NEW TICKET", style: TextStyle(fontSize: context.font(12))),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.scale(16)),
                  _buildTicketList(context),
                  SizedBox(height: context.scale(40)),
                ],
              ),
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
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Tickets",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(14),
              ),
            ),
            SizedBox(height: context.scale(16)),
            TextField(
              controller: _searchController,
              style: TextStyle(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "Search by subject...",
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onSubmitted: (_) => _loadTickets(),
            ),
            SizedBox(height: context.scale(12)),
            context.responsive(
              Column(
                children: [
                  _buildFilterDropdown(context, "PRIORITY", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                    setState(() => _selectedPriority = val!);
                    _loadTickets();
                  }),
                  SizedBox(height: context.scale(12)),
                  _buildFilterDropdown(context, "STATUS", _selectedStatus, ["all", "open", "closed"], (val) {
                    setState(() => _selectedStatus = val!);
                    _loadTickets();
                  }),
                ],
              ),
              tablet: Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(context, "PRIORITY", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                      setState(() => _selectedPriority = val!);
                      _loadTickets();
                    }),
                  ),
                  SizedBox(width: context.scale(12)),
                  Expanded(
                    child: _buildFilterDropdown(context, "STATUS", _selectedStatus, ["all", "open", "closed"], (val) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.scale(4), bottom: context.scale(4)),
          child: Text(label, style: TextStyle(fontSize: context.font(10), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(context.scale(12)),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.colorScheme.surface,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: TextStyle(fontSize: context.font(13))))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketList(BuildContext context) {
    return StreamBuilder<List<SupportTicket>>(
      stream: _ticketsStream,
      builder: (context, snapshot) {
        return LoadingWrapper<List<SupportTicket>>(
          snapshot: snapshot,
          skeleton: _buildSkeleton(context),
          builder: (tickets) => _buildContent(context, tickets),
          onRetry: _loadTickets,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, List<SupportTicket> tickets) {
    if (tickets.isEmpty) {
      return _buildEmptyState(context, "No support tickets found", Icons.confirmation_number_outlined);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 2),
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(140),
      ),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(context, ticket);
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 2),
        crossAxisSpacing: context.scale(16),
        mainAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(140),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const Skeleton(height: 140, borderRadius: 20);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(40)),
        child: Column(
          children: [
            Icon(icon, size: context.scale(48), color: context.theme.colorScheme.primary.withValues(alpha: 0.2)),
            SizedBox(height: context.scale(16)),
            Text(message, style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14))),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicket ticket) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
          _loadTickets();
        },
        borderRadius: BorderRadius.circular(context.scale(20)),
        child: Padding(
          padding: EdgeInsets.all(context.scale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(6)),
                    ),
                    child: Text(
                      "#${ticket.id}",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.font(11),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildPriorityBadge(context, ticket.priority),
                ],
              ),
              SizedBox(height: context.scale(12)),
              Text(
                ticket.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.font(14),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: context.scale(12), color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: context.scale(6)),
                  Text(
                    "Oct 24, 2023", // Assuming created_at exists or mock it
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: context.scale(16), color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.red; break;
      case 'medium': color = Colors.orange; break;
      case 'low': color = Colors.green; break;
      default: color = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(8)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: context.font(10),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        )
      ),
    );
  }
}
