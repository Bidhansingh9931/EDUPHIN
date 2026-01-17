import 'dart:ui';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/edit_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/student_list.dart';
import 'package:flutter/material.dart';

// Data model for a Section
class Section {
  final String name;
  final String mentor;
  final int limit;

  Section({required this.name, required this.mentor, required this.limit});
}

class SectionsPage extends StatefulWidget {
  const SectionsPage({super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  bool _isLoading = true;
  final List<Section> _sections = [];

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    // Simulate API call to fetch sections.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<Section> fetchedSections = [
      Section(name: "Section A", mentor: "Mrs. Anjali Sharma", limit: 40),
      Section(name: "Section B", mentor: "Mr. Vikram Singh", limit: 42),
      Section(name: "Section C", mentor: "Ms. Priya Kumari", limit: 38),
      Section(name: "Section D", mentor: "Mr. Rajeev Mehta", limit: 41),
    ];

    if (mounted) {
      setState(() {
        _sections.addAll(fetchedSections);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to a page to create a new section
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateNewSectionPage()));
            },
            backgroundColor: theme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                SizedBox(width: 5),
                Text("Create New Section"),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Sections for Class VIII"),
            Icon(Icons.menu),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
              child: ListView.separated(
                itemCount: _sections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  return SectionCard(section: section);
                },
              ),
            ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Section section;

  const SectionCard({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(section.name, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
                const Padding(
                  padding: EdgeInsets.all(3),
                  child: Text("Class Limit", style: TextStyle(color: Colors.green, fontSize: 16)),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mentor: ${section.mentor}", style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 14)),
                Text(section.limit.toString(), style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditSectionPage()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 4),
                        Text("Edit"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentListPage()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(45)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_outlined, color: theme.colorScheme.onPrimary, size: 16),
                        const SizedBox(width: 4),
                        Flexible(child: Text("Students", style: TextStyle(color: theme.colorScheme.onPrimary), overflow: TextOverflow.ellipsis,)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showDeleteDialog(context, section.name),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Flexible(child: Text("Delete", style: TextStyle(color: Colors.red))),
                      ],
                    ),
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

void showDeleteDialog(BuildContext context, String sectionName) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSectionDialog(
        sectionName: sectionName,
      );
    },
  );
}

class DeleteSectionDialog extends StatelessWidget {
  final String sectionName;

  const DeleteSectionDialog({
    super.key,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Section",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete this section: $sectionName? "
                    "This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Implement delete logic here
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
