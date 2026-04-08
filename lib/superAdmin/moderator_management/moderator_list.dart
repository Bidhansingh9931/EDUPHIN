import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
    _fetchModerators();
  }

  Future<void> _fetchModerators() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getModerates();
      if (mounted) {
        setState(() {
          _moderators = data;
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moderators Management"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddModeratorScreen())).then((_) => _fetchModerators());
            },
            icon: const Icon(Icons.person_add_alt),
            tooltip: "Add New Moderator",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchModerators,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list, color: Theme.of(context).colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                const Text("Moderator Directory",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("View and manage all registered moderators.",
                                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                            const SizedBox(height: 16),
                            _buildTable(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (context.isTablet ? 100 : 64)),
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Photo", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _moderators.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final mod = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: mod['photo'] != null
                          ? NetworkImage("${ApiService.baseUrl}/storage/${mod['photo']}")
                          : null,
                      child: mod['photo'] == null ? Icon(Icons.person, color: theme.colorScheme.primary, size: 18) : null,
                    ),
                  ),
                ),
                DataCell(Text(mod['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddModeratorScreen(moderator: mod))).then((_) => _fetchModerators());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
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
