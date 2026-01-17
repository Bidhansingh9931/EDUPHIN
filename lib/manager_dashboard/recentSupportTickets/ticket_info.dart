import 'package:eduphin/manager_dashboard/recentSupportTickets/ticket_details.dart';
import 'package:flutter/material.dart';

// --- ENUMS & MODELS ---

enum TicketStatus { open, inProgress, resolved, closed }

// Helper to get a string representation
extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.inProgress:
        return "In-Progress";
      default:
        // Capitalizes the first letter (e.g., "open" -> "Open")
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

enum TicketPriority { high, medium, low }

// Helper to get a string representation
extension TicketPriorityExtension on TicketPriority {
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class Ticket {
  final String serial;
  final String issuedBy;
  final String title;
  final String category;
  final List<String> assignedUsers;
  final String createdAt;
  TicketStatus status;
  TicketPriority priority;

  Ticket({
    required this.serial,
    required this.issuedBy,
    required this.title,
    required this.priority,
    required this.category,
    required this.assignedUsers,
    required this.createdAt,
    required this.status,
  });

  // Factory constructor for creating a new Ticket instance from a map.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      serial: json['serial'] as String,
      issuedBy: json['issuedBy'] as String,
      title: json['title'] as String,
      priority: (json['priority'] as String).toTicketPriority(),
      category: json['category'] as String,
      assignedUsers: List<String>.from(json['assignedUsers']),
      createdAt: json['createdAt'] as String,
      status: (json['status'] as String).toTicketStatus(),
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

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  // TODO: Replace this with your actual API call in the future
  Future<void> _fetchTickets() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> dummyData = [
      {
        "serial": "#001245",
        "issuedBy": "Ananya Sharma",
        "title": "Wi-Fi Connectivity Issue in Library",
        "priority": "High",
        "category": "IT Support",
        "assignedUsers": ["RK", "SM", "PV"],
        "createdAt": "24 Nov 2025, 10:30 AM",
        "status": "open",
      },
      {
        "serial": "#001244",
        "issuedBy": "Rohan Verma",
        "title": "Projector Malfunction in Room 301",
        "priority": "Medium",
        "category": "Classroom AV",
        "assignedUsers": ["RK"],
        "createdAt": "23 Nov 2025, 02:15 PM",
        "status": "inProgress",
      },
    ];

    if (mounted) {
      setState(() {
        _tickets = dummyData.map((data) => Ticket.fromJson(data)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A24),
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
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
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                return TicketCard(
                  key: ValueKey(_tickets[index].serial), // Use a unique key
                  ticket: _tickets[index],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            ),
    );
  }
}

// --- TICKET CARD WIDGET ---

class TicketCard extends StatefulWidget {
  final Ticket ticket;

  const TicketCard({
    super.key,
    required this.ticket,
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
        return Colors.amber;
      case TicketPriority.low:
        return Colors.lightBlueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowText("Serial No.", widget.ticket.serial, "Issued By",
              widget.ticket.issuedBy),
          const SizedBox(height: 12),
          const Text("Title", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(widget.ticket.title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priorityChip(),
              _columnText("Category", widget.ticket.category),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Assigned to", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children:
                widget.ticket.assignedUsers.map((e) => _avatar(e)).toList(),
          ),
          const SizedBox(height: 12),
          const Text("Created At", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(widget.ticket.createdAt),
          const Divider(height: 32),
          Row(
            children: [
              _actionButton(
                "Change Status",
                () => _openStatusBottomSheet(context),
              ),
              const SizedBox(width: 10),
              _actionButton(
                "Set Priority",
                () => _openPriorityBottomSheet(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TicketDetailsPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("View",
                      style: TextStyle(color: Colors.white)),
                ),
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
      content: Column(
        children: TicketStatus.values
            .map((status) => _radioTile<TicketStatus>(
                  status.displayName,
                  status,
                  tempSelection,
                  (v) => setState(() => tempSelection = v),
                ))
            .toList(),
      ),
      buttonText: "Update Status",
      onConfirm: () => setState(() => _selectedStatus = tempSelection),
    );
  }

  void _openPriorityBottomSheet(BuildContext context) {
    TicketPriority tempSelection = _selectedPriority;
    _showSheet(
      context: context,
      title: "Set Ticket Priority",
      content: Column(
        children: TicketPriority.values
            .map((priority) => _radioTile<TicketPriority>(
                  priority.displayName,
                  priority,
                  tempSelection,
                  (v) => setState(() => tempSelection = v),
                ))
            .toList(),
      ),
      buttonText: "Update Priority",
      onConfirm: () => setState(() => _selectedPriority = tempSelection),
    );
  }

  // -------------------- HELPERS --------------------

  void _showSheet({
    required BuildContext context,
    required String title,
    required Widget content,
    required String buttonText,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2A3A),
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _radioTile<T>(
      String text, T value, T groupValue, ValueChanged<T> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF243447),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: (v) => onChanged(v as T),
        title: Text(text),
        activeColor: Colors.blue,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _rowText(String l1, String v1, String l2, String v2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_columnText(l1, v1), _columnText(l2, v2)],
    );
  }

  Widget _columnText(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value),
    ]);
  }

  Widget _priorityChip() {
    final color = _getPriorityColor(_selectedPriority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_selectedPriority.displayName,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _avatar(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withAlpha(55),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
