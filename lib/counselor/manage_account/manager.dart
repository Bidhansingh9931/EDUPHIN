import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
import '../counselor_models.dart';

class InstituteManagerPage extends StatefulWidget {
  const InstituteManagerPage({super.key});

  @override
  State<InstituteManagerPage> createState() => _InstituteManagerPageState();
}

class _InstituteManagerPageState extends State<InstituteManagerPage> {
  bool _isLoading = true;
  List<UserDetail> _managers = [];
  String? _errorMessage;
  final String _cacheKey = 'counselor_manage_manager_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchManagers();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      final List usersData = cachedData['data'] ?? cachedData['users'] ?? [];
      setState(() {
        _managers = usersData.map((json) => UserDetail.fromJson(json)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchManagers() async {
    if (_managers.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/users/3');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          setState(() {
            final List usersData = data['data'] ?? data['users'] ?? [];
            _managers = usersData.map((json) => UserDetail.fromJson(json)).toList();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted) {
          if (_managers.isEmpty) {
            setState(() {
              _errorMessage = ErrorHandler.getMessage("Status: ${response.statusCode}");
              _isLoading = false;
            });
          }
          ErrorHandler.showError(context, "Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        if (_managers.isEmpty) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage(e);
            _isLoading = false;
          });
        }
        ErrorHandler.showError(context, e);
      }
    }
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        children: [
          const Skeleton(width: double.infinity, height: 50),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                mainAxisExtent: context.scale(110),
                crossAxisSpacing: context.spacing,
                mainAxisSpacing: context.spacing,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Skeleton(width: 50, height: 50, borderRadius: 25),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Skeleton(width: 120, height: 16),
                            const SizedBox(height: 8),
                            const Skeleton(width: 80, height: 12),
                          ],
                        ),
                      ),
                      const Skeleton(width: 60, height: 24, borderRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Institute Managers", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchManagers,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _managers.isNotEmpty,
          error: _errorMessage,
          skeleton: _buildSkeleton(),
          onRetry: _fetchManagers,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  Padding(
                    padding: context.pagePadding,
                    child: TextField(
                      style: TextStyle(fontSize: context.font(14)),
                      decoration: InputDecoration(
                        hintText: "Search managers...",
                        prefixIcon: Icon(Icons.search, size: context.scale(20)),
                        hintStyle: TextStyle(fontSize: context.font(14)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _managers.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: context.screenHeight * 0.2),
                              Center(
                                child: Text(
                                  "No managers found",
                                  style: TextStyle(color: theme.hintColor, fontSize: context.font(14)),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: context.pagePadding,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                              mainAxisExtent: context.scale(110),
                              crossAxisSpacing: context.spacing,
                              mainAxisSpacing: context.spacing,
                            ),
                            itemCount: _managers.length,
                            itemBuilder: (context, index) {
                              final manager = _managers[index];
                              final displayName = manager.fullName;

                              return Card(
                                elevation: 0,
                                color: theme.colorScheme.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                  contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
                                  leading: ProfileAvatar(
                                    radius: context.scale(25),
                                    imageUrl: (manager.photo != null && manager.photo!.isNotEmpty) ? ApiService.getStorageUrl(manager.photo) : null,
                                    borderWidth: 0,
                                  ),
                                  title: Text(
                                    displayName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        manager.employeeId != null ? 'ID: ${manager.employeeId}' : 'ID: N/A',
                                        style: TextStyle(color: theme.hintColor, fontSize: context.font(12)),
                                      ),
                                      if (manager.email != null)
                                        Text(
                                          manager.email!,
                                          style: TextStyle(color: theme.hintColor, fontSize: context.font(11)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                  trailing: _statusBadge(context, manager.status ?? "Active"),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final normalizedStatus = status.toLowerCase();
    final isLive = normalizedStatus == 'active' || normalizedStatus == 'live' || normalizedStatus == '1';
    final color = isLive ? Colors.green : Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(9), fontWeight: FontWeight.bold),
      ),
    );
  }
}

