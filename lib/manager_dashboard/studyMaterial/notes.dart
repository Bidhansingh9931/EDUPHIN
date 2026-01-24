import 'package:flutter/material.dart';

// Data model for Study Material
class StudyMaterial {
  final String title;
  final String className; // "class" is a reserved keyword in Dart
  final String section;
  final String uploadedBy;
  final String date;

  StudyMaterial({
    required this.title,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.date,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      title: json['title'],
      className: json['class'],
      section: json['section'],
      uploadedBy: json['uploadedBy'],
      date: json['date'],
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? selectedClass;
  String? selectedSection;

  List<String> classes = [];
  List<String> sections = [];
  List<StudyMaterial> allMaterials = [];
  List<StudyMaterial> filteredMaterials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // TODO: Replace this with your actual API call in the future
  Future<void> _fetchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data from your original code
    final List<String> fetchedClasses = [
      "Class 6", "Class 7", "Class 8", "Class 9", "Class 10", "Class 11", "Class 12"
    ];
    final List<String> fetchedSections = ["Section A", "Section B", "Section C"];
    final List<Map<String, dynamic>> fetchedMaterialsData = [
      {
        "title": "Algebraic Expressions",
        "class": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "date": "12 Nov 2025"
      },
      {
        "title": "Introduction to Trigonometry",
        "class": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "date": "10 Nov 2025"
      },
      {
        "title": "Chemical Reactions and Equations",
        "class": "Class 10",
        "section": "Section B", // Changed to show filtering
        "uploadedBy": "Mrs. Gupta",
        "date": "05 Nov 2025"
      },
      {
        "title": "The Rise of Nationalism in Europe",
        "class": "Class 9", // Changed to show filtering
        "section": "Section A",
        "uploadedBy": "Ms. Singh",
        "date": "01 Nov 2025"
      },
      {
        "title": "Life Processes in Biology",
        "class": "Class 10",
        "section": "Section A",
        "uploadedBy": "Dr. Verma",
        "date": "28 Oct 2025"
      },
    ];

    if (mounted) {
      setState(() {
        classes = fetchedClasses;
        sections = fetchedSections;
        allMaterials = fetchedMaterialsData.map((data) => StudyMaterial.fromJson(data)).toList();

        if (classes.isNotEmpty) selectedClass = "Class 10";
        if (sections.isNotEmpty) selectedSection = "Section A";

        _filterMaterials();
        isLoading = false;
      });
    }
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = allMaterials.where((material) {
        final matchClass = selectedClass == null || material.className == selectedClass;
        final matchSection = selectedSection == null || material.section == selectedSection;
        return matchClass && matchSection;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          "Study Material List",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildFilterSection(theme),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return _buildGridView();
                      } else {
                        return _buildListView();
                      }
                    }),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(theme, "Select Class *", selectedClass, classes, (v) {
              if (v != null) {
                setState(() => selectedClass = v);
                _filterMaterials();
              }
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(theme, "Select Section *", selectedSection, sections, (v) {
              if (v != null) {
                setState(() => selectedSection = v);
                _filterMaterials();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(35))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: theme.cardColor,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildListView() {
    return filteredMaterials.isNotEmpty
        ? ListView.separated(
            padding: const EdgeInsets.only(bottom: 50),
            itemCount: filteredMaterials.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index]),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }

  Widget _buildGridView() {
    return filteredMaterials.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.only(bottom: 50),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8, // Adjust this for card height
            ),
            itemCount: filteredMaterials.length,
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index]),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }
}

class _StudyMaterialCard extends StatelessWidget {
  final StudyMaterial material;

  const _StudyMaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // For better grid alignment
        children: [
          // Tag + Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${material.className} - ${material.section}",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                material.date,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(35),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            material.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Uploaded by: ${material.uploadedBy}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(35),
            ),
          ),
        ],
      ),
    );
  }
}
