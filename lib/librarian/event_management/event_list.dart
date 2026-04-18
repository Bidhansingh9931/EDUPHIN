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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  /// FILTER SECTION
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.md),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.md),
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
                          SizedBox(height: context.sm),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: _fetchEvents,
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: context.md),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                  ),
                                  child: Text("APPLY FILTERS", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(width: context.md),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedStatus = "All Events";
                                      selectedType = "All types";
                                    });
                                    _fetchEvents();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: context.md),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                  ),
                                  child: Text("RESET", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.md),

                  /// ALL EVENTS LIST SECTION
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.md),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.md),
                          child: Row(
                            children: [
                              Text("Event List", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                              const Spacer(),
                              _exportIcon(context, Icons.description, Colors.teal),
                              _exportIcon(context, Icons.table_chart, Colors.green),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        
                        if (_isLoading)
                          Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: context.xl),
                            child: const CircularProgressIndicator(),
                          ))
                        else if (_events.isEmpty)
                          Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: context.xl),
                            child: Text("No events found.", style: TextStyle(fontSize: context.font(14))),
                          ))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                              columnSpacing: context.md,
                              columns: [
                                DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                DataColumn(label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                DataColumn(label: Text("Event Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                DataColumn(label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                DataColumn(label: Text("Ticket info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                              ],
                              rows: _events.asMap().entries.map((entry) {
                                int index = entry.key + 1;
                                model.Event e = entry.value;
                                return _buildDataRow(context, index.toString(), e);
                              }).toList(),
                            ),
                          ),
                        SizedBox(height: context.md),
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
    if (!context.isTablet && !context.isDesktop) {
      return Column(children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.sm), child: c)).toList());
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: context.sm), child: c))).toList(),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.bold)),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _exportIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(left: context.xs),
      padding: EdgeInsets.all(context.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.xs),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: context.scale(16)),
    );
  }

  DataRow _buildDataRow(BuildContext context, String hash, model.Event event) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    bool isExpired = false;
    if (event.eventDate != null) {
      try {
        DateTime eventDate = DateTime.parse(event.eventDate!);
        isExpired = eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      } catch (_) {}
    }

    return DataRow(cells: [
      DataCell(Text(hash, style: TextStyle(fontSize: context.font(12)))),
      DataCell(
        ClipRRect(
          borderRadius: BorderRadius.circular(context.scale(4)),
          child: event.image != null
              ? Image.network(
                  "${ApiService.baseImageUrl}/storage/${event.image}",
                  width: context.scale(40), height: context.scale(40), fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, size: context.scale(20)),
                )
              : Icon(Icons.image, size: context.scale(20)),
        ),
      ),
      DataCell(SizedBox(
        width: context.scale(150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)), overflow: TextOverflow.ellipsis),
            Text(event.venue ?? "N/A", style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(10)), overflow: TextOverflow.ellipsis),
          ],
        ),
      )),
      DataCell(Text(
        "${event.eventDate ?? ''}\n${event.startTime ?? ''}",
        style: TextStyle(fontSize: context.font(10)),
      )),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(event.isTicketed ? "₹${event.ticketPrice}" : "Free", style: TextStyle(fontSize: context.font(11))),
          SizedBox(height: context.scale(2)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.scale(6), vertical: context.scale(2)),
            decoration: BoxDecoration(
              color: (event.isTicketed ? Colors.orange : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.scale(4)),
            ),
            child: Text(event.isTicketed ? "Ticketed" : "Free", style: TextStyle(color: event.isTicketed ? Colors.orange : Colors.green, fontSize: context.font(8), fontWeight: FontWeight.bold)),
          ),
        ],
      )),
      DataCell(
        isExpired
            ? Text("Expired", style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.error, fontSize: context.font(10)))
            : TextButton(
                onPressed: () => _registerEvent(event.id),
                child: Text("Register", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
      ),
    ]);
  }
}
