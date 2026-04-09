import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key});

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  String _statusValue = "All";
  String _typeValue = "All";
  List<dynamic> _registeredEvents = [];
  bool _isLoading = true;

  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _headerRow = const Color(0xff2A3450);

  @override
  void initState() {
    super.initState();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() => _isLoading = true);
    try {
      String? apiStatus;
      if (_statusValue == "Active") apiStatus = "upcoming";
      if (_statusValue == "Completed") apiStatus = "expired";
      if (_statusValue == "Cancelled") apiStatus = "cancelled";

      String? apiType;
      if (_typeValue == "Paid") apiType = "paid";
      if (_typeValue == "Free") apiType = "free";

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
          SnackBar(
            content: Text("Error fetching registered events: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _cancelRegistration(dynamic registration) async {
    final TextEditingController reasonController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel Registration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to cancel your registration for this event?", 
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Reason (Optional)",
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: _bg.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("NO, KEEP IT", style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("YES, CANCEL"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final String registrationId = registration['id_hash']?.toString() ?? registration['id'].toString();
        await ApiService.cancelStudentEventRegistration(
          registrationId,
          reason: reasonController.text.isEmpty ? null : reasonController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration cancelled successfully"),
              backgroundColor: Colors.green,
            ),
          );
          _fetchRegisteredEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cancellation failed: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
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
          "My Registered Events",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRegisteredEvents,
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
                    "Participations",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_registeredEvents.length} registrations",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? Center(child: Padding(padding: const EdgeInsets.all(40.0), child: CircularProgressIndicator(color: _primary)))
                  : _registeredEvents.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _registeredEvents.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildRegistrationCard(_registeredEvents[index]),
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
              const Text("Filter History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Status", 
                  _statusValue, 
                  ["All", "Active", "Completed", "Cancelled"], 
                  (val) => setState(() => _statusValue = val!)
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  "Type", 
                  _typeValue, 
                  ["All", "Paid", "Free"], 
                  (val) => setState(() => _typeValue = val!)
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
                      _statusValue = "All";
                      _typeValue = "All";
                    });
                    _fetchRegisteredEvents();
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
                  onPressed: _fetchRegisteredEvents,
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
              value: value,
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

  Widget _buildRegistrationCard(dynamic registration) {
    final event = registration['event'];
    if (event == null) return const SizedBox.shrink();

    final eventDateStr = event['event_date'];
    String formattedDate = "N/A";
    if (eventDateStr != null) {
      try {
        DateTime dt = DateTime.parse(eventDateStr);
        formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    final String status = registration['status']?.toString().toUpperCase() ?? 'PENDING';
    final bool isCancelled = status == 'CANCELLED';
    final eventDate = eventDateStr != null ? DateTime.tryParse(eventDateStr) : null;
    final bool isExpired = eventDate != null && eventDate.isBefore(DateTime.now());

    Color statusColor = Colors.greenAccent;
    if (isCancelled) statusColor = Colors.redAccent;
    else if (isExpired) statusColor = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 60,
                    width: 60,
                    color: _headerRow,
                    child: event['image'] != null
                        ? Image.network(
                            "${ApiService.baseUrl}/${event['image']}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.event_available, color: _primary, size: 24),
                          )
                        : Icon(Icons.event_available, color: _primary, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Untitled Event',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['venue'] ?? 'TBA',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoDetail(Icons.calendar_today, "Event Date", "$formattedDate at ${event['start_time'] ?? 'N/A'}"),
                const SizedBox(height: 12),
                _buildInfoDetail(Icons.how_to_reg, "Registered On", _formatRegDate(registration['registered_at'])),
                const SizedBox(height: 20),
                if (!isCancelled && !isExpired)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRegistration(registration),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text("CANCEL REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _primary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatRegDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text("No registration history", style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Events you join will appear here", style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
