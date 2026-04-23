import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  String? _status;
  String? _type;
  List<dynamic> _events = [];
  bool _isLoading = true;
  static const String _cacheKey = 'student_all_events';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchEvents();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _events = List<dynamic>.from(cachedData as List? ?? []);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEvents() async {
    if (_events.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      String? apiStatus;
      if (_status == "Upcoming") apiStatus = "upcoming";
      if (_status == "Completed") apiStatus = "expired";

      String? apiType;
      if (_type == "Paid") apiType = "paid";
      if (_type == "Free") apiType = "free";

      final data = await ApiService.getStudentAllEvents(
        status: apiStatus,
        type: apiType,
      );
      if (mounted) {
        setState(() {
          _events = data;
          _isLoading = false;
        });
        await CacheService.saveData(_cacheKey, data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching events: $e"),
            backgroundColor: context.theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _registerForEvent(dynamic event) async {
    final bool isTicketed = event['is_ticketed'] == 1 || event['is_ticketed'] == true;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    
    if (isTicketed) {
      final TextEditingController paymentController = TextEditingController();
      final String? paymentId = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surfaceContainerLow,
          surfaceTintColor: colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
          title: Text("Register for Paid Event", style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: context.font(20))),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ticket Price: ₹${event['ticket_price']}", 
                  style: TextStyle(color: theme.textTheme.headlineSmall?.color, fontWeight: FontWeight.bold, fontSize: context.font(18))),
                SizedBox(height: context.sm),
                Text("Please enter your Payment ID / Transaction Ref to proceed.", 
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13))),
                SizedBox(height: context.lg),
                TextField(
                  controller: paymentController,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: context.font(14)),
                  decoration: InputDecoration(
                    labelText: "Payment ID",
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("CANCEL", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)))
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, paymentController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
              ),
              child: Text("REGISTER", style: TextStyle(fontSize: context.font(14))),
            ),
          ],
        ),
      );
      
      if (paymentId != null && paymentId.isNotEmpty) {
        _apiRegister(event['id'], paymentId);
      }
    } else {
      _apiRegister(event['id'], null);
    }
  }

  Future<void> _apiRegister(int eventId, String? paymentId) async {
    final theme = context.theme;
    try {
      await ApiService.registerForStudentEvent(eventId, paymentId: paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for event!"),
            backgroundColor: Color(0xFF10B981), // Emerald
          ),
        );
        _fetchEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration failed: $e"),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Events"),
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _events.isNotEmpty,
        skeleton: const _EventsSkeleton(),
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Events",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_events.length} found",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_events.isEmpty) 
                    _buildEmptyState()
                  else 
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                        crossAxisSpacing: context.scale(20),
                        mainAxisSpacing: context.scale(20),
                        mainAxisExtent: context.scale(480),
                      ),
                      itemCount: _events.length,
                      itemBuilder: (context, index) => _buildEventCard(_events[index]),
                    ),
                  const SizedBox(height: 40),
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
                Text("Filter Events", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
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
                      _status ?? "All Events", 
                      ["All Events", "Upcoming", "Completed"], 
                      (val) => setState(() => _status = val == "All Events" ? null : val)
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity,
                    child: _buildDropdown(
                      "Type", 
                      _type ?? "All Types", 
                      ["All Types", "Paid", "Free"], 
                      (val) => setState(() => _type = val == "All Types" ? null : val)
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
                        _status = null;
                        _type = null;
                      });
                      _fetchEvents();
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
                    onPressed: _fetchEvents,
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
          initialValue: items.contains(value) ? value : items.first,
          onChanged: onChanged,
          dropdownColor: colorScheme.surfaceContainerLow,
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

  Widget _buildEventCard(dynamic event) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final eventDateStr = event['event_date'];
    String formattedDate = "N/A";
    if (eventDateStr != null) {
      try {
        DateTime dt = DateTime.parse(eventDateStr);
        formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    final bool isPaid = event['is_ticketed'] == 1 || event['is_ticketed'] == true;
    final String price = isPaid ? "₹${event['ticket_price']}" : "FREE";
    final primaryColor = colorScheme.primary;

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
          Stack(
            children: [
              Container(
                height: context.scale(180),
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: event['image'] != null
                    ? Image.network(
                        "${ApiService.baseUrl}/${event['image']}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.event_note, color: primaryColor.withValues(alpha: 0.2), size: context.scale(64)),
                      )
                    : Icon(Icons.event_note, color: primaryColor.withValues(alpha: 0.2), size: context.scale(64)),
              ),
              Positioned(
                top: context.scale(12),
                right: context.scale(12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFF59E0B) : const Color(0xFF10B981), // Amber : Emerald
                    borderRadius: BorderRadius.circular(context.scale(8)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: context.scale(4))],
                  ),
                  child: Text(
                    price,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: context.font(12)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'Untitled Event',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scale(16)),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: context.scale(14), color: primaryColor),
                    SizedBox(width: context.scale(8)),
                    Text(formattedDate, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
                  ],
                ),
                SizedBox(height: context.scale(8)),
                Row(
                  children: [
                    Icon(Icons.access_time, size: context.scale(14), color: primaryColor),
                    SizedBox(width: context.scale(8)),
                    Text(event['start_time'] ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(12))),
                  ],
                ),
                SizedBox(height: context.scale(8)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: context.scale(14), color: primaryColor),
                    SizedBox(width: context.scale(8)),
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
                SizedBox(height: context.scale(20)),
                Text(
                  event['description'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                ),
                SizedBox(height: context.scale(24)),
                SizedBox(
                  width: double.infinity,
                  height: context.scale(48),
                  child: ElevatedButton(
                    onPressed: () => _registerForEvent(event),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      elevation: 0,
                    ),
                    child: Text("REGISTER NOW", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: context.font(14))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(80)),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
            SizedBox(height: context.scale(16)),
            Text("No events found", style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(18))),
            SizedBox(height: context.scale(8)),
            Text("Try adjusting your filters", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(12))),
          ],
        ),
      ),
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSkeleton(context),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(24)),
                  SkeletonBox(width: context.scale(80), height: context.scale(20)),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                  crossAxisSpacing: context.scale(20),
                  mainAxisSpacing: context.scale(20),
                  mainAxisExtent: context.scale(480),
                ),
                itemCount: 6,
                itemBuilder: (context, index) => _buildCardSkeleton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSkeleton(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24)),
        child: Column(
          children: [
            Row(
              children: [
                SkeletonBox(width: context.scale(24), height: context.scale(24), borderRadius: context.scale(4)),
                SizedBox(width: context.scale(12)),
                SkeletonBox(width: context.scale(120), height: context.scale(20), borderRadius: context.scale(4)),
              ],
            ),
            SizedBox(height: context.scale(24)),
            Row(
              children: [
                Expanded(child: SkeletonBox(height: context.scale(40), borderRadius: context.scale(12))),
                SizedBox(width: context.scale(20)),
                Expanded(child: SkeletonBox(height: context.scale(40), borderRadius: context.scale(12))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSkeleton(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: context.scale(180)),
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: context.scale(24), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(16)),
                SkeletonBox(width: context.scale(120), height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(8)),
                SkeletonBox(width: context.scale(100), height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(8)),
                SkeletonBox(width: context.scale(140), height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(20)),
                SkeletonBox(width: double.infinity, height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(4)),
                SkeletonBox(width: double.infinity, height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(4)),
                SkeletonBox(width: context.scale(150), height: context.scale(12), borderRadius: context.scale(4)),
                SizedBox(height: context.scale(24)),
                SkeletonBox(width: double.infinity, height: context.scale(48), borderRadius: context.scale(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
