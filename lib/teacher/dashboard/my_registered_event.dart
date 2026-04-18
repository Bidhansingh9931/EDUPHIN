import 'package:eduphin/services/responsive_helper.dart';
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
        title: Row(
          children: [
            Icon(Icons.how_to_reg_outlined, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            Text("My Registered Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterSection(),
                _buildEventsTable(),
                SizedBox(height: context.scale(32)),
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
            Icon(Icons.filter_alt_outlined, size: context.scale(18), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text("Filter Events", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
          ],
        ),
        SizedBox(height: context.scale(8)),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Status"),
              buildDropdown(
                context,
                ['All', 'Upcoming', 'Attended', 'Cancelled'],
                _filters['status'],
                (val) => setState(() => _filters['status'] = val),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Type"),
              buildDropdown(
                context,
                ['All', 'Workshop', 'Seminar', 'Conference'],
                _filters['type'],
                (val) => setState(() => _filters['type'] = val),
              ),
            ],
          ),
        ]),
        SizedBox(height: context.scale(20)),
        SizedBox(
          width: double.infinity,
          child: buildActionButton(
            context,
            "RESET FILTERS",
            () => setState(() {
              _filters['status'] = 'All';
              _filters['type'] = 'All';
              _listKey = UniqueKey();
            }),
            isPrimary: false,
          ),
        ),
      ],
    );
  }


  Widget _buildEventsTable() {
    final theme = context.theme;
    return Card(
      key: _listKey,
      elevation: 0,
      margin: EdgeInsets.all(context.scale(16)),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          _buildEventRow(1, "Campus Cultural Fest 2025", "A vibrant celebration showcasing the diverse culture of our institution."),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          _buildEventDetailsSubRow("03 Jan 2026\n09:00 AM - 04:00 PM", "Seminar Hall", "Free Event", "09 Oct 2025\n12:16 PM"),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = context.theme;
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      child: Row(
        children: [
          SizedBox(width: context.scale(30), child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
          SizedBox(width: context.scale(60), child: Text("Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
          Expanded(child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
        ],
      ),
    );
  }

  Widget _buildEventRow(int id, String title, String desc) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      child: Row(
        children: [
          SizedBox(width: context.scale(30), child: Text("$id", style: TextStyle(fontSize: context.font(13)))),
          SizedBox(
            width: context.scale(60),
            child: Icon(Icons.image_outlined, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: context.scale(24)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface)),
                Text(desc, style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSubRow(String dateTime, String venue, String ticketInfo, String regOn) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _subInfoColumn("Date & Time", dateTime),
            _subInfoColumn("Venue", venue),
            _subInfoColumn("Ticket Info", ticketInfo, isBadge: true),
            _subInfoColumn("Registration on", regOn),
            Padding(
              padding: EdgeInsets.only(left: context.scale(16)),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                  minimumSize: Size.zero,
                  textStyle: TextStyle(fontSize: context.font(10), fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
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
    final theme = context.theme;
    return Container(
      width: context.scale(120),
      padding: EdgeInsets.only(right: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(10), color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: context.scale(4)),
          if (isBadge)
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(4)),
                border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Text(value, style: TextStyle(color: theme.colorScheme.secondary, fontSize: context.font(10), fontWeight: FontWeight.bold)),
            )
          else
            Text(value, style: TextStyle(fontSize: context.font(10), color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
