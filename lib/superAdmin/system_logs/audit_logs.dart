import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'log_details.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<dynamic> _logs = [];
  List<dynamic> _institutes = [];
  List<dynamic> _roles = [];
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
      final response = await ApiService.get('superadmin/audit');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            if (data is Map) {
              _logs = data['logs'] ?? [];
              _institutes = data['institutes'] ?? [];
              _roles = data['roles'] ?? [];
            } else if (data is List) {
              _logs = data;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Logs"),
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
                Text("Filter Logs", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (context.isTablet)
              Row(
                children: [
                  Expanded(child: _buildDropdownFilter(context, "Institute", _institutes, 'id')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdownFilter(context, "Role", _roles, 'role_id')),
                ],
              )
            else ...[
              _buildDropdownFilter(context, "Institute", _institutes, 'id'),
              _buildDropdownFilter(context, "Role", _roles, 'role_id'),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
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
                Icon(Icons.assignment, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Log Entries", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Detailed records of system activities.", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 24),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
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
                            title: "Audit Log Details",
                            eventType: log['event'] ?? "Login",
                            eventColor: Colors.blue,
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
