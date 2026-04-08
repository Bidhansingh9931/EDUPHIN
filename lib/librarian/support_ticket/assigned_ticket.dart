import 'package:flutter/material.dart';

class AssignedTicketsPage extends StatefulWidget {
  const AssignedTicketsPage({super.key});

  @override
  State<AssignedTicketsPage> createState() => _AssignedTicketsPageState();
}

class _AssignedTicketsPageState extends State<AssignedTicketsPage> {
  static const Color bgColor = Color(0xFF0B0D18);
  static const Color cardColor = Color(0xFF1B2238);
  static const Color fieldColor = Color(0xFF323B5C);
  static const Color blueBtn = Color(0xFF2563EB);

  String selectedPriority = "All Priorities";
  String selectedStatus = "All Statuses";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const Icon(Icons.assignment_outlined, color: Colors.white, size: 24),
        title: const Text("Assigned Tickets",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// FILTER SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  buildSearchField(),
                  const SizedBox(height: 12),
                  buildDropdown(selectedPriority, ["All Priorities", "Low", "Medium", "High"], (val) {
                    setState(() => selectedPriority = val!);
                  }),
                  const SizedBox(height: 12),
                  buildDropdown(selectedStatus, ["All Statuses", "Open", "Closed", "Pending"], (val) {
                    setState(() => selectedStatus = val!);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DATA TABLE SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFF2D3748)),
                      columnSpacing: 25,
                      columns: const [
                        DataColumn(label: Text("#ID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Issue By", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Priority", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Created At", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Action", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        buildDataRow("4", "Nisha\nRao", "Issue with\nFee\nPayment\nPortal", "Low", "Open", "Payment\nProblem", "09 Oct, 2025"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.speaker_notes_outlined, color: Colors.white, size: 18),
                        label: const Text("VIEW/REPLY", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(8)),
      child: const TextField(
        style: TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search by Title...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: fieldColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  DataRow buildDataRow(String id, String by, String title, String priority, String status, String category, String date) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(by, style: const TextStyle(color: Colors.white, fontSize: 13))),
      DataCell(Text(title, style: const TextStyle(color: Colors.white, fontSize: 13))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
        child: Text(priority, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
        child: Text(status, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      )),
      DataCell(Text(category, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      DataCell(Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Open", style: TextStyle(color: Colors.white70, fontSize: 11)),
            Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 14),
          ],
        ),
      )),
    ]);
  }
}