import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ticket_details.dart';

// --- ENUMS ---

enum TicketStatus {
  open,
  inProgress,
  onHold,
  resolved,
  closed;

  String get displayName => toBeginningOfSentenceCase(name.replaceAll('InProgress', 'In Progress'))!;
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
      serial: json['serial']?.toString() ?? 'N/A',
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
    final formattedString = toLowerCase().replaceAll('-', '');
    return TicketStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == formattedString,
      orElse: () => TicketStatus.open,
    );
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

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final List<dynamic> ticketsList = data['tickets'] as List? ?? [];
          final ticketsData = ticketsList.whereType<Map<String, dynamic>>().map(Ticket.fromJson).toList();

          final List<dynamic> usersList = data['assignable_users'] as List? ?? [];
          final usersData = usersList.whereType<Map<String, dynamic>>().map(AssignableUser.fromJson).toList();

          setState(() {
            _tickets = ticketsData;
            _assignableUsers = usersData;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load tickets');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: const Text(
          "Recent Support Tickets",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.download),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return _buildGridView();
              } else {
                return _buildListView();
              }
            }),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        return TicketCard(
          key: ValueKey(_tickets[index].serial),
          ticket: _tickets[index],
          assignableUsers: _assignableUsers,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: _tickets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        return TicketCard(
          key: ValueKey(_tickets[index].serial),
          ticket: _tickets[index],
          assignableUsers: _assignableUsers,
        );
      },
    );
  }
}

// --- TICKET CARD WIDGET ---

class TicketCard extends StatefulWidget {
  final Ticket ticket;
  final List<AssignableUser> assignableUsers;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.assignableUsers,
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
      final response = await ApiService.post('manager/tickets/${widget.ticket.serial}/status', {'status': newStatus.name.replaceAll('InProgress', 'in_progress').toLowerCase()});
      if(mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _selectedStatus = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated!")));
        } else {
          throw Exception('Failed to update status');
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _updateTicketPriority(TicketPriority newPriority) async {
    try {
      final response = await ApiService.post('manager/tickets/${widget.ticket.serial}/priority', {'priority': newPriority.name.toLowerCase()});
      if(mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _selectedPriority = newPriority;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Priority updated!")));
        } else {
          throw Exception('Failed to update priority');
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowText(theme, "Serial No.", widget.ticket.serial, "Issued By",
              widget.ticket.issuedBy),
          const SizedBox(height: 12),
          Text("Title", style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(widget.ticket.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priorityChip(theme),
              _columnText(theme, "Category", widget.ticket.category),
            ],
          ),
          const SizedBox(height: 12),
          Text("Assigned to", style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 6),
          Row(
            children: widget.assignableUsers.where((user) => widget.ticket.assignedUsers.contains(user.id)).map((e) => _avatar(theme, e.name.substring(0, 2).toUpperCase())).toList(),
          ),
          const SizedBox(height: 12),
          Text("Created At", style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(widget.ticket.createdAt),
          const Divider(height: 32),
          Row(
            children: [
              _actionButton(
                theme,
                text: "Change Status",
                onTap: () => _openStatusBottomSheet(context),
                isPrimary: false,
              ),
              const SizedBox(width: 10),
              _actionButton(
                theme,
                text: "Set Priority",
                onTap: () => _openPriorityBottomSheet(context),
                isPrimary: false,
              ),
              const SizedBox(width: 10),
              _actionButton(
                theme,
                text: "View",
                onTap: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketDetailsPage(ticketId: widget.ticket.serial,)));
                },
                isPrimary: true,
              ),
            ],
          ),
        ],
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
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              contentBuilder(setModalState),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(buttonText,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _radioTile<T>(
      String text, T value, T groupValue, ValueChanged<T?> onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(text, style: theme.textTheme.bodyLarge),
        leading: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        onTap: () => onChanged(value),
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

  Widget _priorityChip(ThemeData theme) {
    final color = _getPriorityColor(_selectedPriority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(38), // Replaced withAlpha
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_selectedPriority.displayName,
          style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _avatar(ThemeData theme, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(text, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _actionButton(ThemeData theme, {required String text, required VoidCallback onTap, required bool isPrimary}) {
    final Color textColor = isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer;
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
          foregroundColor: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
