import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart' as model;
import 'package:intl/intl.dart';

class ExploreEventsPage extends StatefulWidget {
  const ExploreEventsPage({super.key});

  @override
  State<ExploreEventsPage> createState() => _ExploreEventsPageState();
}

class _ExploreEventsPageState extends State<ExploreEventsPage> {
  String selectedStatus = "All Events";
  String selectedType = "All types";
  
  bool _isLoading = true;
  List<model.Event> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      String? status = selectedStatus == "All Events" ? null : selectedStatus.toLowerCase();
      String? type = selectedType == "All types" ? null : selectedType.toLowerCase() == "ticketed" ? "paid" : "free";
      
      final events = await ApiService.getLibrarianEvents(status: status, type: type);
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _registerEvent(int eventId) async {
    try {
      await ApiService.librarianRegisterForEvent(eventId.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registered successfully!")));
      _fetchEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Events"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  /// FILTER SECTION
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResponsiveRow(context, [
                            _buildDropdownField(context, "Status", selectedStatus, ["All Events", "Upcoming", "Expired"], (val) {
                              setState(() => selectedStatus = val!);
                            }),
                            _buildDropdownField(context, "Type", selectedType, ["All types", "Ticketed", "Free"], (val) {
                              setState(() => selectedType = val!);
                            }),
                          ]),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _fetchEvents,
                                  child: const Text("APPLY FILTERS"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedStatus = "All Events";
                                      selectedType = "All types";
                                    });
                                    _fetchEvents();
                                  },
                                  child: const Text("RESET"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ALL EVENTS LIST SECTION
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text("Event List", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              _exportIcon(Icons.description, Colors.teal),
                              _exportIcon(Icons.table_chart, Colors.green),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        
                        if (_isLoading)
                          const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ))
                        else if (_events.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text("No events found."),
                          ))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                              columnSpacing: 25,
                              columns: const [
                                DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Event Details", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Ticket info", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _events.asMap().entries.map((entry) {
                                int index = entry.key + 1;
                                model.Event e = entry.value;
                                return _buildDataRow(context, index.toString(), e);
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _exportIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  DataRow _buildDataRow(BuildContext context, String hash, model.Event event) {
    final theme = Theme.of(context);
    bool isExpired = false;
    if (event.eventDate != null) {
      try {
        DateTime eventDate = DateTime.parse(event.eventDate!);
        isExpired = eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      } catch (_) {}
    }

    return DataRow(cells: [
      DataCell(Text(hash)),
      DataCell(
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: event.image != null
              ? Image.network(
                  "${ApiService.baseImageUrl}/storage/${event.image}",
                  width: 40, height: 40, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                )
              : const Icon(Icons.image, size: 20),
        ),
      ),
      DataCell(SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
            Text(event.venue ?? "N/A", style: theme.textTheme.bodySmall?.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
          ],
        ),
      )),
      DataCell(Text(
        "${event.eventDate ?? ''}\n${event.startTime ?? ''}",
        style: const TextStyle(fontSize: 10),
      )),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(event.isTicketed ? "₹${event.ticketPrice}" : "Free", style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (event.isTicketed ? Colors.orange : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(event.isTicketed ? "Ticketed" : "Free", style: TextStyle(color: event.isTicketed ? Colors.orange : Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      )),
      DataCell(
        isExpired
            ? Text("Expired", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error))
            : TextButton(
                onPressed: () => _registerEvent(event.id),
                child: const Text("Register", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
      ),
    ]);
  }
}
