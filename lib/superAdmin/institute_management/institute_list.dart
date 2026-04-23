import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../moderator_dashboard/institute/institute_model.dart';
import '../cache_service.dart';
import '../super_admin_common_widgets.dart';
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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('institute_list');
    if (cachedData != null && mounted) {
      final List<Institute> institutes = (cachedData as List).map((e) => Institute.fromJson(e)).toList();
      setState(() {
        _institutes = institutes;
        _filteredInstitutes = institutes;
        _isLoading = false;
      });
    }
    _fetchInstitutes();
  }

  Future<void> _fetchInstitutes() async {
    if (!mounted) return;
    if (_institutes.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final institutes = await ApiService.getSuperAdminInstitutes();
      if (mounted) {
        setState(() {
          _institutes = institutes;
          _filteredInstitutes = institutes;
          _isLoading = false;
        });
        await SuperAdminCacheService.save('institute_list', institutes.map((e) => e.toJson()).toList());
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
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Institutes Overview", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddInstituteScreen())).then((_) => _fetchInstitutes());
            },
            icon: Icon(Icons.add_circle_outline, size: context.scale(24)),
            tooltip: "Add New Institute",
          ),
        ],
      ),
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _institutes.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
          onRefresh: _fetchInstitutes,
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildFilterSection(context),
                    SizedBox(height: context.spacing),
                    _buildInstituteDirectory(context),
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
      child: Column(
        children: [
          SuperAdminSkeleton(height: context.scale(150)),
          SizedBox(height: context.spacing),
          SuperAdminSkeleton(height: context.scale(300)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = context.theme;
    final states = ["All States", ..._institutes.map((e) => e.state).toSet().toList()];

    return Card(
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
                Icon(Icons.filter_alt, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(8)),
                Text("Filter Institutes",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              ],
            ),
            SizedBox(height: context.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(context, "Filter by State", states, _selectedState, (v) {
                          setState(() => _selectedState = v!);
                          _filterInstitutes();
                        }),
                      ),
                      SizedBox(width: context.spacing),
                      SizedBox(
                        height: context.scale(48),
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
                  );
                }
                return Column(
                  children: [
                    _buildDropdownFilter(context, "Filter by State", states, _selectedState, (v) {
                      setState(() => _selectedState = v!);
                      _filterInstitutes();
                    }),
                    SizedBox(height: context.spacing),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
        SizedBox(height: context.scale(8)),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildInstituteDirectory(BuildContext context) {
    final theme = context.theme;
    return Card(
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
                Text("Institute Directory",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              ],
            ),
            SizedBox(height: context.scale(4)),
            Text("Manage all registered institutes within the system.",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
            SizedBox(height: context.spacing),
            TextField(
              controller: _searchController,
              onChanged: (v) => _filterInstitutes(),
              style: TextStyle(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "Search by Name or Code",
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                contentPadding: EdgeInsets.all(context.scale(12)),
              ),
            ),
            SizedBox(height: context.spacing),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = context.theme;
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
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
              DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
              DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
            ],
            rows: _filteredInstitutes.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final inst = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(13)))),
                  DataCell(
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => InstituteDetailsScreen(instituteId: inst.id.toString())));
                      },
                      child: Text(inst.name, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(13))),
                    ),
                  ),
                  DataCell(Text(inst.code, style: TextStyle(fontStyle: FontStyle.italic, fontSize: context.font(13)))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
