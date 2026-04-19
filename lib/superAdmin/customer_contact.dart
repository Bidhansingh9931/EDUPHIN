import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
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
    setState(() => _isLoading = true);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Messages", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchContacts,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(12)),
                            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(context.spacing),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.assignment_ind, color: theme.colorScheme.primary, size: context.scale(20)),
                                    SizedBox(width: context.scale(8)),
                                    Text("Incoming Messages",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                                  ],
                                ),
                                SizedBox(height: context.scale(4)),
                                Text("Review messages sent through the platform contact form.",
                                    style: TextStyle(color: theme.hintColor, fontSize: context.font(12))),
                                SizedBox(height: context.spacing),
                                _buildTable(context),
                              ],
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

  Widget _buildTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: context.screenWidth - (context.isMobile ? context.scale(64) : context.scale(100))),
        child: DataTable(
          columnSpacing: context.scale(24),
          horizontalMargin: context.scale(12),
          dataRowMinHeight: context.scale(48),
          dataRowMaxHeight: context.scale(60),
          headingRowHeight: context.scale(56),
          columns: [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
          ],
          rows: _contacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(contact['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(13)))),
                DataCell(Text(contact['email'] ?? '', style: TextStyle(fontSize: context.font(13)))),
                DataCell(Text(contact['phone'] ?? '', style: TextStyle(fontSize: context.font(13)))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
