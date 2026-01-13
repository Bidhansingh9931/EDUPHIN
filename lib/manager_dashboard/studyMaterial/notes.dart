import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() =>
      _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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

  final List<String> sections = [
    "Section A",
    "Section B",
    "Section C",
  ];

  final List<Map<String, dynamic>> materials = [
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
      "section": "Section A",
      "uploadedBy": "Mrs. Gupta",
      "date": "05 Nov 2025"
    },
    {
      "title": "The Rise of Nationalism in Europe",
      "class": "Class 10",
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

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
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

          const SizedBox(height: 20),

          // ---------- Study Material List ----------
          ...materials.map((m) => buildMaterialCard(m)),
        ],
      ),
    );
  }

  Widget buildMaterialCard(Map<String, dynamic> m) {
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
                  "${m['class']} - ${m['section']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),

              Text(
                m["date"],
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )
            ],
          ),

          const SizedBox(height: 12),

          Text(
            m["title"],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Uploaded by: ${m['uploadedBy']}",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
