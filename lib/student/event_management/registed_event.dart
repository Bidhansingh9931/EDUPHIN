import 'package:eduphin/services/responsive_helper.dart';
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
        final theme = context.theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching registered events: $e"),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelRegistration(dynamic registration) async {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final TextEditingController reasonController = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
        title: Text("Cancel Registration", style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: context.font(20))),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Are you sure you want to cancel your registration for this event?", 
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13), height: 1.5)),
              SizedBox(height: context.lg),
              TextField(
                controller: reasonController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: context.font(14)),
                decoration: InputDecoration(
                  labelText: "Reason (Optional)",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text("NO, KEEP IT", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
            ),
            child: Text("YES, CANCEL", style: TextStyle(fontSize: context.font(14))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final String registrationId = registration['id']?.toString() ?? registration['id_hash'].toString();
        await ApiService.cancelStudentEventRegistration(
          registrationId,
          reason: reasonController.text.isEmpty ? null : reasonController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration cancelled successfully"),
              backgroundColor: Color(0xFF10B981), // Emerald
            ),
          );
          _fetchRegisteredEvents();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cancellation failed: $e"),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Registered Events"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRegisteredEvents,
        color: theme.colorScheme.primary,
        backgroundColor: theme.cardColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  SizedBox(height: context.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Participations",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
                      ),
                      Text(
                        "${_registeredEvents.length} registrations",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                      ),
                    ],
                  ),
                  SizedBox(height: context.lg),
                  _isLoading
                      ? Center(child: Padding(padding: EdgeInsets.all(context.scale(40)), child: CircularProgressIndicator(color: theme.colorScheme.primary)))
                      : _registeredEvents.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                crossAxisSpacing: context.md,
                                mainAxisSpacing: context.md,
                                mainAxisExtent: context.scale(360),
                              ),
                              itemCount: _registeredEvents.length,
                              itemBuilder: (context, index) => _buildRegistrationCard(_registeredEvents[index]),
                            ),
                  SizedBox(height: context.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: colorScheme.primary, size: context.scale(24)),
                SizedBox(width: context.scale(12)),
                Text("Filter History", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
              ],
            ),
            SizedBox(height: context.scale(24)),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Wrap(
                spacing: context.scale(20),
                runSpacing: context.scale(16),
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity,
                    child: _buildDropdown(
                      "Status", 
                      _statusValue, 
                      ["All", "Active", "Completed", "Cancelled"], 
                      (val) => setState(() => _statusValue = val!)
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity,
                    child: _buildDropdown(
                      "Type", 
                      _typeValue, 
                      ["All", "Paid", "Free"], 
                      (val) => setState(() => _typeValue = val!)
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: context.scale(24)),
            Row(
              children: [
                const Spacer(flex: 2),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                    ),
                    child: Text("RESET", style: TextStyle(fontSize: context.font(14))),
                  ),
                ),
                SizedBox(width: context.scale(16)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _fetchRegisteredEvents,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                      elevation: 0,
                    ),
                    child: Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(12))),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: colorScheme.surfaceContainerLow,
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard(dynamic registration) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
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
    final primaryColor = colorScheme.primary;

    Color statusColor = const Color(0xFF10B981); // Emerald
    if (isCancelled) {
      statusColor = const Color(0xFFEF4444); // Red
    } else if (isExpired) {
      statusColor = colorScheme.onSurfaceVariant;
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  child: Container(
                    height: context.scale(64),
                    width: context.scale(64),
                    color: colorScheme.surfaceContainerHighest,
                    child: event['image'] != null
                        ? Image.network(
                            ApiService.getStorageUrl(event['image']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.event_available, color: primaryColor, size: context.scale(24)),
                          )
                        : Icon(Icons.event_available, color: primaryColor, size: context.scale(24)),
                  ),
                ),
                SizedBox(width: context.scale(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Untitled Event',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.scale(6)),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: context.scale(12), color: colorScheme.onSurfaceVariant),
                          SizedBox(width: context.scale(4)),
                          Expanded(
                            child: Text(
                              event['venue'] ?? 'TBA',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(10)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.scale(6)),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: context.font(10), fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
          Padding(
            padding: EdgeInsets.all(context.scale(16)),
            child: Column(
              children: [
                _buildInfoDetail(Icons.calendar_today, "Event Date", "$formattedDate at ${event['start_time'] ?? 'N/A'}"),
                SizedBox(height: context.scale(12)),
                _buildInfoDetail(Icons.how_to_reg, "Registered On", _formatRegDate(registration['registered_at'])),
                SizedBox(height: context.scale(24)),
                if (!isCancelled && !isExpired)
                  SizedBox(
                    width: double.infinity,
                    height: context.scale(48),
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRegistration(registration),
                      icon: Icon(Icons.cancel_outlined, size: context.scale(18)),
                      label: Text("CANCEL REGISTRATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12))),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: context.scale(14), color: colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          "$label: ",
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: context.font(12)),
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(80)),
        child: Column(
          children: [
            Icon(Icons.history_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
            SizedBox(height: context.scale(16)),
            Text("No registration history", style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(18))),
            SizedBox(height: context.scale(8)),
            Text("Events you join will appear here", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(12))),
          ],
        ),
      ),
    );
  }
}
