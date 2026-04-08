import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class RemarksPage extends StatefulWidget {
  const RemarksPage({super.key});

  @override
  State<RemarksPage> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedRemarkType = "All";
  List<Map<String, dynamic>> _allRemarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRemarks();
    // Re-build whenever user types in the search bar
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRemarks() async {
    setState(() => _isLoading = true);
    try {
      final remarks = await ApiService.getStudentRemarks();
      setState(() {
        _allRemarks = remarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _resetFilters() {
    setState(() {
      selectedRemarkType = "All";
      _searchController.clear();
    });
  }

  // Reactive filtering logic
  List<Map<String, dynamic>> get _filteredRemarks {
    return _allRemarks.where((remark) {
      // 1. Type Filter
      bool matchesType = true;
      if (selectedRemarkType != "All") {
        final rType = (remark['type'] ?? remark['category'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        matchesType = rType == selectedRemarkType.toLowerCase().trim();
      }

      // 2. Search Filter (checks remark text and teacher name)
      bool matchesSearch = true;
      final query = _searchController.text.toLowerCase().trim();
      if (query.isNotEmpty) {
        final content = (remark['remark'] ?? '').toString().toLowerCase();
        final teacher = (remark['teacher']?['name'] ?? 'Faculty').toString().toLowerCase();
        matchesSearch = content.contains(query) || teacher.contains(query);
      }

      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRemarks;

    return Scaffold(
      backgroundColor: const Color(0xff0B1230),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Faculty Remarks", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRemarks,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _fetchRemarks,
                color: Colors.blueAccent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= FILTER CARD =================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff1E2746),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.filter_alt, color: Colors.blueAccent),
                                SizedBox(width: 10),
                                Text(
                                  "Filter Remarks",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Search Field
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search remarks or faculty...",
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xff0B1230),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xff0B1230),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: const Color(0xff1E2746),
                                  value: selectedRemarkType,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                                  isExpanded: true,
                                  items: ["All", "Academic", "Discipline", "Attendance", "Behavior"]
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e, style: const TextStyle(color: Colors.white)),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => selectedRemarkType = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _resetFilters,
                                child: const Text("RESET FILTERS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ================= REMARK HISTORY =================
                      Row(
                        children: [
                          const Icon(Icons.history, color: Colors.white70, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "History (${filtered.length})",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      filtered.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: const Color(0xff1E2746).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.notes, color: Colors.white24, size: 48),
                                  SizedBox(height: 10),
                                  Text("No remarks found matching your criteria", style: TextStyle(color: Colors.white38)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildRemarkItem(filtered[index]);
                              },
                            )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRemarkItem(Map<String, dynamic> remark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1E2746),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (remark['type'] ?? 'General').toString().toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              Text(
                _formatDate(remark['created_at']),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remark['remark'] ?? "No content provided",
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_pin, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              Text(
                "By: ${remark['teacher']?['name'] ?? 'Faculty'}",
                style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
