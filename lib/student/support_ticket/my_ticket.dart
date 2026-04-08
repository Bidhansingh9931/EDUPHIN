import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/student/support_ticket/create_tickets.dart';
import 'package:eduphin/student/support_ticket/ticket_details.dart';
import 'package:intl/intl.dart';

class yoursupportticket extends StatelessWidget {
  const yoursupportticket({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportTicketsPage();
  }
}

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  final Color bgColor = const Color(0xFF0B1026);
  final Color cardColor = const Color(0xFF2F3757);
  final Color fieldColor = const Color(0xFF4A5568);
  final Color badgeColor = const Color(0xFF5F6B7A);
  final Color buttonBlue = const Color(0xFF3F5BD9);

  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedPriority = "all";
  String _selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final filters = {
        'search': _searchQuery,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };
      final tickets = await ApiService.getStudentTickets(filters);
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching tickets: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.access_time, color: Colors.white70),
                  SizedBox(width: 12),
                  Text(
                    "Your Support Tickets",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// FILTER CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _inputField("Search by Title...", fieldColor),
                    const SizedBox(height: 20),
                    _dropdownField("Priority", _selectedPriority, ["all", "low", "medium", "high"], (val) {
                      setState(() => _selectedPriority = val!);
                      _fetchTickets();
                    }, fieldColor),
                    const SizedBox(height: 20),
                    _dropdownField("Status", _selectedStatus, ["all", "open", "closed"], (val) {
                      setState(() => _selectedStatus = val!);
                      _fetchTickets();
                    }, fieldColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TABLE SECTION (SCROLLABLE ROW)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tickets.isEmpty
                        ? const Center(child: Text("No tickets found", style: TextStyle(color: Colors.white)))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: 1000,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _tableHeader(),
                                    ..._tickets.map((ticket) => _tableRow(
                                          id: ticket.id.toString(),
                                          title: ticket.title,
                                          priority: ticket.priority,
                                          status: ticket.status,
                                          category: ticket.category ?? "-",
                                          assigned: ticket.assignedTo ?? "Unassigned",
                                          date: _formatDate(ticket.createdAt),
                                          badgeColor: badgeColor,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
              ),
            ),

            /// CREATE BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateSupportTicketPage()),
                    );
                    if (result == true) {
                      _fetchTickets();
                    }
                  },
                  icon: const Icon(Icons.add, size: 28, color: Colors.white,),
                  label: const Text(
                    "CREATE NEW TICKET",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  /// Input Field
  Widget _inputField(String hint, Color color) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.search, color: Colors.white70),
        ),
        onChanged: (val) {
          _searchQuery = val;
        },
        onSubmitted: (val) => _fetchTickets(),
      ),
    );
  }

  /// Dropdown Field
  Widget _dropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged, Color color) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: color,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                "${label}: ${item.toUpperCase()}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Table Header
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _headerText("#ID"),
          _headerText("Title"),
          _headerText("Priority"),
          _headerText("Status"),
          _headerText("Category"),
          _headerText("Assigned To"),
          _headerText("Created At"),
          _headerText("Action"),
        ],
      ),
    );
  }

  Widget _tableRow({
    required String id,
    required String title,
    required String priority,
    required String status,
    required String category,
    required String assigned,
    required String date,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _cellText(id),
          _cellText(title),
          _badge(priority, _getPriorityColor(priority)),
          _badge(status, _getStatusColor(status)),
          _cellText(category),
          _cellText(assigned),
          _cellText(date),
          _actionButton(id),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blueAccent;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _cellText(String text) {
    return SizedBox(
      width: 120,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      width: 120,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _actionButton(String id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5F6B7A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentTicketDetailsPage(ticketId: id),
          ),
        ).then((_) => _fetchTickets());
      },
      child: const Text("VIEW", style: TextStyle(color: Colors.white),),
    );
  }
}

class _headerText extends StatelessWidget {
  final String text;
  const _headerText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
