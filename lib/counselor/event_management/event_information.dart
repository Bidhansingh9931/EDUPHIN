import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
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
  final String _cacheKey = 'counselor_events_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchEvents();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      _processData(cachedData);
    }
  }

  void _processData(dynamic data) {
    final jsonResponse = data is String ? jsonDecode(data) : data;
    final List eventsData = jsonResponse['events'] ?? jsonResponse['data'] ?? [];
    setState(() {
      _events = eventsData.map((e) => Event.fromJson(e)).toList();
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _fetchEvents() async {
    if (_events.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final queryParams = <String, String>{};
      if (status != null && status != "All Events") {
        queryParams['status'] = status!.toLowerCase();
      }
      if (type != null && type != "All Categories") {
        queryParams['type'] = type!.toLowerCase();
      }

      final response = await ApiService.get('counselor/events', queryParams);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((status == null || status == "All Events") && (type == null || type == "All Categories")) {
          await CachingService.saveData(_cacheKey, data);
        }
        if (mounted) {
          _processData(data);
        }
      } else {
        if (mounted && _events.isEmpty) {
          setState(() {
            _errorMessage = ApiService.errorMessage(response, "Failed to load events");
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && _events.isEmpty) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerForEvent(Event event) async {
    if (event.isTicketed) {
      _showPaymentIdDialog(event);
      return;
    }

    try {
      final response = await ApiService.post('counselor/events/register/${event.id}', {});
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showPaymentIdDialog(Event event) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                final response = await ApiService.post('counselor/events/register/${event.id}', {
                  'payment_id': controller.text,
                });
                if (!mounted) return;
                if (response.statusCode == 200 || response.statusCode == 302) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registered successfully!")));
                  _fetchEvents();
                } else {
                  final error = jsonDecode(response.body)['message'] ?? "Registration failed";
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("REGISTER"),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(width: double.infinity, height: 180),
              SizedBox(height: context.spacing * 1.5),
              const Skeleton(width: 120, height: 24),
              SizedBox(height: context.spacing),
              const Skeleton(width: double.infinity, height: 400),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = context.theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Events"),
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _events.isNotEmpty,
        skeleton: _buildSkeleton(),
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTER CARD
                  Card(
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
                          Text("Filters",
                              style: context.theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font(18))),
                          SizedBox(height: context.spacing),
                          _buildFilterRow(context, [
                            buildDropdown(
                                context, "Status", status ?? "All Events",
                                ["All Events", "Upcoming", "Expired"], (val) {
                              setState(() => status = val);
                            }),
                            buildDropdown(
                                context, "Category", type ?? "All Categories",
                                ["All Categories", "Paid", "Free"], (val) {
                              setState(() => type = val);
                            }),
                          ]),
                          SizedBox(height: context.spacing),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(0, context.scale(48)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(context.scale(8))),
                                  ),
                                  onPressed: _fetchEvents,
                                  child: const Text("APPLY",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(width: context.spacing / 2),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size(0, context.scale(48)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(context.scale(8))),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      status = "All Events";
                                      type = "All Categories";
                                    });
                                    _fetchEvents();
                                  },
                                  child: const Text("RESET",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacing * 1.5),

                  Text("Event List",
                      style: context.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: context.font(18))),
                  SizedBox(height: context.spacing),

                  /// TABLE / LIST
                  if (_errorMessage != null && _events.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.scale(24.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: _colorScheme.error, size: context.scale(48)),
                            SizedBox(height: context.spacing),
                            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: _colorScheme.error, fontSize: context.font(14))),
                            SizedBox(height: context.spacing),
                            FilledButton.icon(onPressed: _fetchEvents, icon: const Icon(Icons.refresh), label: const Text("RETRY")),
                          ],
                        ),
                      ),
                    )
                  else if (_events.isEmpty)
                    Padding(
                        padding: EdgeInsets.all(context.spacing * 2),
                        child: const Center(child: Text("No events found")))
                  else
                    Card(
                      elevation: 0,
                      color: context.theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        side: BorderSide(
                          color: context.theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(context
                              .theme.colorScheme.primary
                              .withValues(alpha: 0.05)),
                          columnSpacing: context.spacing,
                          columns: [
                            DataColumn(
                                label: Text("#",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                            DataColumn(
                                label: Text("Event Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                            DataColumn(
                                label: Text("Date & Time",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                            DataColumn(
                                label: Text("Venue",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                            DataColumn(
                                label: Text("Ticket Info",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                            DataColumn(
                                label: Text("Action",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(14)))),
                          ],
                          rows: _events.asMap().entries.map((entry) {
                            int idx = entry.key;
                            Event event = entry.value;
                            return DataRow(cells: [
                              DataCell(Text("${idx + 1}",
                                  style: TextStyle(fontSize: context.font(14)))),
                              DataCell(SizedBox(
                                  width: context.scale(150),
                                  child: Text(event.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: context.font(14))))),
                              DataCell(Text(
                                  "${event.eventDate}\n${event.startTime} - ${event.endTime}",
                                  style: TextStyle(fontSize: context.font(12)))),
                              DataCell(Text(event.venue ?? "-",
                                  style: TextStyle(fontSize: context.font(14)))),
                              DataCell(Text(
                                  event.isTicketed
                                      ? "Price ${event.ticketPrice}"
                                      : "Free",
                                  style: TextStyle(fontSize: context.font(14)))),
                              DataCell(
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: context.spacing / 2),
                                    minimumSize: Size(0, context.scale(36)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(context.scale(8))),
                                  ),
                                  onPressed: () => _registerForEvent(event),
                                  child: Text("REGISTER",
                                      style: TextStyle(
                                          fontSize: context.font(12),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  SizedBox(height: context.spacing * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((c) => Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: context.spacing / 2), child: c)))
          .toList(),
    );
  }

  Widget buildDropdown(BuildContext context, String label, String value,
      List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold, fontSize: context.font(11))),
        SizedBox(height: context.spacing / 4),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : items.first,
          isExpanded: true,
          style: TextStyle(color: context.theme.colorScheme.onSurface),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: context.spacing / 2, vertical: context.spacing / 4)),
          items: items.map((e) {
            return DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(fontSize: context.font(14))));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


