import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
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
        'search': _searchController.text,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };
      final tickets = widget.isAssigned 
          ? await ApiService.getAccountantAssignedTickets(filters)
          : await ApiService.getAccountantTickets(filters);
      if (mounted) setState(() => _tickets = tickets);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: context.theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.isAssigned ? "Assigned Tickets" : "Support Center",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
        ),
        centerTitle: false,
      ),
      body: _isLoading && _tickets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTickets,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: context.spacing),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(1000)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(context),
                        SizedBox(height: context.spacing * 1.5),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
                          child: Text(
                            "Tickets (${_tickets.length})",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: context.spacing),
                        if (_tickets.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildTicketList(context),
                        SizedBox(height: context.spacing * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: !widget.isAssigned
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTicketPage()))
                    .then((_) => _fetchTickets());
              },
              icon: const Icon(Icons.add),
              label: const Text("New Ticket"),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(80.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              color: theme.colorScheme.outlineVariant,
              size: context.scale(80),
            ),
            SizedBox(height: context.spacing),
            Text(
              "No support tickets found",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter Tickets",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildLabel(context, "Search"),
        buildTextField(
          context, 
          _searchController, 
          "Search by ID or Title...", 
          prefixIcon: Icons.search,
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Priority"),
              buildDropdown(
                context, 
                ['all', 'low', 'medium', 'high'].map((e) => e.toUpperCase()).toList(), 
                _selectedPriority.toUpperCase(), 
                (val) {
                  setState(() => _selectedPriority = val!.toLowerCase());
                  _fetchTickets();
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Status"),
              buildDropdown(
                context, 
                ['all', 'open', 'in_progress', 'resolved', 'closed'].map((e) => e.toUpperCase()).toList(), 
                _selectedStatus.toUpperCase(), 
                (val) {
                  setState(() => _selectedStatus = val!.toLowerCase());
                  _fetchTickets();
                },
              ),
            ],
          ),
        ]),
        SizedBox(height: context.spacing * 1.5),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: buildActionButton(context, "APPLY FILTERS", () => _fetchTickets()),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: buildActionButton(
                context, 
                "RESET", 
                () {
                  _searchController.clear();
                  setState(() {
                    _selectedPriority = 'all';
                    _selectedStatus = 'all';
                  });
                  _fetchTickets();
                },
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketList(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
          mainAxisExtent: context.scale(180),
          crossAxisSpacing: context.spacing,
          mainAxisSpacing: context.spacing,
        ),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          final priorityColor = _getPriorityColor(ticket.priority);
          final statusColor = _getStatusColor(ticket.status);

          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketDetailsPage(ticketId: ticket.encryptedId ?? ticket.id.toString()))),
              borderRadius: BorderRadius.circular(context.scale(16)),
              child: Padding(
                padding: EdgeInsets.all(context.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(5)),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(context.scale(8)),
                          ),
                          child: Text(
                            "#${ticket.id}",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: context.font(11),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, size: context.scale(20), color: theme.colorScheme.onSurfaceVariant),
                      ],
                    ),
                    SizedBox(height: context.spacing),
                    Text(
                      ticket.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildBadge(context, ticket.priority.toUpperCase(), priorityColor),
                        SizedBox(width: context.scale(8)),
                        _buildBadge(context, ticket.status.toUpperCase(), statusColor),
                      ],
                    ),
                    SizedBox(height: context.spacing / 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: context.scale(12), color: theme.colorScheme.onSurfaceVariant),
                        SizedBox(width: context.scale(4)),
                        Text(
                          ticket.createdAt,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: context.font(11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
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
      case 'open': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.orange;
    }
  }
}
