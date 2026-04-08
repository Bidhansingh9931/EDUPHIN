import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  bool _isLoading = true;
  List<UserDetail> _staffMembers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/users/9');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final List usersData = data['data'] ?? data['users'] ?? [];
            _staffMembers = usersData.map((json) => UserDetail.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load staff";
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
        title: const Text("Staff Directory"),
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
                          hintText: "Search staff...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchStaff,
                        child: _staffMembers.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(child: Text("No staff members found", style: TextStyle(color: theme.hintColor))),
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
                                itemCount: _staffMembers.length,
                                itemBuilder: (context, index) {
                                  final staff = _staffMembers[index];
                                  final displayName = staff.fullName;
                                  
                                  return Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        backgroundImage: (staff.photo != null && staff.photo!.isNotEmpty)
                                            ? NetworkImage("${ApiService.baseImageUrl}/${staff.photo}") 
                                            : null,
                                        child: (staff.photo == null || staff.photo!.isEmpty)
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
                                            staff.employeeId != null ? 'ID: ${staff.employeeId}' : 'ID: N/A', 
                                            style: TextStyle(color: theme.hintColor, fontSize: 12)
                                          ),
                                          if (staff.email != null)
                                            Text(
                                              staff.email!,
                                              style: TextStyle(color: theme.hintColor, fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                      trailing: _statusBadge(staff.status ?? "Active"),
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
