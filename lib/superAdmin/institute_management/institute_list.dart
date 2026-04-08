import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../moderator_dashboard/institute/institute_model.dart';
import 'add_institute.dart';
import 'institute_details.dart';

class InstituteListScreen extends StatefulWidget {
  const InstituteListScreen({super.key});

  @override
  State<InstituteListScreen> createState() => _InstituteListScreenState();
}

class _InstituteListScreenState extends State<InstituteListScreen> {
  List<Institute> _institutes = [];
  List<Institute> _filteredInstitutes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedState = "All States";

  @override
  void initState() {
    super.initState();
    _fetchInstitutes();
  }

  Future<void> _fetchInstitutes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final institutes = await ApiService.getSuperAdminInstitutes();
      if (mounted) {
        setState(() {
          _institutes = institutes;
          _filteredInstitutes = institutes;
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

  void _filterInstitutes() {
    setState(() {
      _filteredInstitutes = _institutes.where((inst) {
        final matchesSearch = inst.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            inst.code.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesState = _selectedState == "All States" || inst.state == _selectedState;
        return matchesSearch && matchesState;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Institutes Overview"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddInstituteScreen())).then((_) => _fetchInstitutes());
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add New Institute",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInstitutes,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    _buildFilterSection(context),
                    const SizedBox(height: 24),
                    _buildInstituteDirectory(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    final states = ["All States", ..._institutes.map((e) => e.state).toSet().toList()];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Filter Institutes",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownFilter(context, "Filter by State", states, _selectedState, (v) {
              setState(() => _selectedState = v!);
              _filterInstitutes();
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedState = "All States";
                    _searchController.clear();
                  });
                  _filterInstitutes();
                },
                child: const Text("RESET FILTERS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildInstituteDirectory(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Institute Directory",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Manage all registered institutes within the system.",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (v) => _filterInstitutes(),
              decoration: const InputDecoration(
                hintText: "Search by Name or Code",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            _buildTable(context),
          ],
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
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredInstitutes.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final inst = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InstituteDetailsScreen(instituteId: inst.id.toString())));
                    },
                    child: Text(inst.name, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                DataCell(Text(inst.code, style: const TextStyle(fontStyle: FontStyle.italic))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
