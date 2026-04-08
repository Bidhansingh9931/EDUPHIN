import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Event Management"),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadEvents(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Column(
            children: [
              _buildFilterCard(context),
              const SizedBox(height: 24),
              _buildEventListSection(context, "Upcoming Events", _eventsFuture, isRegistered: false),
              const SizedBox(height: 24),
              _buildEventListSection(context, "Registered Events", _registeredEventsFuture, isRegistered: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(context, _selectedStatus, ["All Events", "Upcoming", "Past"], (val) {
              setState(() => _selectedStatus = val!);
            }),
            const SizedBox(height: 16),
            Text("Type", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(context, _selectedType, ["All types", "Internal", "Workshop", "Seminar"], (val) {
              setState(() => _selectedType = val!);
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text("APPLY FILTERS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.cardTheme.color,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.hintColor),
          style: theme.textTheme.bodyMedium,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEventListSection(BuildContext context, String title, Future<dynamic> future, {required bool isRegistered}) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          FutureBuilder<dynamic>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("No events found", style: TextStyle(color: theme.hintColor)),
                );
              }

              final List dataList = snapshot.data as List;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = dataList[index];
                  final Event event = isRegistered ? (item as EventRegistration).event : (item as Event);
                  final String idToCancel = isRegistered ? (item as EventRegistration).encryptedId ?? item.id.toString() : "";

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(event.eventDate ?? 'N/A', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                    trailing: isRegistered 
                      ? IconButton(
                          icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error, size: 20),
                          onPressed: () => _cancelRegistration(idToCancel),
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: ElevatedButton(
                            onPressed: () => _registerForEvent(event.id),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(0, 36),
                              textStyle: const TextStyle(fontSize: 10),
                            ),
                            child: const Text("REGISTER"),
                          ),
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

  Future<void> _registerForEvent(dynamic eventId) async {
    try {
      await ApiService.staffRegisterForEvent(eventId.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered successfully')));
        _loadEvents();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register: $e')));
    }
  }

  Future<void> _cancelRegistration(String registrationId) async {
    try {
      await ApiService.cancelStaffEventRegistration(registrationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration cancelled')));
        _loadEvents();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
    }
  }
}
