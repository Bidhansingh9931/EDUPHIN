import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';
import 'submit_new_ticket.dart';
import 'ticket_details.dart';

class YourSupportTicket extends StatelessWidget {
  const YourSupportTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportTicketsPage();
  }
}

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  bool _isLoading = true;
  List<SupportTicket> _tickets = [];
  String _searchQuery = "";
  String _selectedPriority = "";
  String _selectedStatus = "";

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> queryParams = {};
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;
      if (_selectedPriority.isNotEmpty) queryParams['priority'] = _selectedPriority.toLowerCase();
      if (_selectedStatus.isNotEmpty) queryParams['status'] = _selectedStatus.toLowerCase();

      final response = await ApiService.get('counselor/tickets', queryParams);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List ticketsData = data['data'] ?? data['tickets'] ?? [];
          _tickets = ticketsData.map((j) => SupportTicket.fromJson(j)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Tickets"),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                /// FILTER SECTION
                Padding(
                  padding: EdgeInsets.fromLTRB(context.pagePadding.left,
                      context.spacing, context.pagePadding.right, 0),
                  child: Card(
                    elevation: 0,
                    color: context.theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(12)),
                      side: BorderSide(
                        color: context.theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (val) {
                              _searchQuery = val;
                              _fetchTickets();
                            },
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: InputDecoration(
                              hintText: "Search tickets...",
                              prefixIcon: Icon(Icons.search, size: context.scale(20)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: context.spacing / 2,
                                  vertical: context.spacing / 4),
                            ),
                          ),
                          SizedBox(height: context.spacing / 2),
                          if (context.isMobile) ...[
                            _buildDropdown(
                                context,
                                "Priority",
                                ["All Priorities", "Low", "Medium", "High"],
                                _selectedPriority.isEmpty
                                    ? "All Priorities"
                                    : _selectedPriority, (val) {
                              setState(() {
                                _selectedPriority = val == "All Priorities" ? "" : val!;
                              });
                              _fetchTickets();
                            }),
                            SizedBox(height: context.spacing / 2),
                            _buildDropdown(
                                context,
                                "Status",
                                [
                                  "All Statuses",
                                  "Open",
                                  "In Progress",
                                  "Resolved",
                                  "Closed"
                                ],
                                _selectedStatus.isEmpty
                                    ? "All Statuses"
                                    : _selectedStatus, (val) {
                              setState(() {
                                _selectedStatus = val == "All Statuses" ? "" : val!;
                              });
                              _fetchTickets();
                            }),
                          ] else
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                      context,
                                      "Priority",
                                      ["All Priorities", "Low", "Medium", "High"],
                                      _selectedPriority.isEmpty
                                          ? "All Priorities"
                                          : _selectedPriority, (val) {
                                    setState(() {
                                      _selectedPriority =
                                          val == "All Priorities" ? "" : val!;
                                    });
                                    _fetchTickets();
                                  }),
                                ),
                                SizedBox(width: context.spacing / 2),
                                Expanded(
                                  child: _buildDropdown(
                                      context,
                                      "Status",
                                      [
                                        "All Statuses",
                                        "Open",
                                        "In Progress",
                                        "Resolved",
                                        "Closed"
                                      ],
                                      _selectedStatus.isEmpty
                                          ? "All Statuses"
                                          : _selectedStatus, (val) {
                                    setState(() {
                                      _selectedStatus =
                                          val == "All Statuses" ? "" : val!;
                                    });
                                    _fetchTickets();
                                  }),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// TABLE SECTION
                Expanded(
                  child: Padding(
                    padding: context.pagePadding,
                    child: Card(
                      elevation: 0,
                      color: context.theme.colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        side: BorderSide(
                          color: context.theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: RefreshIndicator(
                        onRefresh: _fetchTickets,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _tickets.isEmpty
                                ? Center(
                                    child: Text("No tickets found",
                                        style: TextStyle(
                                            color: context.theme.hintColor,
                                            fontSize: context.font(14))))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minWidth: MediaQuery.of(context).size.width -
                                              (context.isTablet
                                                  ? context.scale(100)
                                                  : context.scale(64))),
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(context
                                            .theme.colorScheme.primary
                                            .withValues(alpha: 0.05)),
                                        columnSpacing: context.spacing,
                                        horizontalMargin: context.spacing / 2,
                                        headingRowHeight: context.scale(56),
                                        dataRowMinHeight: context.scale(56),
                                        dataRowMaxHeight: context.scale(56),
                                        columns: [
                                          DataColumn(
                                              label: Text("#",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.font(13)))),
                                          DataColumn(
                                              label: Text("Title",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.font(13)))),
                                          DataColumn(
                                              label: Text("Status",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.font(13)))),
                                          DataColumn(
                                              label: Text("Created",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.font(13)))),
                                          DataColumn(
                                              label: Text("Action",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: context.font(13)))),
                                        ],
                                        rows: _tickets
                                            .map((t) => DataRow(cells: [
                                                  DataCell(Text(t.id.toString(),
                                                      style: TextStyle(
                                                          fontSize: context.font(13)))),
                                                  DataCell(SizedBox(
                                                      width: context.scale(150),
                                                      child: Text(t.title,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize:
                                                                  context.font(13)),
                                                          overflow:
                                                              TextOverflow.ellipsis))),
                                                  DataCell(_statusBadge(context, t.status)),
                                                  DataCell(Text(
                                                      t.createdAt?.split('T')[0] ?? "-",
                                                      style: TextStyle(
                                                          fontSize: context.font(13)))),
                                                  DataCell(
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    TicketDetailsPage(
                                                                        ticket: t))).then(
                                                            (_) => _fetchTickets());
                                                      },
                                                      child: Text("VIEW",
                                                          style: TextStyle(
                                                              fontSize: context.font(11),
                                                              fontWeight:
                                                                  FontWeight.bold)),
                                                    ),
                                                  ),
                                                ]))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ),

                /// CREATE BUTTON
                Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CreateSupportTicketPage()))
                            .then((_) => _fetchTickets());
                      },
                      icon: Icon(Icons.add, size: context.scale(20)),
                      label: Text("CREATE NEW TICKET",
                          style: TextStyle(
                              fontSize: context.font(14), fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: context.scale(16)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items, String current, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(current) ? current : items.first,
      isExpanded: true,
      items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item, style: TextStyle(fontSize: context.font(12))))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: context.font(14)),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case "open": color = Colors.blue; break;
      case "resolved": color = Colors.green; break;
      case "closed": color = Colors.grey; break;
      case "in progress": color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        (status ?? "UNKNOWN").toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(9), fontWeight: FontWeight.bold),
      ),
    );
  }
}
