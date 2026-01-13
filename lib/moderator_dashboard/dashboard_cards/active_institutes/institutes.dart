import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/add_institute.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/view_institute_page.dart';
import 'package:flutter/material.dart';

import 'manage/manage_institute.dart';

class InstitutesPage extends StatefulWidget {
  const InstitutesPage({super.key});

  @override
  State<InstitutesPage> createState() => _InstitutesPageState();
}

class _InstitutesPageState extends State<InstitutesPage> {
  final List<Institute> _allInstitutes = [
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
    // Add more institutes with complete data here
  ];
  final _searchController = TextEditingController();
  List<Institute> _filteredInstitutes = [];

  @override
  void initState() {
    super.initState();
    _filteredInstitutes = _allInstitutes;
    _searchController.addListener(_filterInstitutes);
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
        _filterInstitutes(); // Refresh the filtered list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- TOP BAR ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Active Institutes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- SEARCH + ADD BUTTON ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // SEARCH BAR
                  Expanded(
                    child: Container(
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
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search by name or code...",
                                hintStyle: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ADD BUTTON
                  GestureDetector(
                    onTap: _navigateAndAdd,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B263B),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // ---------- INSTITUTE LIST ----------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredInstitutes.length,
                itemBuilder: (context, index) {
                  return InstituteCard(_filteredInstitutes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// DATA MODEL
//
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

//
// CARD
//
class InstituteCard extends StatelessWidget {
  final Institute data;

  const InstituteCard(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E86D4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Code: ${data.code}",
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
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
                            builder: (_) => ViewInstitutePage(institute: data)));
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
                            builder: (_) =>
                            ManageInstitute()));
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

//
// BUTTON WIDGET
//
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
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
