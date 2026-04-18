import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
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
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List registrationsData = data['data'] ?? data['registered_events'] ?? [];
          _registrations = registrationsData.map((e) => EventRegistration.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = ApiService.errorMessage(response, "Failed to load registered events");
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelRegistration(int registrationId) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text("NO")),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
        if (!mounted) return;
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration cancelled successfully")));
          _fetchRegisteredEvents();
        } else {
          final error = jsonDecode(response.body)['message'] ?? "Cancellation failed";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = context.theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Registered Events"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRegisteredEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(_errorMessage!,
                        style: TextStyle(
                            color: _colorScheme.error, fontSize: context.font(14))))
                : _registrations.isEmpty
                    ? Center(
                        child: Text("No registered events found",
                            style: TextStyle(fontSize: context.font(14))))
                    : ListView.builder(
                        padding: context.pagePadding,
                        itemCount: _registrations.length,
                        itemBuilder: (context, index) {
                          final reg = _registrations[index];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: _buildEventCard(reg),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildEventCard(EventRegistration reg) {
    final event = reg.event;
    final isCancelled = reg.status == 'cancelled';

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing),
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(
          color: context.theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.scale(60),
                  height: context.scale(60),
                  decoration: BoxDecoration(
                    color: _colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                  child: Icon(Icons.event_note_rounded,
                      color: _colorScheme.primary, size: context.scale(24)),
                ),
                SizedBox(width: context.spacing / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: TextStyle(
                              fontSize: context.font(16), fontWeight: FontWeight.bold)),
                      SizedBox(height: context.spacing / 4),
                      Text(event.description ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: _colorScheme.onSurfaceVariant,
                              fontSize: context.font(13))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing / 2),
            const Divider(),
            SizedBox(height: context.spacing / 2),
            _buildInfoRow(Icons.calendar_today_rounded,
                "${event.eventDate} • ${event.startTime} - ${event.endTime}"),
            SizedBox(height: context.spacing / 4),
            _buildInfoRow(Icons.location_on_outlined, event.venue ?? "N/A"),
            SizedBox(height: context.spacing / 4),
            _buildInfoRow(
              Icons.info_outline_rounded,
              reg.status.toUpperCase(),
              color: isCancelled ? Colors.red : Colors.green,
            ),
            SizedBox(height: context.spacing / 2),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.spacing / 2),
              decoration: BoxDecoration(
                color: _colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(context.scale(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Registered on:",
                      style: TextStyle(
                          color: _colorScheme.onSurfaceVariant,
                          fontSize: context.font(11))),
                  Text(reg.registeredAt ?? "-",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: context.font(13))),
                ],
              ),
            ),
            if (!isCancelled) ...[
              SizedBox(height: context.spacing / 2),
              SizedBox(
                width: double.infinity,
                height: context.scale(44),
                child: FilledButton(
                  onPressed: () => _cancelRegistration(reg.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: _colorScheme.secondaryContainer,
                    foregroundColor: _colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(8))),
                  ),
                  child: Text("CANCEL REGISTRATION",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: context.font(12))),
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
        Icon(icon, size: context.scale(16), color: color ?? _colorScheme.onSurfaceVariant),
        SizedBox(width: context.scale(10)),
        Expanded(child: Text(text, style: TextStyle(fontSize: context.font(13), color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal))),
      ],
    );
  }
}
