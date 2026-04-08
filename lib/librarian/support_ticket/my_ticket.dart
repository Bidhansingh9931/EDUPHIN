import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'create_ticket.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  String selectedPriority = "All Priorities";
  String selectedStatus = "All Statuses";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Support Tickets"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Column(
                    children: [
                      /// FILTER SECTION
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildResponsiveRow(context, [
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Search by Title...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                                _buildDropdown(selectedPriority, ["All Priorities", "Low", "Medium", "High"], (val) {
                                  setState(() => selectedPriority = val!);
                                }),
                              ]),
                              const SizedBox(height: 12),
                              _buildDropdown(selectedStatus, ["All Statuses", "Open", "Closed", "Pending"], (val) {
                                setState(() => selectedStatus = val!);
                              }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// DATA TABLE SECTION
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text("Recent Tickets", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            const Divider(height: 1),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                columnSpacing: 25,
                                columns: const [
                                  DataColumn(label: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Category", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: [
                                  _buildDataRow(context, "10", "System Access", "Low", "Open", "Technical"),
                                  _buildDataRow(context, "7", "Network Error", "High", "Closed", "Technical"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// BOTTOM BUTTON
              Padding(
                padding: context.pagePadding,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("CREATE NEW TICKET"),
                ),
              ),
            ],
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

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  DataRow _buildDataRow(BuildContext context, String id, String title, String priority, String status, String category) {
    return DataRow(cells: [
      DataCell(Text(id)),
      DataCell(Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(_buildBadge(priority)),
      DataCell(_buildBadge(status)),
      DataCell(Text(category)),
      DataCell(IconButton(
        icon: const Icon(Icons.visibility_outlined, size: 20),
        onPressed: () {},
      )),
    ]);
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}
