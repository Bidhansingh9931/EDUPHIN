import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/caching_service.dart';

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
    _loadCachedRemarks();
    _fetchRemarks();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadCachedRemarks() async {
    final cached = await CacheService.getData('student_remarks');
    if (cached != null && mounted) {
      setState(() {
        _allRemarks = List<Map<String, dynamic>>.from(cached as List);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRemarks() async {
    if (!mounted) return;
    if (_allRemarks.isEmpty) setState(() => _isLoading = true);
    try {
      final remarks = await ApiService.getStudentRemarks();
      if (mounted) {
        setState(() {
          _allRemarks = remarks;
          _isLoading = false;
        });
        CacheService.saveData('student_remarks', remarks);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (_allRemarks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $e"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
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
    final theme = context.theme;
    final filtered = _filteredRemarks;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Faculty Remarks",
          style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: context.scale(24)),
            onPressed: _fetchRemarks,
          ),
        ],
      ),
      body: SafeArea(
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _allRemarks.isNotEmpty,
          skeleton: const _RemarksSkeleton(),
          onRefresh: _fetchRemarks,
          child: RefreshIndicator(
            onRefresh: _fetchRemarks,
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: context.pagePadding,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= FILTER CARD =================
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.scale(16)),
                          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        color: theme.colorScheme.surfaceContainerLow,
                        child: Padding(
                          padding: EdgeInsets.all(context.scale(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.filter_list, color: theme.colorScheme.primary, size: context.scale(22)),
                                  SizedBox(width: context.scale(12)),
                                  Text(
                                    "Search Remarks",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(18),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.scale(24)),

                              LayoutBuilder(builder: (context, constraints) {
                                final double spacing = context.scale(16);
                                final bool isMobile = constraints.maxWidth < 600;
                                final double width = isMobile 
                                  ? constraints.maxWidth 
                                  : (constraints.maxWidth - spacing) / 2;

                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: [
                                    SizedBox(
                                      width: width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Search Query", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                                          SizedBox(height: context.scale(8)),
                                          TextField(
                                            controller: _searchController,
                                            style: TextStyle(fontSize: context.font(14)),
                                            decoration: InputDecoration(
                                              hintText: "Search content or faculty...",
                                              prefixIcon: Icon(Icons.search, size: context.scale(20)),
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                                              filled: true,
                                              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Remark Category", style: TextStyle(fontSize: context.font(12), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                                          SizedBox(height: context.scale(8)),
                                          DropdownButtonFormField<String>(
                                            initialValue: selectedRemarkType,
                                            style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurface),
                                            items: ["All", "Academic", "Discipline", "Attendance", "Behavior"]
                                                .map((e) => DropdownMenuItem(
                                                      value: e,
                                                      child: Text(e, style: TextStyle(fontSize: context.font(14))),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() => selectedRemarkType = value);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                                              filled: true,
                                              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              SizedBox(height: context.scale(24)),
                              Row(
                                children: [
                                  const Spacer(flex: 2),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _resetFilters,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        foregroundColor: theme.colorScheme.onSurface,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                        padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                                      ),
                                      child: Text("RESET", style: TextStyle(fontSize: context.font(14))),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: context.scale(32)),

                      // ================= REMARK HISTORY =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Remark History",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: context.font(18),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(context.scale(20)),
                            ),
                            child: Text(
                              "${filtered.length} entries",
                              style: TextStyle(color: theme.colorScheme.primary, fontSize: context.font(12), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(20)),

                      filtered.isEmpty
                          ? Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.scale(16)),
                                side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              color: theme.colorScheme.surfaceContainerLow,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: context.scale(80)),
                                child: Column(
                                  children: [
                                    Icon(Icons.notes, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                    SizedBox(height: context.scale(16)),
                                    Text("No remarks found", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                                  ],
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                                crossAxisSpacing: context.scale(16),
                                mainAxisSpacing: context.scale(16),
                                mainAxisExtent: context.scale(240),
                              ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildRemarkItem(Map<String, dynamic> remark) {
    final theme = context.theme;
    final category = (remark['type'] ?? 'General').toString();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(5)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(10)),
                  ),
                ),
                Text(
                  _formatDate(remark['created_at']),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                ),
              ],
            ),
            SizedBox(height: context.scale(16)),
            Expanded(
              child: Text(
                remark['remark'] ?? "No content provided",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: context.font(14),
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: context.scale(12)),
            Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            SizedBox(height: context.scale(12)),
            Row(
              children: [
                ProfileAvatar(
                  imageUrl: ApiService.getStorageUrl(remark['teacher']?['photo']),
                  radius: context.scale(16),
                  borderWidth: 0,
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Faculty Member", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(10))),
                      Text(
                        remark['teacher']?['name'] ?? 'Faculty Member',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(13),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _RemarksSkeleton extends StatelessWidget {
  const _RemarksSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: context.scale(250), width: double.infinity, borderRadius: context.scale(16)),
              SizedBox(height: context.scale(32)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(height: context.scale(24), width: context.scale(150), borderRadius: context.scale(4)),
                  SkeletonBox(height: context.scale(30), width: context.scale(80), borderRadius: context.scale(20)),
                ],
              ),
              SizedBox(height: context.scale(20)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                  crossAxisSpacing: context.scale(16),
                  mainAxisSpacing: context.scale(16),
                  mainAxisExtent: context.scale(240),
                ),
                itemCount: 4,
                itemBuilder: (context, index) => SkeletonBox(
                  height: context.scale(240),
                  width: double.infinity,
                  borderRadius: context.scale(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
