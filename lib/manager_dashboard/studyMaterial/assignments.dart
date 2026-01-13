import 'package:eduphin/manager_dashboard/studyMaterial/submission_assignment.dart';
import 'package:flutter/material.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  String selectedClass = "Class 10";
  String selectedSection = "Section A";

  final List<String> classes = [
    "Class 6",
    "Class 7",
    "Class 8",
    "Class 9",
    "Class 10",
    "Class 11",
    "Class 12"
  ];

  final List<String> sections = ["Section A", "Section B", "Section C"];

  final Map<String, List<Map<String, String>>> assignments = {
    "Mathematics": [
      {
        "title": "Assignment 1",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "20 Nov 2025"
      },
      {
        "title": "Assignment 2",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "22 Nov 2025"
      }
    ],
    "Science": [
      {
        "title": "Assignment 1",
        "uploadedBy": "Mrs. Gupta",
        "uploadedDate": "10 Nov 2025",
        "dueDate": "18 Nov 2025"
      }
    ],
    "Social Studies": [
      {
        "title": "Assignment 1",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "15 Nov 2025"
      },
      {
        "title": "Assignment 2",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "17 Nov 2025"
      }
    ]
  };

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
        title: const Text("Assignments",
            style: TextStyle(color: Colors.white)),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
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
                const Text("Select Class *",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),

                DropdownButtonFormField(
                  initialValue: selectedClass,
                  dropdownColor: const Color(0xff101820),
                  style: const TextStyle(color: Colors.white),
                  decoration: dropdownStyle(),
                  items: classes
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedClass = v!),
                ),

                const SizedBox(height: 16),

                const Text("Select Section *",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),

                DropdownButtonFormField(
                  initialValue: selectedSection,
                  dropdownColor: const Color(0xff101820),
                  style: const TextStyle(color: Colors.white),
                  decoration: dropdownStyle(),
                  items: sections
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedSection = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SUBJECT SECTIONS
          ...assignments.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Text(
                  entry.key,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),

                const SizedBox(height: 10),

                ...entry.value.map((a) => buildAssignmentCard(a)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildAssignmentCard(Map<String, String> a) {
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
            a["title"]!,
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
                child: info("Uploaded by", a["uploadedBy"]!),
              ),
              Expanded(
                child: info("Uploaded Date", a["uploadedDate"]!),
              ),
            ],
          ),

          const SizedBox(height: 4),

          info("Due Date", a["dueDate"]!),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AssignmentSubmissionsScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2D9CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("View Submission",style: TextStyle(color: Colors.white)),
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
