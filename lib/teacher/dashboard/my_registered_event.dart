import 'package:flutter/material.dart';
import 'common_widgets.dart';

class MyRegisteredEventPage extends StatefulWidget {
  const MyRegisteredEventPage({super.key});

  @override
  State<MyRegisteredEventPage> createState() => _MyRegisteredEventPageState();
}

class _MyRegisteredEventPageState extends State<MyRegisteredEventPage> {
  final Map<String, String?> _filters = {'status': 'All', 'type': 'All'};
  Key _listKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.how_to_reg_outlined, size: 20),
            SizedBox(width: 12),
            Text("My Registered Events"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterSection(),
            _buildEventsTable(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 18),
            const SizedBox(width: 8),
            Text("Filter Events", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        _fieldLabel("Status"),
        buildDropdown(
          context, 
          ['All', 'Upcoming', 'Attended', 'Cancelled'], 
          _filters['status'], 
          (val) => setState(() => _filters['status'] = val)
        ),
        _fieldLabel("Type"),
        buildDropdown(
          context, 
          ['All', 'Workshop', 'Seminar', 'Conference'], 
          _filters['type'], 
          (val) => setState(() => _filters['type'] = val)
        ),
        const SizedBox(height: 20),
        buildActionButton(context, "RESET", () => setState(() {
          _filters['status'] = 'All';
          _filters['type'] = 'All';
          _listKey = UniqueKey();
        })),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEventsTable() {
    return Card(
      key: _listKey,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          _buildEventRow(1, "Campus Cultural Fest 2025", "A vibrant celebration showcasing the diverse cultu..."),
          const Divider(height: 1),
          _buildEventDetailsSubRow("03 Jan 2026\n09:00 AM - 04:00 PM", "Seminar Hall", "Free Event", "09 Oct 2025\n12:16 PM"),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildEventRow(int id, String title, String desc) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$id")),
          const SizedBox(width: 60, child: Text("Img", style: TextStyle(fontStyle: FontStyle.italic))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(desc, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSubRow(String dateTime, String venue, String ticketInfo, String regOn) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
             _subInfoColumn("Date & Time", dateTime),
             _subInfoColumn("Venue", venue),
             _subInfoColumn("Ticket Info", ticketInfo, isBadge: true),
             _subInfoColumn("Registration on", regOn),
             Padding(
               padding: const EdgeInsets.only(left: 16),
               child: ElevatedButton(
                 onPressed: () {},
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   minimumSize: Size.zero,
                   textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                 ),
                 child: const Text("CANCEL\nREGISTRATION", textAlign: TextAlign.center),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _subInfoColumn(String label, String value, {bool isBadge = false}) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 4),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.cyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(value, style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          else
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
