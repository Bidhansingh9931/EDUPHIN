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
        child: ListView.separated(
          itemCount: _classes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final classInfo = _classes[index];
            return ClassCard(classInfo: classInfo);
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(classInfo.name, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.onPrimary.withAlpha(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(classInfo.category, style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
                    ),
                  )
                ],
              ),
              Text(classInfo.description, style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 14)),
              const SizedBox(height: 8),
              Divider(
                color: theme.colorScheme.onPrimary.withAlpha(180),
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Code", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text("Total Sections", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(classInfo.code, style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 14)),
                  Text(classInfo.totalSections, style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 14)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}