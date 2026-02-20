import 'dart:async';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/add_institute.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/view_institute_page.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Active Institutes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveFontSize(14)),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search by name or code...",
                                hintStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: responsiveFontSize(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _navigateAndAdd,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: const Color(0xFF1B263B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Error: $_error",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: responsiveFontSize(14)),
                            ),
                          ),
                        )
                      : _filteredInstitutes.isEmpty
                          ? Center(
                              child: Text(
                              "No institutes found.",
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: responsiveFontSize(14)),
                            ))
                          : LayoutBuilder(builder: (context, constraints) {
                              if (constraints.maxWidth > 600) {
                                int crossAxisCount = constraints.maxWidth > 1200
                                    ? 4
                                    : (constraints.maxWidth > 900 ? 3 : 2);
                                return GridView.builder(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  itemCount: _filteredInstitutes.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 2.4,                                  ),
                                  itemBuilder: (context, index) {
                                    return InstituteCard(
                                      _filteredInstitutes[index],
                                      isGridView: true,
                                    );
                                  },
                                );
                              } else {
                                return ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04),
                                  itemCount: _filteredInstitutes.length,
                                  itemBuilder: (context, index) {
                                    return InstituteCard(
                                      _filteredInstitutes[index],
                                      isGridView: false,
                                    );
                                  },
                                );
                              }
                            }),
            ),
          ],
        ),
      ),
    );
  }
}

class InstituteCard extends StatelessWidget {
  final Institute data;
  final bool isGridView;

  const InstituteCard(this.data, {super.key, this.isGridView = false});
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'inactive':
        return Colors.red.shade600;
      case 'pending':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Container(
      margin: isGridView ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isGridView ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E86D4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school,
                    color: Colors.white, size: responsiveFontSize(26)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Code: ${data.code}",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: responsiveFontSize(13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isGridView ? 12 : 16),
          Row(
            children: [
              Text(
                "Status: ",
                style: TextStyle(
                    color: Colors.white70, fontSize: responsiveFontSize(13)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(data.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.status.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveFontSize(11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.visibility_outlined,
                  label: "View",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ViewInstitutePage(instituteId: data.id.toString())));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.settings_outlined,
                  label: "Manage",
                  onTap: () {
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: responsiveFontSize(16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: responsiveFontSize(13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
