import 'package:eduphin/manager_dashboard/recentSupportTickets/ticket_details.dart';
import 'package:flutter/material.dart';

enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { high, medium, low }

class TicketInfoPage extends StatefulWidget {
  const TicketInfoPage({super.key});

  @override
  State<TicketInfoPage> createState() => _TicketInfoPageState();
}

class _TicketInfoPageState extends State<TicketInfoPage> {
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        children: const [
          TicketCard(
            serial: "#001245",
            issuedBy: "Ananya Sharma",
            title: "Wi-Fi Connectivity Issue in Library",
            priority: "High",
            priorityColor: Colors.redAccent,
            category: "IT Support",
            assignedUsers: ["RK", "SM", "PV"],
            createdAt: "24 Nov 2025, 10:30 AM",
          ),
          SizedBox(height: 16),
          TicketCard(
            serial: "#001244",
            issuedBy: "Rohan Verma",
            title: "Projector Malfunction in Room 301",
            priority: "Medium",
            priorityColor: Colors.amber,
            category: "Classroom AV",
            assignedUsers: ["RK"],
            createdAt: "23 Nov 2025, 02:15 PM",
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatefulWidget {
  final String serial;
  final String issuedBy;
  final String title;
  final String priority;
  final Color priorityColor;
  final String category;
  final List<String> assignedUsers;
  final String createdAt;

  const TicketCard({
    super.key,
    required this.serial,
    required this.issuedBy,
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.category,
    required this.assignedUsers,
    required this.createdAt,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  TicketStatus _selectedStatus = TicketStatus.open;
  TicketPriority _selectedPriority = TicketPriority.medium;
  // int _assignedUserIndex = 0;

  final List<Map<String, String>> users = [
    {"name": "Rajesh Kumar", "role": "IT Department", "initial": "RK"},
    {"name": "Sunita Mishra", "role": "IT Support", "initial": "SM"},
    {"name": "Prakash Verma", "role": "Hardware Specialist", "initial": "PV"},
    {"name": "Anita Desai", "role": "Accounts", "initial": "AD"},
    {"name": "Manoj Kumar", "role": "Manager", "initial": "MK"},
    {"name": "Sonia Gupta", "role": "Administration", "initial": "SG"},
  ];

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
          _rowText("Serial No.", widget.serial, "Issued By", widget.issuedBy),
          const SizedBox(height: 12),

          const Text("Title", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(widget.title, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priorityChip(),
              _columnText("Category", widget.category),
            ],
          ),

          const SizedBox(height: 12),

          const Text("Assigned to", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: widget.assignedUsers.map((e) => _avatar(e)).toList(),
          ),

          const SizedBox(height: 12),

          const Text("Created At", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(widget.createdAt),

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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TicketDetailsPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("View",style: TextStyle(color: Colors.white),),
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

    _showSheet(
      context,
      "Change Ticket Status",
      [
        _statusTile("Open", TicketStatus.open),
        _statusTile("In-Progress", TicketStatus.inProgress),
        _statusTile("Resolved", TicketStatus.resolved),
        _statusTile("Closed", TicketStatus.closed),
      ],
      "Update Status",
    );
  }

  void _openPriorityBottomSheet(BuildContext context) {
    _showSheet(
      context,
      "Set Ticket Priority",
      [
        _priorityTile("High", TicketPriority.high),
        _priorityTile("Medium", TicketPriority.medium),
        _priorityTile("Low", TicketPriority.low),
      ],
      "Update Priority",
    );
  }

  // void _openAssignBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF1C2A3A),
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (_) => StatefulBuilder(
  //       builder: (BuildContext context, StateSetter setModalState) {
  //         return Padding(
  //           padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const Text("Assign Ticket To",
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
  //               const SizedBox(height: 16),
  //               Flexible(
  //                 child: ListView.builder(
  //                   itemCount: users.length,
  //                   shrinkWrap: true,
  //                   itemBuilder: (context, i) {
  //                     final user = users[i];
  //                     return Container(
  //                       margin: const EdgeInsets.only(bottom: 10),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFF243447),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: ListTile(
  //                         leading: CircleAvatar(
  //                           backgroundColor: Colors.blueAccent,
  //                           child: Text(user["initial"]!),
  //                         ),
  //                         title: Text(user["name"]!),
  //                         subtitle: Text(user["role"]!,
  //                             style: const TextStyle(color: Colors.grey)),
  //                         trailing: Radio<int>(
  //                           value: i,
  //                           groupValue: _assignedUserIndex,
  //                           onChanged: (v) => setModalState(() => _assignedUserIndex = v!),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               Row(
  //                 children: [
  //                   Expanded(child: _secondaryButton("Cancel")),
  //                   const SizedBox(width: 12),
  //                   Expanded(child: _primaryButton("Confirm Assignment")),
  //                 ],
  //               )
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // -------------------- HELPERS --------------------

  void _showSheet(
      BuildContext context, String title, List<Widget> tiles, String buttonText) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2A3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...tiles,
          const SizedBox(height: 20),
          _primaryButton(buttonText),
        ]),
      ),
    );
  }

  Widget _statusTile(String text, TicketStatus value) {
    return _radioTile(
      text,
      value,
      _selectedStatus,
          (v) => setState(() => _selectedStatus = v),
    );
  }

  Widget _priorityTile(String text, TicketPriority value) {
    return _radioTile(
      text,
      value,
      _selectedPriority,
          (v) => setState(() => _selectedPriority = v),
    );
  }

  Widget _radioTile<T>(
      String text, T value, T group, ValueChanged<T> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF243447),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<T>(
        value: value,
        groupValue: group,
        onChanged: (v) => onChanged(v as T),
        title: Text(text),
        activeColor: Colors.blue,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.priorityColor.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(widget.priority,
          style: TextStyle(
              color: widget.priorityColor, fontWeight: FontWeight.w600)),
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
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _primaryButton(String text) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _secondaryButton(String text) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A3B4F),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

