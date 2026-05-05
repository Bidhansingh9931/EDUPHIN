import 'dart:convert';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eduphin/services/api_service.dart';
import 'ticket_info.dart'; // To use TicketStatus and TicketPriority enums if needed, or keep local
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
  List<AssignedTicket> _tickets = [];
  bool _isLoading = true;
  Object? _error;
  final String _cacheKey = 'manager_assigned_tickets';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {}); // Rebuild the widget to apply the filter
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadCachedData();
    await _fetchAssignedTickets();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null && mounted) {
      final List<dynamic> ticketsJson = cachedData['data'] ?? [];
      setState(() {
        _tickets = ticketsJson.map((json) => AssignedTicket.fromJson(json)).toList();
        _isLoading = _tickets.isEmpty;
      });
    }
  }

  Future<void> _refreshTickets() async {
    _searchController.clear();
    await _fetchAssignedTickets();
  }

  Future<void> _fetchAssignedTickets() async {
    if (_tickets.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await ApiService.get('manager/assigned-tickets');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
        await CacheService.setCache(_cacheKey, responseData);
          final List<dynamic> ticketsJson = responseData['data'];
          final tickets = ticketsJson.map((json) => AssignedTicket.fromJson(json)).toList();

          if (mounted) {
            setState(() {
              _tickets = tickets;
              _isLoading = false;
              _error = null;
            });
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tickets');
        }
      } else {
        throw Exception('Failed to load tickets: Server error ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
        ErrorHandler.showError(context, e);
      }
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
      ErrorHandler.showError(context, e);
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _tickets.isNotEmpty,
        error: _error,
        onRetry: _fetchAssignedTickets,
        skeleton: _buildSkeleton(),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildSkeleton() {
    final theme = context.theme;
    return Column(
      children: [
        Padding(
          padding: context.pagePadding,
          child: SkeletonBox(height: context.scale(50), borderRadius: context.scale(12)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: context.spacing),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: context.md),
              child: Container(
                padding: context.pagePadding,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(height: context.scale(15), width: context.scale(40)),
                        SkeletonBox(height: context.scale(25), width: context.scale(60)),
                      ],
                    ),
                    SizedBox(height: context.scale(12)),
                    SkeletonBox(height: context.scale(20), width: context.scale(180)),
                    SizedBox(height: context.scale(8)),
                    SkeletonBox(height: context.scale(15), width: context.scale(100)),
                    SizedBox(height: context.scale(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(height: context.scale(35), width: context.scale(100)),
                        SkeletonBox(height: context.scale(15), width: context.scale(80)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_tickets.isEmpty && !_isLoading) {
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
    }

    final searchQuery = _searchController.text.toLowerCase();
    final filteredTickets = _tickets.where((ticket) {
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
