import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class MyRegisteredEventsPage extends StatefulWidget {
  const MyRegisteredEventsPage({super.key});

  @override
  State<MyRegisteredEventsPage> createState() =>
      _MyRegisteredEventsPageState();
}

class _MyRegisteredEventsPageState extends State<MyRegisteredEventsPage> {
  late ColorScheme _colorScheme;
  bool _isLoading = true;
  List<EventRegistration> _registrations = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/events/registered');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List registrationsData = data['data'] ?? [];
          _registrations = registrationsData.map((e) => EventRegistration.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load registered events";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelRegistration(int registrationId) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Registration"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Are you sure you want to cancel this registration?"),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Reason for cancellation",
                hintText: "Optional",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("NO")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("YES, CANCEL"),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final response = await ApiService.post('counselor/events/cancel/$registrationId', {
          'reason_for_cancel': controller.text,
        });
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration cancelled successfully")));
            _fetchRegisteredEvents();
          }
        } else {
          final error = jsonDecode(response.body)['message'] ?? "Cancellation failed";
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Registered Events"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRegisteredEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: _colorScheme.error)))
                : _registrations.isEmpty
                    ? const Center(child: Text("No registered events found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _registrations.length,
                        itemBuilder: (context, index) {
                          final reg = _registrations[index];
                          return _buildEventCard(reg);
                        },
                      ),
      ),
    );
  }

  Widget _buildEventCard(EventRegistration reg) {
    final event = reg.event;
    final isCancelled = reg.status == 'cancelled';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event_note_rounded, color: _colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(event.description ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today_rounded, "${event.eventDate} • ${event.startTime} - ${event.endTime}"),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on_outlined, event.venue ?? "N/A"),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.info_outline_rounded,
              reg.status.toUpperCase(),
              color: isCancelled ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registered on:", style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 11)),
                  Text(reg.registeredAt ?? "-", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => _cancelRegistration(reg.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: _colorScheme.errorContainer,
                    foregroundColor: _colorScheme.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CANCEL REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? _colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal))),
      ],
    );
  }
}
