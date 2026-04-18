import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/manager_dashboard/events/event_model.dart';
import 'common_widgets.dart';

class ExploreEventsPage extends StatefulWidget {
  const ExploreEventsPage({super.key});

  @override
  State<ExploreEventsPage> createState() => _ExploreEventsPageState();
}

class _ExploreEventsPageState extends State<ExploreEventsPage> {
  final Map<String, String?> _filters = {'status': 'all', 'type': 'all', 'search': ''};
  final TextEditingController _searchController = TextEditingController();
  Key _listKey = UniqueKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Events"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterSection(),
                FutureBuilder<List<Event>>(
                  key: _listKey,
                  future: ApiService.getEvents(
                    status: _filters['status'] == 'all' ? null : _filters['status'],
                    type: _filters['type'] == 'all' ? null : _filters['type'],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(context.spacing * 2),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.all(context.spacing * 2),
                        child: Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: context.theme.colorScheme.error))),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(context.spacing * 2),
                        child: Center(child: Text("No events found.", style: TextStyle(fontSize: context.font(14), color: context.theme.colorScheme.onSurfaceVariant))),
                      );
                    }

                    final events = snapshot.data!;
                    return _buildEventsTable(events);
                  },
                ),
                SizedBox(height: context.spacing * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list, size: context.scale(18), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter Events",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(
          context,
          [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel(context, "Status"),
                buildDropdown(
                  context, 
                  ['all', 'upcoming', 'expired'], 
                  _filters['status'], 
                  (val) => setState(() => _filters['status'] = val),
                  hint: "All Events"
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel(context, "Type"),
                buildDropdown(
                  context, 
                  ['all', 'free', 'paid'], 
                  _filters['type'], 
                  (val) => setState(() => _filters['type'] = val),
                  hint: "All types"
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: context.scale(24)),
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                context, 
                "RESET", 
                () => setState(() {
                  _filters['status'] = 'all';
                  _filters['type'] = 'all';
                  _listKey = UniqueKey();
                }),
                isPrimary: false
              ),
            ),
            SizedBox(width: context.scale(12)),
            Expanded(child: buildActionButton(context, "APPLY", () => setState(() => _listKey = UniqueKey()))),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(6)),
      child: Text(text, style: context.theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12))),
    );
  }

  Widget _buildEventsTable(List<Event> events) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.all(context.pagePadding.left),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 0.5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), thickness: 0.5),
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
                child: Row(
                  children: [
                    SizedBox(
                      width: context.scale(32),
                      child: Text("${index + 1}", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    Container(
                      width: context.scale(50),
                      height: context.scale(50),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(context.scale(8)),
                      ),
                      child: Icon(Icons.event_note_outlined, size: context.scale(24), color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                    SizedBox(width: context.scale(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface)),
                          SizedBox(height: context.scale(2)),
                          Text(event.description, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: context.scale(20), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = context.theme;
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(10)),
      child: Row(
        children: [
          SizedBox(width: context.scale(32), child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          SizedBox(width: context.scale(66), child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text("Event Details", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          SizedBox(width: context.scale(20)),
        ],
      ),
    );
  }
}
