import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../cache_service.dart';
import '../super_admin_common_widgets.dart';
import 'add_moderators.dart';

class ModeratorListScreen extends StatefulWidget {
  const ModeratorListScreen({super.key});

  @override
  State<ModeratorListScreen> createState() => _ModeratorListScreenState();
}

class _ModeratorListScreenState extends State<ModeratorListScreen> {
  List<dynamic> _moderators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('moderator_list');
    if (cachedData != null && mounted) {
      setState(() {
        _moderators = cachedData;
        _isLoading = false;
      });
    }
    _fetchModerators();
  }

  Future<void> _fetchModerators() async {
    if (!mounted) return;
    if (_moderators.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getModerates();
      if (mounted) {
        setState(() {
          _moderators = data;
          _isLoading = false;
        });
        await SuperAdminCacheService.save('moderator_list', data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteModerator(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Moderator"),
        content: const Text("Are you sure you want to delete this moderator?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteModerate(id);
        _fetchModerators();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Moderators Management", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddModeratorScreen())).then((_) => _fetchModerators());
            },
            icon: Icon(Icons.person_add_alt, size: context.scale(24)),
            tooltip: "Add New Moderator",
          ),
        ],
      ),
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _moderators.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
          onRefresh: _fetchModerators,
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
                                Icon(Icons.list, color: theme.colorScheme.primary, size: context.scale(20)),
                                SizedBox(width: context.scale(8)),
                                Text("Moderator Directory",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                              ],
                            ),
                            SizedBox(height: context.scale(4)),
                            Text("View and manage all registered moderators.",
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
          child: SuperAdminSkeleton(height: context.scale(400)),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = context.theme;
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
            DataColumn(label: Text("Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
          ],
          rows: _moderators.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final mod = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(13)))),
                DataCell(
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.scale(4)),
                    child: ProfileAvatar(
                      radius: context.scale(18),
                      imageUrl: mod['photo'] != null
                          ? ApiService.getStorageUrl(mod['photo'])
                          : null,
                      borderWidth: 0,
                    ),
                  ),
                ),
                DataCell(Text(mod['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(13)))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blue, size: context.scale(20)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddModeratorScreen(moderator: mod))).then((_) => _fetchModerators());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red, size: context.scale(20)),
                        onPressed: () => _deleteModerator(mod['id'].toString()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
