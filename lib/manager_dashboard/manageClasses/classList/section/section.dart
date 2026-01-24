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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateNewSectionPage()));
        },
        label: const Text("Create New Section"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _sections.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5, // Adjust for content
                    ),
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return SectionCard(section: section);
                    },
                  );
                } else {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), 
                    itemCount: _sections.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return SectionCard(section: section);
                    },
                  );
                }
              },
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(section.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Class Limit",
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: Colors.green.shade300)),
                  Text(section.limit.toString(),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: theme.colorScheme.onPrimary)),
                ],
              )
            ],
          ),
          Text("Mentor: ${section.mentor}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
          const SizedBox(height: 12),
          Divider(
            color: theme.colorScheme.onPrimary.withAlpha(180),
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditSectionPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StudentListPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer),
                  icon: const Icon(Icons.people_alt_outlined, size: 16),
                  label: const Text("Students", overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showDeleteDialog(context, section.name),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                ),
              ),
            ],
          ),
        ],
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete Section",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this section: $sectionName? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(35),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Implement delete logic here
                      Navigator.pop(context);
                    },
                    child: const Text("Yes, Delete"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                       side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
