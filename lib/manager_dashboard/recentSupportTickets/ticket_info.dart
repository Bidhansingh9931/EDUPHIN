import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ticket_details.dart';

// --- ENUMS ---

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get displayName => toBeginningOfSentenceCase(name.replaceAll('InProgress', 'In Progress'))!;

  String get apiName {
    switch (this) {
      case TicketStatus.inProgress:
        return 'in_progress';
      default:
        return name.toLowerCase();
    }
  }
}

enum TicketPriority {
  low,
  medium,
  high;

  String get displayName => toBeginningOfSentenceCase(name)!;
}

// --- DATA MODELS ---

class AssignableUser {
  final int id;
  final String name;

  AssignableUser({required this.id, required this.name});

  factory AssignableUser.fromJson(Map<String, dynamic> json) {
    return AssignableUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown User',
    );
  }
}

class Ticket {
  final String serial;
  final String title;
  final String category;
  final String issuedBy;
  final String createdAt;
  final List<int> assignedUsers;
  final TicketStatus status;
  final TicketPriority priority;

  Ticket({
    required this.serial,
    required this.title,
    required this.category,
    required this.issuedBy,
    required this.createdAt,
    required this.assignedUsers,
    required this.status,
    required this.priority,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Helper function for safe date parsing
    String formatDate(String? dateStr) {
      if (dateStr == null) return 'N/A';
      try {
        return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateStr));
      } catch (e) {
        return 'Invalid Date';
      }
    }

    final List<int> assignedUsersList = [];
    if (json['assigned_users'] is List) {
      for (final user in json['assigned_users']) {
        if (user is Map<String, dynamic> && user['id'] is int) {
          assignedUsersList.add(user['id']);
        }
      }
    }

    return Ticket(
      serial: json['id']?.toString() ?? 'N/A',
      title: json['title']?.toString() ?? 'No Title',
      category: (json['category'] is Map<String, dynamic> ? json['category']['name']?.toString() : null) ?? 'Uncategorized',
      issuedBy: (json['user'] is Map<String, dynamic> ? json['user']['name']?.toString() : null) ?? 'Unknown User',
      createdAt: formatDate(json['created_at']?.toString()),
      assignedUsers: assignedUsersList,
      priority: (json['priority']?.toString() ?? 'medium').toTicketPriority(),
      status: (json['status']?.toString() ?? 'open').toTicketStatus(),
    );
  }
}

// String to Enum conversion helpers
extension on String {
  TicketPriority toTicketPriority() {
    return TicketPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }

  TicketStatus toTicketStatus() {
    const statusMap = {
      'open': TicketStatus.open,
      'in_progress': TicketStatus.inProgress,
      'inprogress': TicketStatus.inProgress,
      'resolved': TicketStatus.resolved,
      'closed': TicketStatus.closed,
    };
    return statusMap[toLowerCase()] ?? TicketStatus.open;
  }
}

// --- MAIN PAGE WIDGET ---

class TicketInfoPage extends StatefulWidget {
  const TicketInfoPage({super.key});

  @override
  State<TicketInfoPage> createState() => _TicketInfoPageState();
}

class _TicketInfoPageState extends State<TicketInfoPage> {
  bool _isLoading = true;
  List<Ticket> _tickets = [];
  List<AssignableUser> _assignableUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/tickets');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> ticketsList = data['tickets'] as List? ?? [];
        final ticketsData =
            ticketsList.whereType<Map<String, dynamic>>().map(Ticket.fromJson).toList();

        final List<dynamic> usersList = data['assignable_users'] as List? ?? [];
        final usersData =
            usersList.whereType<Map<String, dynamic>>().map(AssignableUser.fromJson).toList();

        setState(() {
          _tickets = ticketsData;
          _assignableUsers = usersData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Support Tickets", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Manage and respond to support requests", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement export
            },
          ),
          SizedBox(width: context.sm),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTickets,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: context.responsive(
                    _buildListView(),
                    tablet: _buildGridView(crossAxisCount: 2),
                    desktop: _buildGridView(crossAxisCount: 3),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.md),
          child: TicketCard(
            key: ValueKey(_tickets[index].serial),
            ticket: _tickets[index],
            assignableUsers: _assignableUsers,
            onUpdate: _fetchTickets,
          ),
        );
      },
    );
  }

  Widget _buildGridView({required int crossAxisCount}) {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: _tickets.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return TicketCard(
          key: ValueKey(_tickets[index].serial),
          ticket: _tickets[index],
          assignableUsers: _assignableUsers,
          onUpdate: _fetchTickets,
        );
      },
    );
  }
}

// --- TICKET CARD WIDGET ---

class TicketCard extends StatefulWidget {
  final Ticket ticket;
  final List<AssignableUser> assignableUsers;
  final VoidCallback onUpdate;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.assignableUsers,
    required this.onUpdate,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  late TicketStatus _selectedStatus;
  late TicketPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
    _selectedPriority = widget.ticket.priority;
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.high:
        return Colors.redAccent;
      case TicketPriority.medium:
        return Colors.amber.shade700;
      case TicketPriority.low:
        return Colors.lightBlueAccent;
    }
  }

  Future<void> _updateTicketStatus(TicketStatus newStatus) async {
    try {
      final response = await ApiService.post(
          'manager/tickets/${widget.ticket.serial}/status', {'status': newStatus.apiName});
      if (!mounted) return;
      if (response.statusCode == 200) {
        widget.onUpdate();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Status updated!")));
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to update status';
        throw Exception(error);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateTicketPriority(TicketPriority newPriority) async {
    try {
      final response = await ApiService.post(
          'manager/tickets/${widget.ticket.serial}/priority', {'priority': newPriority.name.toLowerCase()});
      if (!mounted) return;
      if (response.statusCode == 200) {
        widget.onUpdate();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Priority updated!")));
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Failed to update priority';
        throw Exception(error);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn(context, "Serial No.", widget.ticket.serial),
                _priorityChip(context),
              ],
            ),
            SizedBox(height: context.md),
            Text("Title", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontSize: context.font(11))),
            Text(
              widget.ticket.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                Expanded(child: _infoColumn(context, "Issued By", widget.ticket.issuedBy)),
                Expanded(child: _infoColumn(context, "Category", widget.ticket.category)),
              ],
            ),
            SizedBox(height: context.md),
            Text("Assigned to", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontSize: context.font(11))),
            const SizedBox(height: 4),
            Row(
              children: widget.assignableUsers
                  .where((user) => widget.ticket.assignedUsers.contains(user.id))
                  .map<Widget>((e) => _avatar(context, e.name.substring(0, 2).toUpperCase()))
                  .toList(),
            ),
            SizedBox(height: context.md),
            _infoColumn(context, "Created At", widget.ticket.createdAt),
            SizedBox(height: context.md),
            const Divider(),
            SizedBox(height: context.sm),
            Row(
              children: [
                _actionIconButton(
                  context,
                  icon: Icons.sync,
                  label: "Status",
                  onTap: () => _openStatusBottomSheet(context),
                ),
                SizedBox(width: context.sm),
                _actionIconButton(
                  context,
                  icon: Icons.priority_high,
                  label: "Priority",
                  onTap: () => _openPriorityBottomSheet(context),
                ),
                SizedBox(width: context.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailsPage(ticketId: widget.ticket.serial),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: Text("VIEW DETAILS", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(BuildContext context, String label, String value) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary, fontSize: context.font(11))),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(14))),
      ],
    );
  }

  Widget _priorityChip(BuildContext context) {
    final theme = context.theme;
    final color = _getPriorityColor(_selectedPriority);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        _selectedPriority.displayName.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: context.font(10)),
      ),
    );
  }

  Widget _avatar(BuildContext context, String text) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: context.scale(32),
      height: context.scale(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: context.font(10),
        ),
      ),
    );
  }

  Widget _actionIconButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = context.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scale(12)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(6)),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        child: Column(
          children: [
            Icon(icon, size: context.scale(18), color: theme.colorScheme.primary),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(10))),
          ],
        ),
      ),
    );
  }

  // -------------------- BOTTOM SHEETS --------------------

  void _openStatusBottomSheet(BuildContext context) {
    TicketStatus tempSelection = _selectedStatus;
    _showSheet(
      context: context,
      title: "Change Ticket Status",
      contentBuilder: (modalStateSetter) => Column(
        mainAxisSize: MainAxisSize.min,
        children: TicketStatus.values
            .map((status) => _radioTile<TicketStatus>(
                  status.displayName,
                  status,
                  tempSelection,
                  (v) => modalStateSetter(() => tempSelection = v!),
                ))
            .toList(),
      ),
      buttonText: "Update Status",
      onConfirm: () => _updateTicketStatus(tempSelection),
    );
  }

  void _openPriorityBottomSheet(BuildContext context) {
    TicketPriority tempSelection = _selectedPriority;
    _showSheet(
      context: context,
      title: "Set Ticket Priority",
      contentBuilder: (modalStateSetter) => Column(
        mainAxisSize: MainAxisSize.min,
        children: TicketPriority.values
            .map((priority) => _radioTile<TicketPriority>(
                  priority.displayName,
                  priority,
                  tempSelection,
                  (v) => modalStateSetter(() => tempSelection = v!),
                ))
            .toList(),
      ),
      buttonText: "Update Priority",
      onConfirm: () => _updateTicketPriority(tempSelection),
    );
  }

  // -------------------- HELPERS --------------------

  void _showSheet({
    required BuildContext context,
    required String title,
    required Widget Function(StateSetter) contentBuilder,
    required String buttonText,
    required Future<void> Function() onConfirm,
  }) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
      ),
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                context.spacing, context.spacing, context.spacing, MediaQuery.of(context).padding.bottom + context.spacing),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: context.scale(40),
                height: 4,
                margin: EdgeInsets.only(bottom: context.spacing),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
              SizedBox(height: context.spacing),
              contentBuilder(setModalState),
              SizedBox(height: context.spacing),
              buildActionButton(context, buttonText.toUpperCase(), () async {
                await onConfirm();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }),
            ]),
          );
        },
      ),
    );
  }

  Widget _radioTile<T>(
      String text, T value, T groupValue, ValueChanged<T?> onChanged) {
    final theme = context.theme;
    return Container(
      margin: EdgeInsets.only(bottom: context.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(
          color: value == groupValue ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: value == groupValue ? 1.5 : 0.5,
        ),
      ),
      child: RadioListTile<T>(
        title: Text(text, style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(16), fontWeight: value == groupValue ? FontWeight.bold : FontWeight.normal)),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: context.sm),
      ),
    );
  }

  Widget _rowText(ThemeData theme, String l1, String v1, String l2, String v2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_columnText(theme, l1, v1), _columnText(theme, l2, v2)],
    );
  }

  Widget _columnText(ThemeData theme, String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: theme.hintColor)),
      const SizedBox(height: 4),
      Text(value, style: theme.textTheme.bodyLarge),
    ]);
  }

  Widget _actionButton(ThemeData theme,
      {required String text, required VoidCallback onTap, required bool isPrimary}) {
    final Color textColor =
        isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer;
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.secondaryContainer,
          foregroundColor: isPrimary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
