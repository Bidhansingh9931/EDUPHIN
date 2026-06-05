import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.loadList('customer_contacts');
    if (cachedData != null && mounted) {
      setState(() {
        _contacts = cachedData;
        _isLoading = false;
      });
    }
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (!mounted) return;
    if (_contacts.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getSuperAdminContacts();
      if (mounted) {
        setState(() {
          _contacts = data;
          _isLoading = false;
        });
        await SuperAdminCacheService.saveList('customer_contacts', data);
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
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
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _contacts.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
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
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
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
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          SuperAdminSkeleton(height: 20, width: 20),
                          SizedBox(width: 8),
                          SuperAdminSkeleton(height: 16, width: 150),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const SuperAdminSkeleton(height: 12, width: 300),
                      SizedBox(height: context.spacing),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, __) => const Row(
                          children: [
                            SuperAdminSkeleton(height: 40, width: 30),
                            SizedBox(width: 12),
                            Expanded(child: SuperAdminSkeleton(height: 40)),
                            SizedBox(width: 12),
                            Expanded(child: SuperAdminSkeleton(height: 40)),
                            SizedBox(width: 12),
                            Expanded(child: SuperAdminSkeleton(height: 40)),
                          ],
                        ),
                      ),
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
