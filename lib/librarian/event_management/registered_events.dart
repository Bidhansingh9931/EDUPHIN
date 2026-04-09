import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart' as librarian_model;

class MyRegisteredEventsPage extends StatefulWidget {
  const MyRegisteredEventsPage({super.key});

  @override
  State<MyRegisteredEventsPage> createState() => _MyRegisteredEventsPageState();
}

class _MyRegisteredEventsPageState extends State<MyRegisteredEventsPage> {
  static const Color bgColor = Color(0xFF0B0D18);
  static const Color cardColor = Color(0xFF1B2238);
  static const Color fieldColor = Color(0xFF323B5C);
  static const Color blueBtn = Color(0xFF2563EB);

  String selectedStatus = "All";
  String selectedType = "All";
  bool _isLoading = true;
  List<librarian_model.EventRegistration> _registeredRegistrations = [];

  @override
  void initState() {
    super.initState();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() => _isLoading = true);
    try {
      final registrations = await ApiService.getLibrarianRegisteredEvents();
      if (!mounted) return;
      setState(() {
        _registeredRegistrations = List<librarian_model.EventRegistration>.from(registrations);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching events: $e")));
    }
  }

  List<librarian_model.EventRegistration> get _filteredRegistrations {
    return _registeredRegistrations.where((reg) {
      final event = reg.event;
      bool matchesStatus = true;
      if (selectedStatus != "All") {
        DateTime? eventDate;
        if (event.eventDate != null) {
          eventDate = DateTime.tryParse(event.eventDate!);
        }
        if (eventDate != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
          
          if (selectedStatus == "Upcoming") {
            matchesStatus = eventDay.isAfter(today) || eventDay.isAtSameMomentAs(today);
          } else if (selectedStatus == "Completed") {
            matchesStatus = eventDay.isBefore(today);
          }
        }
      }

      bool matchesType = true;
      if (selectedType != "All") {
        if (selectedType == "Free") {
          matchesType = !event.isTicketed;
        } else if (selectedType == "Paid") {
          matchesType = event.isTicketed;
        }
      }

      return matchesStatus && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRegistrations;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Registered Events",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: blueBtn))
          : RefreshIndicator(
              onRefresh: _fetchRegisteredEvents,
              color: blueBtn,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    /// FILTER SECTION
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_alt, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text("Filter Events",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildLabel("Status"),
                          buildDropdownField(selectedStatus, ["All", "Upcoming", "Completed"], (val) {
                            setState(() => selectedStatus = val!);
                          }),
                          const SizedBox(height: 12),
                          buildLabel("Type"),
                          buildDropdownField(selectedType, ["All", "Free", "Paid"], (val) {
                            setState(() => selectedType = val!);
                          }),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedStatus = "All";
                                  selectedType = "All";
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueBtn,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("RESET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DATA TABLE SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: filtered.isEmpty
                          ? const Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text("No registered events found", style: TextStyle(color: Colors.white38)),
                            ))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFF2D3748)),
                                columnSpacing: 25,
                                dataRowMinHeight: 60,
                                dataRowMaxHeight: 80,
                                columns: const [
                                  DataColumn(label: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Date & Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Venue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Ticket Info", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                ],
                                rows: filtered.asMap().entries.map((entry) {
                                  int index = entry.key + 1;
                                  librarian_model.EventRegistration registration = entry.value;
                                  return buildDataRow(
                                    index.toString(),
                                    registration,
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget buildDropdownField(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: fieldColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  DataRow buildDataRow(String hash, librarian_model.EventRegistration registration) {
    final event = registration.event;
    return DataRow(cells: [
      DataCell(Text(hash, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      DataCell(
        event.image != null
            ? Image.network("${ApiService.baseImageUrl}/storage/${event.image}", width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.white24))
            : const Icon(Icons.image, color: Colors.white24, size: 30),
      ),
      DataCell(SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(event.title, 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            if (event.description != null)
              Text(event.description!, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      )),
      DataCell(Text("${event.eventDate ?? ''}\n${event.startTime ?? ''} - ${event.endTime ?? ''}", style: const TextStyle(color: Colors.white70, fontSize: 11))),
      DataCell(Text(event.venue ?? "N/A", style: const TextStyle(color: Colors.white70, fontSize: 11))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
        child: Text(event.isTicketed ? "Paid: ${event.ticketPrice}" : "Free Event", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      )),
      DataCell(ElevatedButton(
        onPressed: registration.status == 'cancelled' ? null : () async {
          try {
            await ApiService.cancelLibrarianEventRegistration(registration.id.toString());
            if (!mounted) return;
            _fetchRegisteredEvents();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration cancelled")));
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: registration.status == 'cancelled' ? Colors.grey : const Color(0xFF374151),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(registration.status == 'cancelled' ? "CANCELLED" : "CANCEL\nREGISTRATION",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
      )),
    ]);
  }
}
