import 'dart:async';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/add_institute.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/view_institute_page.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Active Institutes", style: TextStyle(fontSize: context.font(20))),
        actions: [
          IconButton(
            onPressed: _fetchData,
            icon: Icon(Icons.refresh_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
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
                      style: TextStyle(fontSize: context.font(14)),
                      decoration: InputDecoration(
                        hintText: "Search by name or code...",
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.scale(12)),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.scale(12)),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.scale(12)),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.md),
                  IconButton.filled(
                    onPressed: _navigateAndAdd,
                    icon: Icon(Icons.add_rounded, size: context.scale(24)),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      padding: EdgeInsets.all(context.scale(12)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.md),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState(context)
                      : _filteredInstitutes.isEmpty
                          ? _buildEmptyState(context)
                          : SingleChildScrollView(
                              padding: context.pagePadding,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: context.scale(1200)),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredInstitutes.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                      crossAxisSpacing: context.md,
                                      mainAxisSpacing: context.md,
                                      mainAxisExtent: context.scale(210),
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

  Widget _buildErrorState(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: context.scale(64), color: colorScheme.error.withValues(alpha: 0.5)),
          SizedBox(height: context.md),
          Text("Connection Error", style: theme.textTheme.titleMedium?.copyWith(fontSize: context.font(18), color: colorScheme.error)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.lg),
            child: Text(_error ?? "Unknown error", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14)), textAlign: TextAlign.center),
          ),
          SizedBox(height: context.scale(24)),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text("Retry", style: TextStyle(fontSize: context.font(16))),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_rounded, size: context.scale(64), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: context.md),
          Text("No institutes found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class InstituteCard extends StatelessWidget {
  final Institute data;

  const InstituteCard({super.key, required this.data});
  
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.greenAccent[400]!;
      case 'inactive': return colorScheme.error;
      case 'pending': return Colors.orangeAccent[400]!;
      default: return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(data.status, colorScheme);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  imageUrl: ApiService.getStorageUrl(data.logo),
                  radius: context.scale(24),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Code: ${data.code}",
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
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
                  width: context.scale(8),
                  height: context.scale(8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                ),
                SizedBox(width: context.scale(8)),
                Text(
                  data.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1.1),
                ),
              ],
            ),
            SizedBox(height: context.md),
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
                      side: BorderSide(color: colorScheme.outlineVariant),
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                    ),
                    child: Text("View Info", style: TextStyle(fontSize: context.font(12), color: colorScheme.primary)),
                  ),
                ),
                SizedBox(width: context.scale(8)),
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
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                    ),
                    child: Text("Manage", style: TextStyle(fontSize: context.font(12))),
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
