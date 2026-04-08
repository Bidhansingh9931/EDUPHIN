import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';
import 'create_ticket.dart';
import 'ticket_details.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart' show SupportTicket;

class StaffSupportTicketsPage extends StatefulWidget {
  const StaffSupportTicketsPage({super.key});

  @override
  State<StaffSupportTicketsPage> createState() => _StaffSupportTicketsPageState();
}

class _StaffSupportTicketsPageState extends State<StaffSupportTicketsPage> {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);

  late Future<List<SupportTicket>> _ticketsFuture;
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
      _ticketsFuture = ApiService.getStaffTickets({
        'title': _searchController.text.trim(),
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Support Tickets", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTickets(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildFilters(),
              const SizedBox(height: 24),
              Expanded(child: _buildTicketList()),
              const SizedBox(height: 20),
              _buildCreateTicketButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search by Title...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _loadTickets(),
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown("Priority", _selectedPriority, ["all", "low", "medium", "high"], (val) {
            setState(() => _selectedPriority = val!);
            _loadTickets();
          }),
          const SizedBox(height: 12),
          _buildFilterDropdown("Status", _selectedStatus, ["all", "open", "closed"], (val) {
            setState(() => _selectedStatus = val!);
            _loadTickets();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text("#ID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text("Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text("Priority", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: FutureBuilder<List<SupportTicket>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No tickets found", style: TextStyle(color: Colors.white38)));
                }

                final tickets = snapshot.data!;
                return ListView.separated(
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return ListTile(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailsPage(ticketId: ticket.id.toString())));
                        _loadTickets();
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: SizedBox(width: 40, child: Text(ticket.id.toString(), style: const TextStyle(color: Colors.white70, fontSize: 14))),
                      title: Text(ticket.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ticket.priority.toLowerCase() == "high" ? Colors.red.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket.priority.toUpperCase(),
                          style: TextStyle(
                            color: ticket.priority.toLowerCase() == "high" ? Colors.redAccent : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTicketButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffCreateTicketPage()));
          _loadTickets();
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("CREATE NEW TICKET", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
