import 'package:eduphin/manager_dashboard/studyMaterial/submission_assignment.dart';
import 'package:flutter/material.dart';

// --- Data Models ---

class Assignment {
  final String title;
  final String subject;
  final String className;
  final String section;
  final String uploadedBy;
  final String uploadedDate;
  final String dueDate;

  Assignment({
    required this.title,
    required this.subject,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.uploadedDate,
    required this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      title: json['title'] as String,
      subject: json['subject'] as String,
      className: json['className'] as String,
      section: json['section'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedDate: json['uploadedDate'] as String,
      dueDate: json['dueDate'] as String,
    );
  }
}


class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  String? selectedClass;
  String? selectedSection;

  bool isLoading = true;
  List<String> classes = [];
  List<String> sections = [];
  List<Assignment> allAssignments = [];
  Map<String, List<Assignment>> filteredAssignments = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // TODO: Replace this with your actual API call in the future
  Future<void> _fetchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data from your original code, now structured for a dynamic list
    final List<String> fetchedClasses = [
      "Class 6", "Class 7", "Class 8", "Class 9", "Class 10", "Class 11", "Class 12"
    ];
    final List<String> fetchedSections = ["Section A", "Section B", "Section C"];
    final List<Map<String, dynamic>> fetchedAssignmentsData = [
      // Class 10, Section A
      {
        "title": "Algebraic Equations",
        "subject": "Mathematics",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "20 Nov 2025"
      },
      {
        "title": "Polynomials",
        "subject": "Mathematics",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "22 Nov 2025"
      },
      {
        "title": "Light - Reflection and Refraction",
        "subject": "Science",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mrs. Gupta",
        "uploadedDate": "10 Nov 2025",
        "dueDate": "18 Nov 2025"
      },
      // Class 10, Section B
      {
        "title": "Federalism",
        "subject": "Social Studies",
        "className": "Class 10",
        "section": "Section B",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "15 Nov 2025"
      },
      {
        "title": "Sectors of the Indian Economy",
        "subject": "Social Studies",
        "className": "Class 10",
        "section": "Section B",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "17 Nov 2025"
      },
      // Class 9, Section A
      {
        "title": "Number Systems",
        "subject": "Mathematics",
        "className": "Class 9",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "01 Nov 2025",
        "dueDate": "10 Nov 2025"
      }
    ];

    if (mounted) {
      setState(() {
        classes = fetchedClasses;
        sections = fetchedSections;
        allAssignments = fetchedAssignmentsData.map((data) => Assignment.fromJson(data)).toList();

        // Set initial filter values
        selectedClass = "Class 10";
        selectedSection = "Section A";

        _filterAssignments();
        isLoading = false;
      });
    }
  }

  void _filterAssignments() {
    final filtered = allAssignments.where((assignment) {
      final matchClass = selectedClass == null || assignment.className == selectedClass;
      final matchSection = selectedSection == null || assignment.section == selectedSection;
      return matchClass && matchSection;
    }).toList();

    final Map<String, List<Assignment>> grouped = {};
    for (var assignment in filtered) {
      if (!grouped.containsKey(assignment.subject)) {
        grouped[assignment.subject] = [];
      }
      grouped[assignment.subject]!.add(assignment);
    }

    setState(() {
      filteredAssignments = grouped;
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
        title: const Text("Assignments", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        children: [
          // FILTER CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff0F1A2B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Class *", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedClass,
                  dropdownColor: const Color(0xff101820),
                  style: const TextStyle(color: Colors.white),
                  decoration: dropdownStyle(),
                  items: classes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedClass = v);
                      _filterAssignments();
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text("Select Section *", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedSection,
                  dropdownColor: const Color(0xff101820),
                  style: const TextStyle(color: Colors.white),
                  decoration: dropdownStyle(),
                  items: sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedSection = v);
                      _filterAssignments();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // SUBJECT SECTIONS
          if (filteredAssignments.isNotEmpty)
            ...filteredAssignments.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    entry.key, // Subject Name
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...entry.value.map((a) => buildAssignmentCard(a)), // List of assignments
                ],
              );
            })
          else
             const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "No assignments found for the selected filters.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget buildAssignmentCard(Assignment a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff0F1A2B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.title,
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: info("Uploaded by", a.uploadedBy),
              ),
              Expanded(
                child: info("Uploaded Date", a.uploadedDate),
              ),
            ],
          ),
          const SizedBox(height: 4),
          info("Due Date", a.dueDate),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AssignmentSubmissionsScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2D9CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("View Submission", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label\n",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
