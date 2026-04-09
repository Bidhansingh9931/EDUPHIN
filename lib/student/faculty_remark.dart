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

  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

  @override
  void initState() {
    super.initState();
    _fetchRemarks();
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

  List<Map<String, dynamic>> get _filteredRemarks {
    return _allRemarks.where((remark) {
      bool matchesType = true;
      if (selectedRemarkType != "All") {
        final rType = (remark['type'] ?? remark['category'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        matchesType = rType == selectedRemarkType.toLowerCase().trim();
      }

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Faculty Remarks",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchRemarks,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _primary))
            : RefreshIndicator(
                onRefresh: _fetchRemarks,
                color: _primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= FILTER CARD =================
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.filter_list, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Search Remarks",
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            const Text("Search Query", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search content or faculty name...",
                                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                                filled: true,
                                fillColor: _secondary,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            const Text("Remark Category", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: _secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: _card,
                                  value: selectedRemarkType,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                                  isExpanded: true,
                                  items: ["All", "Academic", "Discipline", "Attendance", "Behavior"]
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _resetFilters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text("RESET FILTERS", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // ================= REMARK HISTORY =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Remark History",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${filtered.length} entries",
                              style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      filtered.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.notes, color: Colors.white10, size: 64),
                                  const SizedBox(height: 16),
                                  const Text("No remarks found", style: TextStyle(color: Colors.white38, fontSize: 16)),
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
    final category = (remark['type'] ?? 'General').toString();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
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
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _primary.withValues(alpha: 0.5)),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              Text(
                _formatDate(remark['created_at']),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            remark['remark'] ?? "No content provided",
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white70, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Faculty Member", style: TextStyle(color: Colors.white38, fontSize: 11)),
                    Text(
                      remark['teacher']?['name'] ?? 'Faculty Member',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
