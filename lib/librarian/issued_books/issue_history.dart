import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class IssueHistoryPage extends StatefulWidget {
  final String issueId;
  const IssueHistoryPage({super.key, required this.issueId});

  @override
  State<IssueHistoryPage> createState() => _IssueHistoryPageState();
}

class _IssueHistoryPageState extends State<IssueHistoryPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final logs = await ApiService.getIssueAuditLogs(widget.issueId);
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Issue History (ID: ${widget.issueId})"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLogs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        /// FILTER SECTION
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Filter History Logs", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildResponsiveRow(context, [
                                  _buildDateField(context, "Action From", _fromController),
                                  _buildDateField(context, "Action To", _toController),
                                ]),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Local filtering logic
                                        },
                                        child: const Text("APPLY"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _fromController.clear();
                                            _toController.clear();
                                          });
                                        },
                                        child: const Text("RESET"),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// RECORDS SECTION
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text("Audit Trail", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    _exportIcon(Icons.description, Colors.teal),
                                    _exportIcon(Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),

                              if (_logs.isEmpty)
                                const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text("No history records found"),
                                ))
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                    columnSpacing: 25,
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Performed By", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("IP Address", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _logs.asMap().entries.map((entry) {
                                      int index = entry.key + 1;
                                      var log = entry.value;
                                      return _buildDataRow(
                                        index.toString(),
                                        log['event'] ?? "N/A",
                                        log['user']?['name'] ?? "System",
                                        log['created_at'] ?? "N/A",
                                        log['ip_address'] ?? "N/A",
                                      );
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, controller),
            child: IgnorePointer(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "yyyy-mm-dd",
                  suffixIcon: Icon(Icons.calendar_month, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  DataRow _buildDataRow(String hash, String action, String user, String dateTime, String ip) {
    return DataRow(cells: [
      DataCell(Text(hash)),
      DataCell(Text(action, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(user)),
      DataCell(Text(dateTime)),
      DataCell(Text(ip, style: const TextStyle(fontSize: 10))),
    ]);
  }
}
