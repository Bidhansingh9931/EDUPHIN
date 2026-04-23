import 'dart:async';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 1. Data Model for an Event
class Event {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? venue;
  final String? eventDate;
  final String? startTime;
  final String? endTime;
  final bool isTicketed;
  final String? ticketPrice;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.venue,
    this.eventDate,
    this.startTime,
    this.endTime,
    required this.isTicketed,
    this.ticketPrice,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] != null ? ApiService.getStorageUrl(json['image']) : null,
      venue: json['venue'],
      eventDate: json['event_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isTicketed: json['is_ticketed'] == 1 || json['is_ticketed'] == true,
      ticketPrice: json['ticket_price']?.toString(),
    );
  }
}

// 2. Data Provider to fetch event data
class EventProvider {
  static const String _cacheKey = 'moderator_events_list';

  Future<List<Event>> fetchEvents({bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await getCachedEvents();
        if (cached != null) return cached;
      }
      final data = await ApiService.getModeratorEvents();
      await CacheHelper.save(_cacheKey, data);
      return data.map((e) => Event.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching events: $e");
      // Return empty list instead of throwing to allow "Coming Soon" state
      return [];
    }
  }

  Future<List<Event>?> getCachedEvents() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null && cached is List) {
      return cached.map((e) => Event.fromJson(e)).toList();
    }
    return null;
  }
}

// 3. Updated StatefulWidget to be dynamic
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventProvider _provider = EventProvider();
  late Future<List<Event>> _eventsFuture;
  List<Event>? _cachedEvents;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedEvents = await _provider.getCachedEvents();
    _refreshEvents();
  }

  Future<void> _refreshEvents({bool bypassCache = false}) async {
    setState(() {
      _eventsFuture = _provider.fetchEvents(bypassCache: bypassCache);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('All Events', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _refreshEvents,
            icon: Icon(Icons.refresh_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<Event>>(
            snapshot: snapshot,
            cachedData: _cachedEvents,
            skeleton: const ListSkeleton(),
            onRefresh: () => _refreshEvents(bypassCache: true),
            builder: (events) {
              if (snapshot.hasError && (_cachedEvents == null || _cachedEvents!.isEmpty)) {
                return _buildComingSoon(context);
              }

              if (events.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => _refreshEvents(bypassCache: true),
                color: theme.colorScheme.primary,
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.scale(1200)),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                          crossAxisSpacing: context.md,
                          mainAxisSpacing: context.md,
                          mainAxisExtent: context.scale(260),
                        ),
                        itemBuilder: (context, index) {
                          return EventCard(event: events[index]);
                        },
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: context.md),
          Text("No events found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(24)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.rocket_launch_rounded, size: context.scale(64), color: theme.colorScheme.primary),
            ),
            SizedBox(height: context.lg),
            Text(
              "Coming Soon!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: context.font(28),
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              "We're working hard to bring events to your dashboard. Stay tuned!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.font(16),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    String formattedDate = "N/A";
    if (event.eventDate != null) {
      try {
        DateTime dt = DateTime.parse(event.eventDate!);
        formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
      } catch (_) {}
    }

    final String price = event.isTicketed ? "₹${event.ticketPrice ?? '0'}" : "FREE";

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: context.scale(120),
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(context.md)),
                    child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                        ? Image.network(
                            event.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.event_note, color: primaryColor.withValues(alpha: 0.2), size: context.scale(48))),
                          )
                        : Center(child: Icon(Icons.event_note, color: primaryColor.withValues(alpha: 0.2), size: context.scale(48))),
                  ),
                ),
                Positioned(
                  top: context.scale(8),
                  right: context.scale(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                    decoration: BoxDecoration(
                      color: event.isTicketed ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(context.scale(4)),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.font(10)),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    if (event.eventDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: context.scale(12), color: primaryColor),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(11))),
                        ],
                      ),
                    const Spacer(),
                    Text(
                      event.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4, fontSize: context.font(12)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.sm),
                    Row(
                      children: [
                        Text("Read More", style: TextStyle(color: colorScheme.primary, fontSize: context.font(12), fontWeight: FontWeight.bold)),
                        SizedBox(width: context.xs),
                        Icon(Icons.arrow_forward_rounded, color: colorScheme.primary, size: context.scale(14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
