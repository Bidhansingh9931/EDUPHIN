import 'package:flutter/material.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF00D1FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Employee List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Show entries", style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 12),
                    TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search Remarks",
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              _buildTableHeader(),
              const Divider(color: Colors.white10, height: 1),
              _buildEmployeeRow(1, "Rajveer K. Malhotra", "1", "raj@iias.com", "9812345678"),
              const Divider(color: Colors.white10, height: 1),
              _buildEmployeeRow(2, "Sneha Sharma", "2", "sneha@iias.com", "9876543210"),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.white.withValues(alpha: 0.02),
      child: const Row(
        children: [
          SizedBox(width: 30, child: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 3, child: Text("Employee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 4, child: Text("Contact Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(int index, String name, String id, String email, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 30, child: Text("$index", style: const TextStyle(color: Colors.white54, fontSize: 13))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("ID: $id", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: const TextStyle(color: secondaryColor, fontSize: 13)),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
