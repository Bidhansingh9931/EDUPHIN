import 'dart:async';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/add_institute.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/view_institute_page.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import '../../institute/institute_model.dart';
import 'manage/manage_institute.dart';

// 1. Data Provider to fetch institute data
class InstituteProvider {
  Future<List<Institute>> fetchInstitutes() async {
    return ApiService.getInstitutes();
  }
}

class InstitutesPage extends StatefulWidget {
  const InstitutesPage({super.key});

  @override
  State<InstitutesPage> createState() => _InstitutesPageState();
}

class _InstitutesPageState extends State<InstitutesPage> {
  final InstituteProvider _provider = InstituteProvider();
  List<Institute> _allInstitutes = [];
  List<Institute> _filteredInstitutes = [];
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterInstitutes);
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _provider.fetchInstitutes();
      if (mounted) {
        setState(() {
          _allInstitutes = data;
          _filteredInstitutes = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load institutes: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterInstitutes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInstitutes = _allInstitutes.where((institute) {
        final nameLower = institute.name.toLowerCase();
        final codeLower = institute.code.toLowerCase();
        return nameLower.contains(query) || codeLower.contains(query);
      }).toList();
    });
  }

  void _navigateAndAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddNewInstitutePage(),
      ),
    );

    if (result == true && mounted) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Institutes"),
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            Padding(
              padding: context.pagePadding.copyWith(bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search by name or code...",
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _navigateAndAdd,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(theme)
                      : _filteredInstitutes.isEmpty
                          ? _buildEmptyState(theme)
                          : SingleChildScrollView(
                              padding: context.pagePadding,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredInstitutes.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      mainAxisExtent: 210,
                                    ),
                                    itemBuilder: (context, index) {
                                      return InstituteCard(data: _filteredInstitutes[index]);
                                    },
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("Connection Error", style: theme.textTheme.titleMedium),
          Text(_error ?? "Unknown error", style: TextStyle(color: theme.hintColor), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchData, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_rounded, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("No institutes found", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class InstituteCard extends StatelessWidget {
  final Institute data;

  const InstituteCard({super.key, required this.data});
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.greenAccent[400]!;
      case 'inactive': return Colors.redAccent[200]!;
      case 'pending': return Colors.orangeAccent[200]!;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school_rounded, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Code: ${data.code}",
                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(data.status)),
                ),
                const SizedBox(width: 8),
                Text(
                  data.status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(data.status), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ViewInstitutePage(instituteId: data.id.toString())));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("View Info", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageInstitute(
                            instituteId: data.id.toString(),
                            instituteName: data.name,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Manage", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
