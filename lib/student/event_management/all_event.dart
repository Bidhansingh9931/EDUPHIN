import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {

  String? status;
  String? type;
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      String? apiStatus;
      if (status == "Upcoming") apiStatus = "upcoming";
      if (status == "Completed") apiStatus = "expired";

      String? apiType;
      if (type == "Paid") apiType = "paid";
      if (type == "Free") apiType = "free";

      final data = await ApiService.getStudentAllEvents(
        status: apiStatus,
        type: apiType,
      );
      setState(() {
        _events = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching events: $e")),
        );
      }
    }
  }

  Future<void> _registerForEvent(dynamic event) async {
    final bool isTicketed = event['is_ticketed'] == 1 || event['is_ticketed'] == true;
    
    if (isTicketed) {
      final TextEditingController paymentController = TextEditingController();
      final String? paymentId = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF3B4668),
          title: const Text("Paid Event", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ticket Price: ₹${event['ticket_price']}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 15),
              TextField(
                controller: paymentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Payment ID",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () => Navigator.pop(context, paymentController.text),
              child: const Text("Register"),
            ),
          ],
        ),
      );
      
      if (paymentId == null || paymentId.isEmpty) return;
      
      _apiRegister(event['id'], paymentId);
    } else {
      _apiRegister(event['id'], null);
    }
  }

  Future<void> _apiRegister(int eventId, String? paymentId) async {
    try {
      await ApiService.registerForStudentEvent(eventId, paymentId: paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully!")),
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E3A59),
        elevation: 0,
        title: const Text("Manage Events",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// FILTER CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3B4668),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  buildDropdown("Filter by Status", "All Events", status,
                      ["All Events", "Upcoming", "Completed"], (val) {
                        setState(() => status = val);
                      }),

                  const SizedBox(height: 20),

                  buildDropdown("Filter by Category", "All Categories", type,
                      ["All Categories", "Paid", "Free"], (val) {
                        setState(() => type = val);
                      }),

                  const SizedBox(height: 25),

                  /// APPLY BUTTON (same size)
                  buildMainButton("APPLY FILTERS",
                      const Color(0xFF3D63A8), () {
                        _fetchEvents();
                      }),

                  const SizedBox(height: 15),

                  /// RESET BUTTON (same size)
                  buildMainButton("RESET FILTERS",
                      const Color(0xFF5E6A75), () {
                        setState(() {
                          status = null;
                          type = null;
                        });
                        _fetchEvents();
                      }),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// SLIDE TABLE
            _isLoading 
            ? const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.white),
            ))
            : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF3B4668)),
                dataRowColor: WidgetStateProperty.all(
                    const Color(0xFF3B4668)),
                columnSpacing: 40,
                columns: [
                  DataColumn(label: whiteText("#")),
                  DataColumn(label: whiteText("Event Name")),
                  DataColumn(label: whiteText("Date & Time")),
                  DataColumn(label: whiteText("Venue")),
                  DataColumn(label: whiteText("Ticket Info")),
                  DataColumn(label: whiteText("Action")),
                ],
                rows: _events.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final eventDate = event['event_date'] != null ? DateTime.tryParse(event['event_date']) : null;
                  final dateStr = eventDate != null ? DateFormat('dd MMM yyyy').format(eventDate) : (event['event_date'] ?? '');
                  final timeStr = "${event['start_time'] ?? ''} - ${event['end_time'] ?? ''}";
                  final ticketInfo = (event['is_ticketed'] == 1 || event['is_ticketed'] == true)
                      ? "Price ₹${event['ticket_price']}\nSeats ${event['max_participants'] ?? 'N/A'}"
                      : "Free Event\nSeats ${event['max_participants'] ?? 'N/A'}";

                  bool isEnded = false;
                  if (eventDate != null) {
                    isEnded = eventDate.isBefore(DateTime.now());
                  }

                  return buildRow(
                    (index + 1).toString(),
                    event['title'] ?? '',
                    "$dateStr\n$timeStr",
                    event['venue'] ?? '',
                    ticketInfo,
                    isEnded ? "Ended" : "Register",
                    onTap: isEnded ? null : () => _registerForEvent(event),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- REUSABLE WIDGETS ----------

  Widget buildDropdown(String label, String hint, String? value,
      List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF5E6A75),
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF5E6A75),
              hint: Text(hint,
                  style: const TextStyle(color: Colors.white70)),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white),
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style:
                      const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMainButton(
      String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50, // SAME SIZE
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  static DataRow buildRow(
      String id,
      String name,
      String date,
      String venue,
      String ticket,
      String status,
      {VoidCallback? onTap}) {
    return DataRow(cells: [
      DataCell(whiteText(id)),
      DataCell(whiteText(name)),
      DataCell(whiteText(date)),
      DataCell(whiteText(venue)),
      DataCell(whiteText(ticket)),
      DataCell(GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: status == "Ended"
                ? Colors.red
                : Colors.green,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(status,
              style: const TextStyle(color: Colors.white)),
        ),
      )),
    ]);
  }

  static Widget whiteText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
