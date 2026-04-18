import 'package:eduphin/services/common_widgets.dart';
import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/users/3');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final List usersData = data['data'] ?? data['users'] ?? [];
            _managers = usersData.map((json) => UserDetail.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load managers";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Institute Managers", style: TextStyle(fontSize: context.font(20))),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.scale(24.0)),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                  ),
                )
              : Center(
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
                          child: RefreshIndicator(
                            onRefresh: _fetchManagers,
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
                        ),
                      ],
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
