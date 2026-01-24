import 'dart:async';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/add_institute.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/view_institute_page.dart';
import 'package:flutter/material.dart';

import 'manage/manage_institute.dart';

// 1. Data Provider to fetch institute data
class InstituteProvider {
  // In the future, you will replace this with your actual API call
  Future<List<Institute>> fetchInstitutes() async {
    // Simulate a network delay to mimic an API call
    await Future.delayed(const Duration(seconds: 2));

    // This is where you would fetch your data from an API.
    return [
      Institute(
          name: "Global Tech Academy",
          code: "GTA2024",
          chairman: "Dr. Evelyn Reed",
          address: "123 Tech Park, Silicon Valley, CA 94043, USA",
          email: "contact@gta.edu",
          phone: "+1(555)123-4567",
          website: "www.globaltechacademy.edu",
          affiliation: "International Board of Education (IBE)",
          pan: "PUWPS1245"),
      Institute(
          name: "St. Xavier's High School",
          code: "SXHS01",
          chairman: "Mr. John Doe",
          address: "456 Edu Street, New Delhi, India",
          email: "contact@sxhs.edu.in",
          phone: "+91 11 2345 6789",
          website: "www.sxhs.edu.in",
          affiliation: "CBSE",
          pan: "ABCDE1234F"),
    ];
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

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterInstitutes);
  }

  Future<void> _fetchData() async {
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
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load institutes: \$e')),
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
    final newInstitute = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddNewInstitutePage(),
      ),
    );

    if (newInstitute != null && newInstitute is Institute && mounted) {
      setState(() {
        _allInstitutes.add(newInstitute);
        _filterInstitutes();
      });
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _navigateAndAdd,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B263B),
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
                                childAspectRatio: 2.2,
                              ),
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

class Institute {
  final String name;
  final String code;
  final String chairman;
  final String address;
  final String email;
  final String phone;
  final String website;
  final String affiliation;
  final String pan;

  Institute({
    required this.name,
    required this.code,
    required this.chairman,
    required this.address,
    required this.email,
    required this.phone,
    required this.website,
    required this.affiliation,
    required this.pan,
  });
}

class InstituteCard extends StatelessWidget {
  final Institute data;
  final bool isGridView;

  const InstituteCard(this.data, {super.key, this.isGridView = false});

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
            isGridView ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Row(
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Code: \${data.code}",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: responsiveFontSize(13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isGridView ? 20 : 16),
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
                                ViewInstitutePage(instituteId: data.code)));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  icon: Icons.settings_outlined,
                  label: "Manage",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ManageInstitute()));
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
            Icon(icon, color: Colors.white, size: responsiveFontSize(18)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: Colors.white, fontSize: responsiveFontSize(14))),
          ],
        ),
      ),
    );
  }
}
