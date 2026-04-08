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
        leading: IconButton(
          icon: const Icon(Icons.event_note_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: FutureBuilder<List<Event>>(
              key: _listKey,
              future: ApiService.getEvents(
                status: _filters['status'] == 'all' ? null : _filters['status'],
                type: _filters['type'] == 'all' ? null : _filters['type'],
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events found."));
                }

                final events = snapshot.data!;
                return _buildEventsTable(events);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return buildFilterCard(
      context,
      children: [
        _buildLabel("Status"),
        buildDropdown(
          context, 
          ['all', 'upcoming', 'expired'], 
          _filters['status'], 
          (val) => setState(() => _filters['status'] = val),
          hint: "All Events"
        ),
        const SizedBox(height: 12),
        _buildLabel("Type"),
        buildDropdown(
          context, 
          ['all', 'free', 'paid'], 
          _filters['type'], 
          (val) => setState(() => _filters['type'] = val),
          hint: "All types"
        ),
        const SizedBox(height: 16),
        buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey())),
        const SizedBox(height: 10),
        buildActionButton(
          context, 
          "RESET FILTERS", 
          () => setState(() {
            _filters['status'] = 'all';
            _filters['type'] = 'all';
            _listKey = UniqueKey();
          }),
          isPrimary: false
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEventsTable(List<Event> events) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(height: 1),
          _buildTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text("${index + 1}")),
                      const SizedBox(width: 60, child: Text("Img", style: TextStyle(fontStyle: FontStyle.italic))),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(event.description, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 30, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 60, child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Event Details", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
