import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';

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

  Future<void> _register(dynamic eventId, bool isPaid) async {
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

  Future<void> _cancelRegistration(dynamic registrationId) async {
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
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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
        title: const Text("Event Management"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Explore"),
            Tab(text: "My Participation"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _buildSmallDropdown(
            isExplore ? _exploreStatus : _registeredStatus, 
            isExplore ? _exploreStatusOptions : _registeredStatusOptions, 
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
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildSmallDropdown(
            isExplore ? _exploreType : _registeredType, 
            _typeOptions, 
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
          )),
        ],
      ),
    );
  }

  Widget _buildSmallDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _buildEventList() {
    if (_availableEvents.isEmpty) {
      return _buildEmptyState("No events found");
    }
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 2 : 1,
        mainAxisExtent: 320,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _availableEvents.length,
      itemBuilder: (context, index) => _buildEventItem(_availableEvents[index]),
    );
  }

  Widget _buildRegisteredList() {
    if (_registeredEvents.isEmpty) {
      return _buildEmptyState("No registrations found");
    }
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: _registeredEvents.length,
      itemBuilder: (context, index) => _buildRegisteredItem(_registeredEvents[index]),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, color: Theme.of(context).hintColor.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: theme.colorScheme.surfaceContainerHighest,
              image: event.image != null ? DecorationImage(image: NetworkImage("${ApiService.baseUrl}/storage/${event.image}"), fit: BoxFit.cover) : null,
            ),
            child: event.image == null ? Icon(Icons.image_outlined, color: theme.hintColor.withValues(alpha: 0.3), size: 40) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 14),
                    const SizedBox(width: 8),
                    Text(event.date, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (event.isTicketed ? Colors.orange : Colors.green).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(event.isTicketed ? "PAID: ₹${event.ticketPrice}" : "FREE", 
                    style: TextStyle(color: event.isTicketed ? Colors.orange : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _register(event.id, event.isTicketed),
                    child: const Text("REGISTER"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredItem(EventRegistration registration) {
    final event = registration.event;
    final bool isCancelled = registration.status.toLowerCase() == 'cancelled';
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.event_available, color: theme.colorScheme.primary),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(event.date, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isCancelled ? Colors.red : Colors.green).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(registration.status.toUpperCase(), 
                    style: TextStyle(color: isCancelled ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                if (!isCancelled) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => _cancelRegistration(registration.id),
                    child: const Text("Cancel Registration", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
