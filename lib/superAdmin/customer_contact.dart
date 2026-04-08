import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CustomerContactScreen extends StatefulWidget {
  const CustomerContactScreen({super.key});

  @override
  State<CustomerContactScreen> createState() => _CustomerContactScreenState();
}

class _CustomerContactScreenState extends State<CustomerContactScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (!mounted) return;
    try {
      final data = await ApiService.getSuperAdminContacts();
      if (mounted) {
        setState(() {
          _contacts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Messages"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchContacts,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_ind, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text("Incoming Messages", 
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Review messages sent through the platform contact form.", 
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                            const SizedBox(height: 24),
                            _buildTable(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (context.isTablet ? 100 : 64)),
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _contacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(contact['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(contact['email'] ?? '')),
                DataCell(Text(contact['phone'] ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
