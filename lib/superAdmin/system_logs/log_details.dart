import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class LogDetailsScreen extends StatelessWidget {
  final String title;
  final String eventType;
  final Color eventColor;
  final dynamic log;

  const LogDetailsScreen({
    super.key,
    required this.title,
    required this.eventType,
    this.eventColor = Colors.blue,
    this.log,
  });

  @override
  Widget build(BuildContext context) {
    final data = log ?? {};
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Column(
                children: [
                  _buildInfoRow(context, "User:", "${data['user_name'] ?? 'N/A'} (ID: ${data['user_id'] ?? 'N/A'})"),
                  _buildInfoRow(context, "Institute:", data['institute_name'] ?? "Eduphin"),
                  _buildInfoRow(context, "Role:", data['role_name'] ?? "N/A"),
                  _buildEventRow(context, "Event Type:", eventType, eventColor),
                  _buildInfoRow(context, "Target Model:", "${data['model'] ?? 'N/A'} (ID: ${data['model_id'] ?? 'N/A'})"),
                  _buildInfoRow(context, "IP Address:", data['ip_address'] ?? "N/A"),
                  _buildInfoRow(context, "Timestamp:", data['created_at'] ?? "N/A"),
                  _buildInfoRow(context, "URL:", data['url'] ?? "N/A"),
                  const SizedBox(height: 24),
                  _buildValueSection(context, "Old Values:", data['old_values']?.toString() ?? "null"),
                  _buildValueSection(context, "New Values:", data['new_values']?.toString() ?? "null", isJson: true),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE DETAILS"),
                      ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildEventRow(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5))),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: color.withValues(alpha: 0.5))
            ),
            child: Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildValueSection(BuildContext context, String label, String value, {bool isJson = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1))
            ),
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: isJson ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
