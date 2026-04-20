import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/app_drawer.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_skeleton_widgets.dart';
import '../../services/common_widgets.dart';

class IssueHistoryPage extends StatefulWidget {
  final String issueId;
  const IssueHistoryPage({super.key, required this.issueId});

  @override
  State<IssueHistoryPage> createState() => _IssueHistoryPageState();
}

class _IssueHistoryPageState extends State<IssueHistoryPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  late Stream<List<dynamic>> _logsStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    setState(() {
      _logsStream = ApiService.getIssueAuditLogsStream(widget.issueId).asBroadcastStream();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text("Issue History #${widget.issueId}"),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _logsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<List<dynamic>>(
            snapshot: snapshot,
            skeleton: const TableSkeleton(),
            onRetry: _refreshStream,
            builder: (logs) {
              return RefreshIndicator(
                onRefresh: () async => _refreshStream(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// FILTER SECTION
                          Card(
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.md),
                              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                                      SizedBox(width: context.sm),
                                      Text(
                                        "Filter History Logs",
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: context.md),
                                  _buildResponsiveRow(context, [
                                    _buildDateField(context, "Action From", _fromController),
                                    _buildDateField(context, "Action To", _toController),
                                  ]),
                                  SizedBox(height: context.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            // Local filtering logic
                                          },
                                          icon: const Icon(Icons.search_rounded),
                                          label: const Text("APPLY FILTERS"),
                                          style: FilledButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: context.md),
                                      Expanded(
                                        child: FilledButton.tonalIcon(
                                          onPressed: () {
                                            setState(() {
                                              _fromController.clear();
                                              _toController.clear();
                                            });
                                          },
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text("RESET"),
                                          style: FilledButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: context.lg),

                          /// RECORDS SECTION
                          Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            color: theme.colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.md),
                              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(context.md),
                                  child: Row(
                                    children: [
                                      Icon(Icons.history_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                                      SizedBox(width: context.sm),
                                      Text(
                                        "Audit Trail",
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                      ),
                                      const Spacer(),
                                      _exportIcon(context, Icons.description_rounded, "PDF", Colors.teal),
                                      _exportIcon(context, Icons.table_chart_rounded, "Excel", Colors.green),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                if (logs.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: context.xl),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.history_toggle_off_rounded, size: context.scale(48), color: theme.colorScheme.outlineVariant),
                                          SizedBox(height: context.sm),
                                          Text("No history records found", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline, fontSize: context.font(16))),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: context.md,
                                      headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainer),
                                      dataRowMinHeight: context.scale(60),
                                      dataRowMaxHeight: context.scale(70),
                                      columns: [
                                        DataColumn(label: Text("#", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("ACTION", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("PERFORMED BY", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("DATE & TIME", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("IP ADDRESS", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      ],
                                      rows: logs.asMap().entries.map((entry) {
                                        int index = entry.key + 1;
                                        var log = entry.value;
                                        return DataRow(cells: [
                                          DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(log['event'] ?? "N/A", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataCell(Text(log['user']?['name'] ?? "System", style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(log['created_at'] ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(log['ip_address'] ?? "N/A", style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)))),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                SizedBox(height: context.md),
                              ],
                            ),
                          ),
                          SizedBox(height: context.xl),
                        ],
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

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) return Column(children: children);
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.key != children.length - 1 ? context.md : 0,
                    ),
                    child: entry.value,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          InkWell(
            onTap: () => _selectDate(context, controller),
            borderRadius: BorderRadius.circular(context.sm),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sm),
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? "yyyy-mm-dd" : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: controller.text.isEmpty ? theme.colorScheme.outline : null,
                        fontSize: context.font(14),
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, size: context.scale(18), color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportIcon(BuildContext context, IconData icon, String tooltip, Color color) {
    return Container(
      margin: EdgeInsets.only(left: context.sm),
      child: IconButton.filledTonal(
        onPressed: () {},
        icon: Icon(icon, color: color, size: context.scale(20)),
        tooltip: "Export as $tooltip",
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
        ),
      ),
    );
  }
}
