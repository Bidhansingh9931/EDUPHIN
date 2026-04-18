import 'package:eduphin/services/common_widgets.dart';
import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class CounselorPage extends StatefulWidget {
  const CounselorPage({super.key});

  @override
  State<CounselorPage> createState() => _CounselorPageState();
}

class _CounselorPageState extends State<CounselorPage> {
  bool _isLoading = true;
  List<UserDetail> _counselors = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCounselors();
  }

  Future<void> _fetchCounselors() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/users/4');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final List usersData = data['data'] ?? data['users'] ?? [];
            _counselors = usersData.map((json) => UserDetail.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load counselors";
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
        title: Text("Counselors Directory", style: TextStyle(fontSize: context.font(20))),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: context.font(14))),
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
                              hintText: "Search counselors...",
                              prefixIcon: Icon(Icons.search, size: context.scale(20)),
                              hintStyle: TextStyle(fontSize: context.font(14)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _fetchCounselors,
                            child: _counselors.isEmpty
                                ? ListView(
                                    children: [
                                      SizedBox(height: context.screenHeight * 0.2),
                                      Center(
                                        child: Text(
                                          "No counselors found",
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
                                    itemCount: _counselors.length,
                                    itemBuilder: (context, index) {
                                      final counselor = _counselors[index];
                                      final displayName = counselor.fullName;

                                      return Card(
                                        elevation: 0,
                                        margin: EdgeInsets.zero,
                                        color: theme.colorScheme.surfaceContainerLow,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(context.scale(12)),
                                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                                        ),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                          contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
                                          leading: ProfileAvatar(
                                            radius: context.scale(24),
                                            imageUrl: ApiService.getStorageUrl(counselor.photo),
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
                                                counselor.employeeId != null ? 'ID: ${counselor.employeeId}' : 'ID: N/A',
                                                style: TextStyle(color: theme.hintColor, fontSize: context.font(12)),
                                              ),
                                              if (counselor.email != null)
                                                Text(
                                                  counselor.email!,
                                                  style: TextStyle(color: theme.hintColor, fontSize: context.font(11)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                          trailing: _statusBadge(context, counselor.status ?? "Active"),
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
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(9), fontWeight: FontWeight.bold),
      ),
    );
  }

}
