import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffStudentFeeDetailPage extends StatefulWidget {
  const StaffStudentFeeDetailPage({super.key});

  @override
  State<StaffStudentFeeDetailPage> createState() => _StaffStudentFeeDetailPageState();
}

class _StaffStudentFeeDetailPageState extends State<StaffStudentFeeDetailPage> {
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);
  static const Color primaryColor = Color(0xFF6C63FF);

  final TextEditingController _searchController = TextEditingController();
  StudentFeeDetail? _feeDetail;
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchDetail() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _feeDetail = null;
    });

    try {
      final detail = await ApiService.getStaffStudentFeeDetail(_searchController.text.trim());
      setState(() {
        _feeDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Student Fee Detail", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBox(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
            else if (_feeDetail != null) ...[
              _buildStudentInfo(_feeDetail!),
              const SizedBox(height: 20),
              _buildFeeSummary(_feeDetail!),
            ] else
              const Center(child: Text("Enter Student ID to search details", style: TextStyle(color: Colors.white38))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (_) => _fetchDetail(),
        decoration: InputDecoration(
          hintText: "Search Student ID...",
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send_rounded, color: primaryColor),
            onPressed: _fetchDetail,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStudentInfo(StudentFeeDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.studentName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text("Roll No: ${detail.rollNo}", style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text("Class: ${detail.className}", style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFeeSummary(StudentFeeDetail detail) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white),
                SizedBox(width: 12),
                Text("Fee Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ...detail.fees.map((fee) => _buildFeeItem(fee.title, "₹${fee.amount}", fee.status)).toList(),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String amount, String status) {
    bool isPaid = status.toLowerCase() == 'paid';
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(amount, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
      trailing: Text(status.toUpperCase(), style: TextStyle(color: isPaid ? Colors.greenAccent : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
