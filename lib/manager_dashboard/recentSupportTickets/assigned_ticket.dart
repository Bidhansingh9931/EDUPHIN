import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import 'ticket_details.dart';

// Model for an assigned ticket based on the UI and API speculation
class AssignedTicket {
  final int id;
  final String issueBy;
  final String title;
  final String priority;
  String status; // mutable for dropdown
  final String category;
  final DateTime createdAt;

  AssignedTicket({
    required this.id,
    required this.issueBy,
    required this.title,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
  });

  factory AssignedTicket.fromJson(Map<String, dynamic> json) {
    // This factory is designed to be highly robust against unexpected API data types.
    // It safely parses all fields, providing default values to prevent crashes.
    return AssignedTicket(
      // Safely parse ID, converting from String if necessary.
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      // Safely get the 'issueBy' name from a potentially nested object.
      issueBy: (json['user_detail'] is Map
              ? json['user_detail']['name']?.toString()
              : null) ??
          'N/A',

      title: json['title']?.toString() ?? 'No Title',
      priority: json['priority']?.toString() ?? 'low',
      status: json['status']?.toString() ?? 'open',

      // Safely get the 'category' name from a potentially nested object.
      category: (json['category'] is Map
              ? json['category']['name']?.toString()
              : null) ??
          'General',

      // Safely parse the date, with a fallback to the current time.
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AssignedTicketsScreen extends StatefulWidget {
  const AssignedTicketsScreen({super.key});

  @override
  AssignedTicketsScreenState createState() => AssignedTicketsScreenState();
}

class AssignedTicketsScreenState extends State<AssignedTicketsScreen> {
  late Future<List<AssignedTicket>> _ticketsFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _fetchAssignedTickets();
    _searchController.addListener(() {
      setState(() {}); // Rebuild the widget to apply the filter
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTickets() async {
    setState(() {
      // Clear search and re-fetch tickets
      _searchController.clear();
      _ticketsFuture = _fetchAssignedTickets();
    });
  }

  Future<List<AssignedTicket>> _fetchAssignedTickets() async {
    try {
      final response = await ApiService.get('manager/assigned-tickets');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> ticketsJson = responseData['data'];
          // The FutureBuilder will use this returned list
          return ticketsJson.map((json) => AssignedTicket.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tickets: API status false');
        }
      } else {
        throw Exception('Failed to load tickets: Server error ${response.statusCode}');
      }
    } catch (e) {
      // The ApiService handles connection errors, so we just rethrow its message.
      throw Exception('Failed to fetch tickets: $e');
    }
  }

  Future<void> _updateTicketStatus(AssignedTicket ticket, String newStatus) async {
    final theme = Theme.of(context);
    try {
      final response = await ApiService.post(
        'manager/tickets/${ticket.id}/status',
        {'status': newStatus},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            ticket.status = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ticket #${ticket.id} status updated to $newStatus'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update status');
        }
      } else {
        throw Exception('Failed to update status: Server error ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Assigned Tickets'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        foregroundColor: context.theme.colorScheme.onSurface,
      ),
      body: FutureBuilder<List<AssignedTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: context.pagePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: context.scale(48), color: context.theme.colorScheme.error),
                    SizedBox(height: context.sm),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: context.theme.textTheme.titleMedium),
                    SizedBox(height: context.md),
                    ElevatedButton.icon(
                      onPressed: _refreshTickets,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: context.scale(64), color: context.theme.colorScheme.outline),
                  SizedBox(height: context.sm),
                  Text('No assigned tickets found.', style: context.theme.textTheme.titleMedium),
                ],
              ),
            );
          } else {
            final allTickets = snapshot.data!;
            final searchQuery = _searchController.text.toLowerCase();

            final filteredTickets = allTickets.where((ticket) {
              return ticket.title.toLowerCase().contains(searchQuery) ||
                  ticket.issueBy.toLowerCase().contains(searchQuery) ||
                  ticket.id.toString().contains(searchQuery);
            }).toList();

            return RefreshIndicator(
              onRefresh: _refreshTickets,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: context.isMobile
                            ? _buildMobileList(filteredTickets)
                            : _buildDesktopTable(filteredTickets),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: context.pagePadding,
      child: TextField(
        controller: _searchController,
        style: context.theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search by ID, Title, or Issue By',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: context.theme.colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 1.5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMobileList(List<AssignedTicket> tickets) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.spacing),
      itemCount: tickets.length,
      itemBuilder: (context, index) => _buildTicketCard(tickets[index]),
    );
  }

  Widget _buildTicketCard(AssignedTicket ticket) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.md),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(ticket),
        borderRadius: BorderRadius.circular(context.scale(12)),
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${ticket.id}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  _buildPriorityChip(ticket.priority, theme),
                ],
              ),
              SizedBox(height: context.sm),
              Text(ticket.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: context.xs),
              Text('By: ${ticket.issueBy}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: context.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusDropdown(ticket, theme),
                  Text(DateFormat('dd MMM, yyyy').format(ticket.createdAt), style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopTable(List<AssignedTicket> tickets) {
    final theme = context.theme;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.spacing),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
        child: DataTable(
          columnSpacing: context.responsive(20.0, tablet: 30.0, desktop: 40.0),
          columns: const [
            DataColumn(label: Text('#ID')),
            DataColumn(label: Text('ISSUE BY')),
            DataColumn(label: Text('TITLE')),
            DataColumn(label: Text('PRIORITY')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('CATEGORY')),
            DataColumn(label: Text('CREATED AT')),
            DataColumn(label: Text('ACTION')),
          ],
          rows: tickets.map((ticket) => _buildDataRow(ticket, theme)).toList(),
        ),
      ),
    );
  }

  void _navigateToDetails(AssignedTicket ticket) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
  }

  DataRow _buildDataRow(AssignedTicket ticket, ThemeData theme) {
    return DataRow(cells: [
      DataCell(Text(ticket.id.toString())),
      DataCell(Text(ticket.issueBy)),
      DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200), child: Text(ticket.title, overflow: TextOverflow.ellipsis))),
      DataCell(_buildPriorityChip(ticket.priority, theme)),
      DataCell(_buildStatusDropdown(ticket, theme)),
      DataCell(Text(ticket.category)),
      DataCell(Text(DateFormat('dd MMM, yyyy').format(ticket.createdAt))),
      DataCell(
        TextButton.icon(
          onPressed: () => _navigateToDetails(ticket),
          icon: const Icon(Icons.reply_rounded, size: 18),
          label: const Text('VIEW'),
        ),
      ),
    ]);
  }

  Widget _buildPriorityChip(String priority, ThemeData theme) {
    Color color;
    String label = priority.isNotEmpty ? priority[0].toUpperCase() + priority.substring(1) : '';
    switch (priority.toLowerCase()) {
      case 'high':
        color = theme.colorScheme.error;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.blue;
        break;
      default:
        color = theme.colorScheme.outline;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(context.xs),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusDropdown(AssignedTicket ticket, ThemeData theme) {
    const statusOptions = ['open', 'in_progress', 'resolved', 'closed'];

    return DropdownButtonHideUnderline(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(context.xs),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: DropdownButton<String>(
          value: ticket.status,
          isDense: true,
          dropdownColor: theme.colorScheme.surface,
          items: statusOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.replaceAll('_', ' ').split(' ').map((l) => l[0].toUpperCase() + l.substring(1)).join(' '),
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && newValue != ticket.status) {
              _updateTicketStatus(ticket, newValue);
            }
          },
        ),
      ),
    );
  }
}
