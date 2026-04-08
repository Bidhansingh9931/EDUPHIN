import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'log_details.dart';

class DatabaseLogsScreen extends StatefulWidget {
  const DatabaseLogsScreen({super.key});

  @override
  State<DatabaseLogsScreen> createState() => _DatabaseLogsScreenState();
}

class _DatabaseLogsScreenState extends State<DatabaseLogsScreen> {
  List<dynamic> _logs = [];
  List<dynamic> _institutes = [];
  List<dynamic> _roles = [];
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('superadmin/audit/database');
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body)['data'];
          setState(() {
            if (data is Map) {
              _logs = data['logs'] ?? [];
              _institutes = data['institutes'] ?? [];
              _roles = data['roles'] ?? [];
              _events = data['events'] ?? [];
            }
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode} - Failed to load logs")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exception: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Audit Logs"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLogs,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    _buildFilterSection(context),
                    const SizedBox(height: 24),
                    _buildLogEntries(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Filter Database Logs", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter(context, "Institute", _institutes, 'id'),
            _buildDropdownFilter(context, "Role", _roles, 'role_id'),
            _buildDropdownFilter(context, "Event", _events.map((e) => {'name': e, 'value': e}).toList(), 'name'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _fetchLogs,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("RESET FILTERS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, List<dynamic> items, String valueKey) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          DropdownButtonFormField<dynamic>(
            isExpanded: true,
            hint: const Text("All Options"),
            items: items.map((item) {
              return DropdownMenuItem<dynamic>(
                value: item[valueKey],
                child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {},
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntries(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Log Entries", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Detailed records of database changes.", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 24),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
    if (_logs.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No database logs found."),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (context.isTablet ? 100 : 64)),
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("User", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Institute", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _logs.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final log = entry.value;
            final user = log['user'] ?? {};
            final institute = user['institute'] ?? {};
            
            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("ID: ${log['user_id'] ?? 'N/A'}", style: TextStyle(fontSize: 10, color: theme.hintColor)),
                    ],
                  ),
                ),
                DataCell(Text(institute['name'] ?? 'Eduphin')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogDetailsScreen(
                            title: "Database Log Details",
                            eventType: log['event'] ?? "Update",
                            eventColor: Colors.orange,
                            log: log,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
