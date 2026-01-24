import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:flutter/material.dart';

// Data model for a class
class ClassInfo {
  final String name;
  final String description;
  final String category;
  final String code;
  final String totalSections;

  ClassInfo({
    required this.name,
    required this.description,
    required this.category,
    required this.code,
    required this.totalSections,
  });
}

class ClassListPage extends StatefulWidget {
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  bool _isLoading = true;
  final List<ClassInfo> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    // Simulate API call to fetch classes.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<ClassInfo> fetchedClasses = [
      ClassInfo(name: "Class VIII", description: "Class for 8th grade students", category: "Secondary", code: "C-VIII", totalSections: "4"),
      ClassInfo(name: "Class IX", description: "Class for 9th grade students", category: "Secondary", code: "C-IX", totalSections: "5"),
      ClassInfo(name: "Class X", description: "Class for 10th grade students", category: "Sr. Sec", code: "C-X", totalSections: "4"),
      ClassInfo(name: "Class XI", description: "Class for 11th grade students", category: "Sr. Sec", code: "C-XI", totalSections: "6"),
      ClassInfo(name: "Class V", description: "Class for 5th grade students", category: "Primary", code: "C-V", totalSections: "3"),
      ClassInfo(name: "B.Com", description: "Batchelor of Commerce", category: "Graduation", code: "BCOM-1", totalSections: "2"),
    ];

    if (mounted) {
      setState(() {
        _classes.addAll(fetchedClasses);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Class List"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        // Using LayoutBuilder for a responsive layout that adapts to screen size
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For wider screens, use a GridView for better space utilization
            if (constraints.maxWidth > 600) {
              return GridView.builder(
                itemCount: _classes.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400, // Max width of each grid item
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.8, // Adjust for desired card shape
                ),
                itemBuilder: (context, index) {
                  final classInfo = _classes[index];
                  return ClassCard(classInfo: classInfo);
                },
              );
            } else {
              // For narrower screens, use a ListView
              return ListView.separated(
                itemCount: _classes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final classInfo = _classes[index];
                  return ClassCard(classInfo: classInfo);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

// Widget for displaying a single class card
class ClassCard extends StatelessWidget {
  final ClassInfo classInfo;

  const ClassCard({super.key, required this.classInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SectionsPage())),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.primaryColor,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Center content in grid view
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Using theme for scalable and consistent text styles
                Expanded(
                  child: Text(classInfo.name,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: theme.colorScheme.onPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Using a theme-aware color
                    color: theme.colorScheme.secondary.withAlpha(35),
                  ),
                  child: Text(classInfo.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 4),
            Text(classInfo.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(35))),
            const SizedBox(height: 12),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(35),
              thickness: 1,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(theme, "Code", classInfo.code),
                _buildInfoColumn(theme, "Total Sections", classInfo.totalSections,
                    crossAxisAlignment: CrossAxisAlignment.end),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper widget to reduce code duplication for info columns
  Widget _buildInfoColumn(ThemeData theme, String label, String value,
      {CrossAxisAlignment? crossAxisAlignment}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(35))),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onPrimary)),
      ],
    );
  }
}
