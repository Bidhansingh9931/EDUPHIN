import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class MyRegisteredEventsPage extends StatefulWidget {
  const MyRegisteredEventsPage({super.key});

  @override
  State<MyRegisteredEventsPage> createState() =>
      _MyRegisteredEventsPageState();
}

class _MyRegisteredEventsPageState extends State<MyRegisteredEventsPage> {
  String statusValue = "All";
  String typeValue = "All";
  List<dynamic> _registeredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() => _isLoading = true);
    try {
      String? apiStatus;
      if (statusValue == "Active") apiStatus = "upcoming";
      if (statusValue == "Completed") apiStatus = "expired";
      if (statusValue == "Cancelled") apiStatus = "cancelled";

      String? apiType;
      if (typeValue == "Paid") apiType = "paid";
      if (typeValue == "Free") apiType = "free";

      final data = await ApiService.getStudentRegisteredEvents(
        status: apiStatus,
        type: apiType,
      );
      setState(() {
        _registeredEvents = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching registered events: $e")),
        );
      }
    }
  }

  Future<void> _cancelRegistration(dynamic registration) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff3d4466),
        title: const Text("Cancel Registration", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to cancel your registration for this event?", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Reason (Optional)",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // The API expects the register_id (which it decrypts)
        // Usually, the API should return a hash if it expects one back.
        // We'll use registration['id_hash'] if available, otherwise just id.
        final String registrationId = registration['id_hash'] ?? registration['id'].toString();
        await ApiService.cancelStudentEventRegistration(
          registrationId,
          reason: reasonController.text.isEmpty ? null : reasonController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration cancelled successfully")),
          );
          _fetchRegisteredEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b0f2a),
      appBar: AppBar(
        backgroundColor: const Color(0xff3d4466),
        title: const Row(
          children: [
            Icon(Icons.event_available, color: Colors.white),
            SizedBox(width: 10),
            Text("My Registered Events",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔵 FILTER CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff3d4466),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Filter Events",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text("Status",
                      style:
                      TextStyle(color: Colors.white, fontSize: 16)),

                  const SizedBox(height: 8),

                  _buildDropdown(statusValue, ["All", "Active", "Completed", "Cancelled"], (val) {
                    setState(() => statusValue = val!);
                    _fetchRegisteredEvents();
                  }),

                  const SizedBox(height: 20),

                  const Text("Type",
                      style:
                      TextStyle(color: Colors.white, fontSize: 16)),

                  const SizedBox(height: 8),

                  _buildDropdown(typeValue, ["All", "Paid", "Free"], (val) {
                    setState(() => typeValue = val!);
                    _fetchRegisteredEvents();
                  }),

                  const SizedBox(height: 25),

                  /// 🔵 RESET BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4866d8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          statusValue = "All";
                          typeValue = "All";
                        });
                        _fetchRegisteredEvents();
                      },
                      child: const Text("RESET",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔵 TABLE
            _isLoading
            ? const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.white),
            ))
            : _registeredEvents.isEmpty
              ? const Center(child: Text("No registered events found", style: TextStyle(color: Colors.white70)))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _registeredEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final registration = _registeredEvents[index];
                    final event = registration['event'];
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff3d4466),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          /// Header Row
                          _tableHeader(index + 1),
                          const Divider(color: Colors.white24, height: 1),
                          /// Data Row
                          _tableRow(registration, event),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  /// 🔹 DROPDOWN
  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xff5a6670),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xff3d4466),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// 🔹 TABLE HEADER
  Widget _tableHeader(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("# $index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text("Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text("Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 🔹 TABLE ROW
  Widget _tableRow(dynamic registration, dynamic event) {
    if (event == null) return const SizedBox.shrink();

    final eventDateStr = event['event_date'];
    final startTime = event['start_time'] ?? '';
    final endTime = event['end_time'] ?? '';
    final registeredAtStr = registration['registered_at'];

    String formattedEventDate = eventDateStr ?? 'N/A';
    if (eventDateStr != null) {
      try {
        DateTime dt = DateTime.parse(eventDateStr);
        formattedEventDate = DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    String formattedRegDate = registeredAtStr ?? 'N/A';
    if (registeredAtStr != null) {
      try {
        DateTime dt = DateTime.parse(registeredAtStr);
        formattedRegDate = DateFormat('dd MMM yyyy\nhh:mm a').format(dt);
      } catch (_) {}
    }

    final isCancelled = registration['status'] == 'cancelled';
    final eventDate = eventDateStr != null ? DateTime.tryParse(eventDateStr) : null;
    final isExpired = eventDate != null && eventDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                  flex: 1,
                  child: Text("", style: TextStyle(color: Colors.white))), // Space for index
              Expanded(
                  flex: 1,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: event['image'] != null
                        ? Image.network(
                            "${ApiService.baseUrl}/${event['image']}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.white70),
                          )
                        : const Icon(Icons.image, color: Colors.white70),
                  )),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['title'] ?? 'N/A',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                        event['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24),

          /// 🔵 DETAILS ROW (BOTTOM PART)
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$formattedEventDate\n$startTime - $endTime",
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),

              Expanded(
                child: Text(event['venue'] ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xff5a6670),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text((event['is_ticketed'] == 1 || event['is_ticketed'] == true) ? "Paid Event" : "Free Event",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),

              Expanded(
                child: Text(formattedRegDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),

              const SizedBox(width: 8),

              isCancelled
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("CANCELLED",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                )
              : isExpired
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("EXPIRED",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
                  )
                : GestureDetector(
                    onTap: () => _cancelRegistration(registration),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xff5a6670),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text("CANCEL\nREGISTRATION",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
            ],
          )
        ],
      ),
    );
  }
}
