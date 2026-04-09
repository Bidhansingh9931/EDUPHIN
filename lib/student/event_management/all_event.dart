import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  String? _status;
  String? _type;
  List<dynamic> _events = [];
  bool _isLoading = true;

  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _headerRow = const Color(0xff2A3450);

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      String? apiStatus;
      if (_status == "Upcoming") apiStatus = "upcoming";
      if (_status == "Completed") apiStatus = "expired";

      String? apiType;
      if (_type == "Paid") apiType = "paid";
      if (_type == "Free") apiType = "free";

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
          SnackBar(
            content: Text("Error fetching events: $e"),
            backgroundColor: Colors.redAccent,
          ),
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
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Register for Paid Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ticket Price: ₹${event['ticket_price']}", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text("Please enter your Payment ID / Transaction Ref to proceed.", 
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: paymentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Payment ID",
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: _bg.withValues(alpha: 0.5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("CANCEL", style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, paymentController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("REGISTER"),
            ),
          ],
        ),
      );
      
      if (paymentId != null && paymentId.isNotEmpty) {
        _apiRegister(event['id'], paymentId);
      }
    } else {
      _apiRegister(event['id'], null);
    }
  }

  Future<void> _apiRegister(int eventId, String? paymentId) async {
    try {
      await ApiService.registerForStudentEvent(eventId, paymentId: paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for event!"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Explore Events",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        color: _primary,
        backgroundColor: _card,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Available Events",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_events.length} found",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading 
                  ? Center(child: Padding(padding: const EdgeInsets.all(40.0), child: CircularProgressIndicator(color: _primary)))
                  : _events.isEmpty 
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _events.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildEventCard(_events[index]),
                        ),
              const SizedBox(height: 32),
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
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: _primary, size: 20),
              const SizedBox(width: 10),
              const Text("Filter Events", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Status", 
                  _status ?? "All Events", 
                  ["All Events", "Upcoming", "Completed"], 
                  (val) => setState(() => _status = val == "All Events" ? null : val)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  "Type", 
                  _type ?? "All Types", 
                  ["All Types", "Paid", "Free"], 
                  (val) => setState(() => _type = val == "All Types" ? null : val)
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _status = null;
                      _type = null;
                    });
                    _fetchEvents();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("RESET"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _fetchEvents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _bg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: _card,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(dynamic event) {
    final eventDateStr = event['event_date'];
    String formattedDate = "N/A";
    if (eventDateStr != null) {
      try {
        DateTime dt = DateTime.parse(eventDateStr);
        formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    final bool isPaid = event['is_ticketed'] == 1 || event['is_ticketed'] == true;
    final String price = isPaid ? "₹${event['ticket_price']}" : "FREE";

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: _headerRow,
                  child: event['image'] != null
                      ? Image.network(
                          "${ApiService.baseUrl}/${event['image']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.event_note, color: _primary.withValues(alpha: 0.2), size: 64),
                        )
                      : Icon(Icons.event_note, color: _primary.withValues(alpha: 0.2), size: 64),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.orangeAccent : Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Untitled Event',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: _primary),
                    const SizedBox(width: 6),
                    Text(formattedDate, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: _primary),
                    const SizedBox(width: 6),
                    Text(event['start_time'] ?? 'N/A', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: _primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event['venue'] ?? 'TBA',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  event['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _registerForEvent(event),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("REGISTER NOW", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text("No events found", style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Try adjusting your filters", style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
