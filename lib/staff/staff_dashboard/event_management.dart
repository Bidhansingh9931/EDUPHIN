import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';

class StaffEventManagementPage extends StatefulWidget {
  const StaffEventManagementPage({super.key});

  @override
  State<StaffEventManagementPage> createState() => _StaffEventManagementPageState();
}

class _StaffEventManagementPageState extends State<StaffEventManagementPage> {
  late Future<List<Event>> _eventsFuture;
  late Future<List<EventRegistration>> _registeredEventsFuture;
  String _selectedStatus = "All Events";
  String _selectedType = "All types";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = ApiService.getStaffEvents(
        status: _selectedStatus == "All Events" ? null : _selectedStatus,
        type: _selectedType == "All types" ? null : _selectedType,
      );
      _registeredEventsFuture = ApiService.getStaffRegisteredEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Event Management", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadEvents(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  _buildFilterCard(context),
                  Padding(
                    padding: context.pagePadding,
                    child: context.responsive(
                      Column(
                        children: [
                          _buildEventListSection(context, "Upcoming Events", _eventsFuture, isRegistered: false),
                          SizedBox(height: context.spacing),
                          _buildEventListSection(context, "Registered Events", _registeredEventsFuture, isRegistered: true),
                        ],
                      ),
                      tablet: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildEventListSection(context, "Upcoming Events", _eventsFuture, isRegistered: false)),
                          SizedBox(width: context.spacing),
                          Expanded(child: _buildEventListSection(context, "Registered Events", _registeredEventsFuture, isRegistered: true)),
                        ],
                      ),
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

  Widget _buildFilterCard(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: context.pagePadding.copyWith(bottom: 0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scale(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filter Events", 
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              SizedBox(height: context.scale(16)),
              context.responsive(
                Column(
                  children: [
                    _buildDropdownField(context, "Status", _selectedStatus, ["All Events", "Upcoming", "Past"], (val) {
                      setState(() => _selectedStatus = val!);
                    }),
                    SizedBox(height: context.scale(12)),
                    _buildDropdownField(context, "Type", _selectedType, ["All types", "Internal", "Workshop", "Seminar"], (val) {
                      setState(() => _selectedType = val!);
                    }),
                  ],
                ),
                tablet: Row(
                  children: [
                    Expanded(child: _buildDropdownField(context, "Status", _selectedStatus, ["All Events", "Upcoming", "Past"], (val) {
                      setState(() => _selectedStatus = val!);
                    })),
                    SizedBox(width: context.scale(16)),
                    Expanded(child: _buildDropdownField(context, "Type", _selectedType, ["All types", "Internal", "Workshop", "Seminar"], (val) {
                      setState(() => _selectedType = val!);
                    })),
                    SizedBox(width: context.scale(16)),
                    Padding(
                      padding: EdgeInsets.only(top: context.scale(22)),
                      child: FilledButton(
                        onPressed: _loadEvents,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(14)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        child: const Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              if (context.isMobile) ...[
                SizedBox(height: context.scale(16)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loadEvents,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: const Text("APPLY FILTERS", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
        SizedBox(height: context.scale(6)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(context.scale(12)),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.colorScheme.surface,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventListSection(BuildContext context, String title, Future<dynamic> future, {required bool isRegistered}) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Text(title, 
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: context.font(16))),
          ),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          FutureBuilder<dynamic>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(context.scale(40)),
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.all(context.scale(20)),
                  child: Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(13)))),
                );
              } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(context.scale(40)),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded, size: context.scale(48), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      SizedBox(height: context.scale(12)),
                      Center(child: Text("No events found", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)))),
                    ],
                  ),
                );
              }

              final List dataList = snapshot.data as List;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataList.length,
                separatorBuilder: (context, index) => Divider(color: theme.colorScheme.outlineVariant, height: 1),
                itemBuilder: (context, index) {
                  final item = dataList[index];
                  final Event event = isRegistered ? (item as EventRegistration).event : (item as Event);
                  final String idToCancel = isRegistered ? (item as EventRegistration).encryptedId ?? item.id.toString() : "";

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                    leading: Container(
                      width: context.scale(44),
                      height: context.scale(44),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                      child: Icon(Icons.event_note_rounded, color: theme.colorScheme.primary, size: context.scale(22)),
                    ),
                    title: Text(event.title, 
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: context.scale(4)),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: context.scale(12), color: theme.colorScheme.onSurfaceVariant),
                          SizedBox(width: context.scale(4)),
                          Text(event.eventDate ?? 'N/A', 
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
                        ],
                      ),
                    ),
                    trailing: isRegistered 
                      ? IconButton(
                          icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error, size: context.scale(22)),
                          onPressed: () => _showCancelDialog(context, idToCancel),
                          tooltip: "Cancel Registration",
                        )
                      : FilledButton.tonal(
                          onPressed: () => _registerForEvent(event.id),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                            minimumSize: Size(0, context.scale(36)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                          ),
                          child: Text("REGISTER", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold)),
                        ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String registrationId) {
    final colorScheme = context.theme.colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Registration", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to cancel your registration for this event?", style: TextStyle(fontSize: context.font(14))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(20))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("NO", style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelRegistration(registrationId);
            }, 
            child: Text("YES, CANCEL", style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _registerForEvent(dynamic eventId) async {
    try {
      await ApiService.staffRegisterForEvent(eventId.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Registered successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to register: $e'),
          backgroundColor: context.theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _cancelRegistration(String registrationId) async {
    try {
      await ApiService.cancelStaffEventRegistration(registrationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Registration cancelled'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to cancel: $e'),
          backgroundColor: context.theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }
}

