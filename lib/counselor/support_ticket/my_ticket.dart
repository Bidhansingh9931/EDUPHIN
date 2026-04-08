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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final List ticketsData = data['data'] ?? data['tickets'] ?? [];
            _tickets = ticketsData.map((j) => SupportTicket.fromJson(j)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support Tickets"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// FILTER SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (val) {
                          _searchQuery = val;
                          _fetchTickets();
                        },
                        decoration: const InputDecoration(
                          hintText: "Search tickets...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(context, "Priority", ["All Priorities", "Low", "Medium", "High"], 
                              _selectedPriority.isEmpty ? "All Priorities" : _selectedPriority, (val) {
                                setState(() {
                                  _selectedPriority = val == "All Priorities" ? "" : val!;
                                });
                                _fetchTickets();
                              }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(context, "Status", ["All Statuses", "Open", "In Progress", "Resolved", "Closed"], 
                              _selectedStatus.isEmpty ? "All Statuses" : _selectedStatus, (val) {
                                setState(() {
                                  _selectedStatus = val == "All Statuses" ? "" : val!;
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
                  child: RefreshIndicator(
                    onRefresh: _fetchTickets,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _tickets.isEmpty
                            ? Center(child: Text("No tickets found", style: TextStyle(color: theme.hintColor)))
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (context.isTablet ? 100 : 64)),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Created", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _tickets.map((t) => DataRow(cells: [
                                      DataCell(Text(t.id.toString())),
                                      DataCell(SizedBox(width: 150, child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w500)))),
                                      DataCell(_statusBadge(t.status)),
                                      DataCell(Text(t.createdAt?.split('T')[0] ?? "-")),
                                      DataCell(
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticket: t))).then((_) => _fetchTickets());
                                          },
                                          child: const Text("VIEW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ])).toList(),
                                  ),
                                ),
                              ),
                  ),
                ),
              ),
            ),

            /// CREATE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage())).then((_) => _fetchTickets());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("CREATE NEW TICKET"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items, String current, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(current) ? current : items.first,
      isExpanded: true,
      items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _statusBadge(String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case "open": color = Colors.blue; break;
      case "resolved": color = Colors.green; break;
      case "closed": color = Colors.grey; break;
      case "in progress": color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        (status ?? "UNKNOWN").toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
