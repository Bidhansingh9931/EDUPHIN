import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class ExploreEventsPage extends StatefulWidget {
  const ExploreEventsPage({super.key});

  @override
  State<ExploreEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ExploreEventsPage> {
  late ColorScheme _colorScheme;
  String? status;
  String? type;

  bool _isLoading = true;
  List<Event> _events = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final queryParams = <String, String>{};
      if (status != null && status != "All Events") {
        queryParams['status'] = status!.toLowerCase();
      }
      if (type != null && type != "All Categories") {
        queryParams['type'] = type!.toLowerCase();
      }

      final response = await ApiService.get('counselor/events', queryParams);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List eventsData = data['events'] ?? data['data'] ?? [];
          _events = eventsData.map((e) => Event.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load events: ${response.statusCode}";
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

  Future<void> _registerForEvent(Event event) async {
    if (event.isTicketed) {
      _showPaymentIdDialog(event);
      return;
    }

    try {
      final response = await ApiService.post('counselor/events/register/${event.id}', {});
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 302) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully!")),
        );
        _fetchEvents();
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Registration failed";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showPaymentIdDialog(Event event) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Required"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("This is a paid event (Price: ${event.ticketPrice}). Please enter your Payment ID.",
                style: TextStyle(color: _colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Payment ID",
                hintText: "Enter Payment ID",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              try {
                final response = await ApiService.post('counselor/events/register/${event.id}', {
                  'payment_id': controller.text,
                });
                if (response.statusCode == 200 || response.statusCode == 302) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registered successfully!")));
                  _fetchEvents();
                } else {
                  final error = jsonDecode(response.body)['message'] ?? "Registration failed";
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("REGISTER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Events"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FILTER CARD
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Filters", style: _getSectionHeaderStyle()),
                      const SizedBox(height: 20),
                      buildDropdown("Status", status ?? "All Events", ["All Events", "Upcoming", "Expired"], (val) {
                        setState(() => status = val);
                      }),
                      const SizedBox(height: 20),
                      buildDropdown("Category", type ?? "All Categories", ["All Categories", "Paid", "Free"], (val) {
                        setState(() => type = val);
                      }),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _colorScheme.primary,
                                foregroundColor: _colorScheme.onPrimary,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _fetchEvents,
                              child: const Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                setState(() {
                                  status = "All Events";
                                  type = "All Categories";
                                });
                                _fetchEvents();
                              },
                              child: const Text("RESET", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text("Event List", style: _getSectionHeaderStyle()),
              const SizedBox(height: 16),

              /// TABLE / LIST
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
              else if (_errorMessage != null)
                Center(child: Text(_errorMessage!, style: TextStyle(color: _colorScheme.error)))
              else if (_events.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No events found")))
              else
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(_colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                      columnSpacing: 40,
                      columns: [
                        DataColumn(label: Text("#", style: _getTableHeaderStyle())),
                        DataColumn(label: Text("Event Name", style: _getTableHeaderStyle())),
                        DataColumn(label: Text("Date & Time", style: _getTableHeaderStyle())),
                        DataColumn(label: Text("Venue", style: _getTableHeaderStyle())),
                        DataColumn(label: Text("Ticket Info", style: _getTableHeaderStyle())),
                        DataColumn(label: Text("Action", style: _getTableHeaderStyle())),
                      ],
                      rows: _events.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Event event = entry.value;
                        return DataRow(cells: [
                          DataCell(Text("${idx + 1}")),
                          DataCell(SizedBox(width: 150, child: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w500)))),
                          DataCell(Text("${event.eventDate}\n${event.startTime} - ${event.endTime}", style: const TextStyle(fontSize: 12))),
                          DataCell(Text(event.venue ?? "-")),
                          DataCell(Text(event.isTicketed ? "Price ${event.ticketPrice}" : "Free")),
                          DataCell(
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _registerForEvent(event),
                              child: const Text("REGISTER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ]);
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

  TextStyle _getSectionHeaderStyle() {
    return GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: _colorScheme.onSurface,
    );
  }

  TextStyle _getTableHeaderStyle() {
    return const TextStyle(fontWeight: FontWeight.bold);
  }

  Widget buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              isExpanded: true,
              style: TextStyle(color: _colorScheme.onSurface, fontSize: 15),
              items: items.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
