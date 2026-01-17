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
      "Class 6",
      "Class 7",
      "Class 8",
      "Class 9",
      "Class 10",
      "Class 11",
      "Class 12"
    ];
    final List<String> fetchedSections = [
      "Section A",
      "Section B",
      "Section C",
    ];
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
        allMaterials = fetchedMaterialsData
            .map((data) => StudyMaterial.fromJson(data))
            .toList();

        // Set initial filter values
        if (classes.isNotEmpty) {
          selectedClass = "Class 10";
        }
        if (sections.isNotEmpty) {
          selectedSection = "Section A";
        }

        _filterMaterials();
        isLoading = false;
      });
    }
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = allMaterials.where((material) {
        final matchClass =
            selectedClass == null || material.className == selectedClass;
        final matchSection =
            selectedSection == null || material.section == selectedSection;
        return matchClass && matchSection;
      }).toList();
    });
  }

  InputDecoration dropdownStyle() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xff101820),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Study Material List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              children: [
                // ---------- Filters Card ----------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0F1A2B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Class *",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClass,
                        dropdownColor: const Color(0xff101820),
                        style: const TextStyle(color: Colors.white),
                        decoration: dropdownStyle(),
                        items: classes
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              selectedClass = v;
                            });
                            _filterMaterials();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text("Select Section *",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedSection,
                        dropdownColor: const Color(0xff101820),
                        style: const TextStyle(color: Colors.white),
                        decoration: dropdownStyle(),
                        items: sections
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              selectedSection = v;
                            });
                            _filterMaterials();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ---------- Study Material List ----------
                if (filteredMaterials.isNotEmpty)
                  ...filteredMaterials.map((m) => buildMaterialCard(m))
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No study material found for the selected filters.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget buildMaterialCard(StudyMaterial m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff0F1A2B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag + Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${m.className} - ${m.section}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Text(
                m.date,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            m.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Uploaded by: ${m.uploadedBy}",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}