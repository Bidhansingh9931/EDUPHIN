import 'package:eduphin/librarian/librarian_skeleton_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/common_widgets.dart';
import '../librarian_models.dart' as librarian_model;

class MyRegisteredEventsPage extends StatefulWidget {
  const MyRegisteredEventsPage({super.key});

  @override
  State<MyRegisteredEventsPage> createState() => _MyRegisteredEventsPageState();
}

class _MyRegisteredEventsPageState extends State<MyRegisteredEventsPage> {
  String selectedStatus = "All";
  String selectedType = "All";

  late Stream<List<librarian_model.EventRegistration>> _registrationsStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    setState(() {
      _registrationsStream = ApiService.getLibrarianRegisteredEventsStream().asBroadcastStream();
    });
  }

  List<librarian_model.EventRegistration> _filterRegistrations(List<librarian_model.EventRegistration> registrations) {
    return registrations.where((reg) {
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Registered Events"),
      ),
      body: StreamBuilder<List<librarian_model.EventRegistration>>(
        stream: _registrationsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<List<librarian_model.EventRegistration>>(
            snapshot: snapshot,
            skeleton: const TableSkeleton(),
            onRetry: _updateStream,
            builder: (registrations) {
              final filtered = _filterRegistrations(registrations);
              return RefreshIndicator(
                onRefresh: () async => _updateStream(),
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
                              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.filter_alt, color: colorScheme.primary, size: context.scale(18)),
                                      SizedBox(width: context.xs),
                                      Text("Filter Events",
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: context.md),
                                  _buildResponsiveRow(context, [
                                    _buildDropdownField(context, "Status", selectedStatus, ["All", "Upcoming", "Completed"], (val) {
                                      setState(() => selectedStatus = val!);
                                    }),
                                    _buildDropdownField(context, "Type", selectedType, ["All", "Free", "Paid"], (val) {
                                      setState(() => selectedType = val!);
                                    }),
                                  ]),
                                  SizedBox(height: context.sm),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedStatus = "All";
                                          selectedType = "All";
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: context.md),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                      ),
                                      child: Text("RESET FILTERS", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: context.md),

                          /// DATA TABLE SECTION
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.md),
                              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: filtered.isEmpty
                                ? Center(child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: context.xl),
                                    child: Text("No registered events found", style: TextStyle(fontSize: context.font(14))),
                                  ))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                      columnSpacing: context.md,
                                      columns: [
                                        DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Ticket Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      ],
                                      rows: filtered.asMap().entries.map((entry) {
                                        int index = entry.key + 1;
                                        librarian_model.EventRegistration registration = entry.value;
                                        return buildDataRow(
                                          context,
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
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) return Column(children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.sm), child: c)).toList());
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
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  DataRow buildDataRow(BuildContext context, String hash, librarian_model.EventRegistration registration) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final event = registration.event;
    return DataRow(cells: [
      DataCell(Text(hash, style: TextStyle(fontSize: context.font(12)))),
      DataCell(
        ClipRRect(
          borderRadius: BorderRadius.circular(context.xs),
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
            Text(event.title, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12))),
            if (event.description != null)
              Text(event.description!, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(10))),
          ],
        ),
      )),
      DataCell(Text("${event.eventDate ?? ''}\n${event.startTime ?? ''}", style: TextStyle(fontSize: context.font(10)))),
      DataCell(Text(event.venue ?? "N/A", style: TextStyle(fontSize: context.font(10)))),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: context.xs, vertical: context.xs / 2),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.xs)
        ),
        child: Text(event.isTicketed ? "Paid: ${event.ticketPrice}" : "Free Event", 
          style: TextStyle(color: colorScheme.primary, fontSize: context.font(9), fontWeight: FontWeight.bold)),
      )),
      DataCell(TextButton(
        onPressed: registration.status == 'cancelled' ? null : () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Cancel Registration"),
              content: const Text("Are you sure you want to cancel your registration for this event?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("NO")),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("YES")),
              ],
            )
          );
          if (confirm != true) return;

          try {
            await ApiService.cancelLibrarianEventRegistration(registration.id.toString());
            if (!mounted) return;
            _updateStream();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration cancelled")));
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
        child: Text(registration.status == 'cancelled' ? "CANCELLED" : "CANCEL",
            style: TextStyle(color: registration.status == 'cancelled' ? theme.hintColor : colorScheme.error, fontSize: context.font(11), fontWeight: FontWeight.bold)),
      )),
    ]);
  }
}
