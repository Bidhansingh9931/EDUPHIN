import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';

class EventListPage extends StatefulWidget {
  final bool showRegisteredOnly;
  const EventListPage({super.key, this.showRegisteredOnly = false});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Event> _availableEvents = [];
  List<EventRegistration> _registeredEvents = [];

  // Filters for Tab 0 (Explore)
  String _exploreStatus = 'Upcoming';
  String _exploreType = 'All types';

  // Filters for Tab 1 (My Registrations)
  String _registeredStatus = 'All Status';
  String _registeredType = 'All types';

  final List<String> _exploreStatusOptions = ['All Events', 'Upcoming', 'Expired'];
  final List<String> _registeredStatusOptions = ['All Status', 'Registered', 'Cancelled'];
  final List<String> _typeOptions = ['All types', 'Free', 'Paid'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.showRegisteredOnly ? 1 : 0);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchData();
      }
    });
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      if (_tabController.index == 0) {
        final events = await ApiService.getAccountantEvents(
          status: _exploreStatus == 'All Events' ? null : _exploreStatus.toLowerCase(),
          type: _exploreType == 'All types' ? null : _exploreType.toLowerCase(),
        );
        if (mounted) setState(() => _availableEvents = events);
      } else {
        final registered = await ApiService.getAccountantRegisteredEvents(
          status: _registeredStatus == 'All Status' ? null : _registeredStatus.toLowerCase(),
          type: _registeredType == 'All types' ? null : _registeredType.toLowerCase(),
        );
        if (mounted) setState(() => _registeredEvents = registered);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register(Event event) async {
    final eventId = event.encryptedId ?? event.id;
    final isPaid = event.isTicketed;

    if (isPaid) {
      _showPaymentDialog(eventId);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.accountantRegisterForEvent(eventId.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registered successfully")));
        _fetchData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRegistration(EventRegistration registration) async {
    final registrationId = registration.encryptedId ?? registration.id;
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Participation"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Reason for cancellation (optional)",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("GO BACK")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.colorScheme.error),
            child: const Text("CANCEL SPOT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ApiService.accountantCancelEvent(registrationId.toString(), reason: reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Participation cancelled")));
          _fetchData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showPaymentDialog(dynamic eventId) {
    final paymentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Paid Event Registration"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("This is a ticketed event. Please provide your payment reference ID."),
            const SizedBox(height: 20),
            TextField(
              controller: paymentController,
              decoration: const InputDecoration(
                hintText: "Transaction ID",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (paymentController.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await ApiService.accountantRegisterForEvent(eventId.toString(), paymentId: paymentController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration submitted")));
                  _fetchData();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              } finally {
                if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event Management", style: context.theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Explore and register for upcoming events", style: context.theme.textTheme.labelSmall?.copyWith(color: context.theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "Explore Events"),
            Tab(text: "My Participation"),
          ],
        ),
      ),
      body: _isLoading && (_availableEvents.isEmpty && _registeredEvents.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventList(),
                      _buildRegisteredList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    bool isExplore = _tabController.index == 0;
    return buildFilterCard(
      context,
      children: [
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Event Status"),
              buildDropdown(
                context, 
                isExplore ? _exploreStatusOptions : _registeredStatusOptions, 
                isExplore ? _exploreStatus : _registeredStatus, 
                (val) {
                  setState(() {
                    if (isExplore) {
                      _exploreStatus = val!;
                    } else {
                      _registeredStatus = val!;
                    }
                  });
                  _fetchData();
                }
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Event Type"),
              buildDropdown(
                context, 
                _typeOptions, 
                isExplore ? _exploreType : _registeredType, 
                (val) {
                  setState(() {
                    if (isExplore) {
                      _exploreType = val!;
                    } else {
                      _registeredType = val!;
                    }
                  });
                  _fetchData();
                }
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _buildEventList() {
    if (_availableEvents.isEmpty) {
      return _buildEmptyState("No upcoming events found");
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.scale(1200)),
        child: GridView.builder(
          padding: context.pagePadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
            mainAxisExtent: context.scale(360),
            crossAxisSpacing: context.spacing,
            mainAxisSpacing: context.spacing,
          ),
          itemCount: _availableEvents.length,
          itemBuilder: (context, index) => _buildEventItem(_availableEvents[index]),
        ),
      ),
    );
  }

  Widget _buildRegisteredList() {
    if (_registeredEvents.isEmpty) {
      return _buildEmptyState("You haven't registered for any events yet");
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.scale(800)),
        child: ListView.builder(
          padding: context.pagePadding,
          itemCount: _registeredEvents.length,
          itemBuilder: (context, index) => _buildRegisteredItem(_registeredEvents[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, color: theme.hintColor.withValues(alpha: 0.3), size: context.scale(64)),
            SizedBox(height: context.scale(16)),
            Text(message, style: TextStyle(color: theme.hintColor, fontSize: context.font(14)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: context.scale(150),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                image: event.image != null ? DecorationImage(image: NetworkImage("${ApiService.baseUrl}/storage/${event.image}"), fit: BoxFit.cover) : null,
              ),
              child: event.image == null ? Icon(Icons.image_outlined, color: theme.hintColor.withValues(alpha: 0.3), size: context.scale(40)) : null,
            ),
            Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: context.scale(8)),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary, size: context.scale(14)),
                      SizedBox(width: context.scale(8)),
                      Text(event.date, style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12))),
                    ],
                  ),
                  if (event.venue != null) ...[
                    SizedBox(height: context.scale(4)),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: theme.colorScheme.secondary, size: context.scale(14)),
                        SizedBox(width: context.scale(8)),
                        Expanded(child: Text(event.venue!, style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                  SizedBox(height: context.scale(12)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                    decoration: BoxDecoration(
                      color: (event.isTicketed ? Colors.orange : Colors.green).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(8)),
                    ),
                    child: Text(
                      event.isTicketed ? "PAID EVENT: ₹${event.ticketPrice}" : "FREE EVENT", 
                      style: TextStyle(
                        color: event.isTicketed ? Colors.orange : Colors.green, 
                        fontSize: context.font(10), 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  SizedBox(height: context.spacing),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _register(event),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                      child: Text("REGISTER NOW", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Event event) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
        ),
        padding: EdgeInsets.all(context.spacing * 1.5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.scale(40),
                  height: context.scale(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.spacing),
              if (event.image != null)
                Container(
                  height: context.scale(200),
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: context.spacing),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    image: DecorationImage(image: NetworkImage("${ApiService.baseUrl}/storage/${event.image}"), fit: BoxFit.cover),
                  ),
                ),
              Text(event.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: context.spacing),
              _detailInfoRow(Icons.calendar_month, "Date", event.date),
              if (event.startTime != null) _detailInfoRow(Icons.access_time, "Time", "${event.startTime} - ${event.endTime ?? ''}"),
              if (event.venue != null) _detailInfoRow(Icons.location_on, "Venue", event.venue!),
              _detailInfoRow(Icons.confirmation_number, "Price", event.isTicketed ? "₹${event.ticketPrice}" : "Free"),
              if (event.description != null && event.description!.isNotEmpty) ...[
                SizedBox(height: context.spacing),
                Text("About Event", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: context.scale(8)),
                Text(event.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              SizedBox(height: context.spacing * 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _register(event);
                  },
                  child: const Text("REGISTER FOR THIS EVENT"),
                ),
              ),
              SizedBox(height: context.spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(6)),
      child: Row(
        children: [
          Icon(icon, size: context.scale(18), color: context.theme.colorScheme.primary),
          SizedBox(width: context.spacing),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildRegisteredItem(EventRegistration registration) {
    final event = registration.event;
    final bool isCancelled = registration.status.toLowerCase() == 'cancelled';
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_available_rounded, color: theme.colorScheme.onPrimaryContainer, size: context.scale(24)),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(event.date, style: theme.textTheme.bodySmall),
                  if (registration.reasonForCancel != null && isCancelled)
                    Text("Reason: ${registration.reasonForCancel}", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontStyle: FontStyle.italic)),
                  SizedBox(height: context.scale(8)),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
                        decoration: BoxDecoration(
                          color: (isCancelled ? Colors.red : Colors.green).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.scale(6)),
                        ),
                        child: Text(
                          registration.status.toUpperCase(), 
                          style: TextStyle(
                            color: isCancelled ? Colors.red : Colors.green, 
                            fontSize: context.font(10), 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      if (!isCancelled) ...[
                        SizedBox(width: context.spacing),
                        TextButton(
                          onPressed: () => _cancelRegistration(registration),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("Cancel Spot"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
