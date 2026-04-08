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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counselors Directory"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search counselors...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchCounselors,
                        child: _counselors.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(child: Text("No counselors found", style: TextStyle(color: theme.hintColor))),
                                ],
                              )
                            : GridView.builder(
                                padding: context.pagePadding,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: context.isTablet ? 2 : 1,
                                  mainAxisExtent: 110,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _counselors.length,
                                itemBuilder: (context, index) {
                                  final counselor = _counselors[index];
                                  final displayName = counselor.fullName;

                                  return Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        backgroundImage: (counselor.photo != null && counselor.photo!.isNotEmpty)
                                            ? NetworkImage("${ApiService.baseImageUrl}/${counselor.photo}")
                                            : null,
                                        child: (counselor.photo == null || counselor.photo!.isEmpty)
                                            ? Text(
                                                displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        displayName, 
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            counselor.employeeId != null ? 'ID: ${counselor.employeeId}' : 'ID: N/A', 
                                            style: TextStyle(color: theme.hintColor, fontSize: 12)
                                          ),
                                          if (counselor.email != null)
                                            Text(
                                              counselor.email!,
                                              style: TextStyle(color: theme.hintColor, fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                      trailing: _statusBadge(counselor.status ?? "Active"),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _statusBadge(String status) {
    final normalizedStatus = status.toLowerCase();
    final isLive = normalizedStatus == 'active' || normalizedStatus == 'live' || normalizedStatus == '1';
    final color = isLive ? Colors.green : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
