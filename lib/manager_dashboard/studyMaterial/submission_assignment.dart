import 'package:flutter/material.dart';

class AssignmentSubmissionsScreen extends StatefulWidget {
  const AssignmentSubmissionsScreen({super.key});

  @override
  State<AssignmentSubmissionsScreen> createState() =>
      _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState
    extends State<AssignmentSubmissionsScreen> {
  final List<Map<String, dynamic>> submissions = [
    {
      "name": "Rahul Sharma",
      "fileName": "Uploaded PDF",
      "hasFile": true,
      "typedAnswer":
      "The answer is provided in the attached document. Please refer to it for the detailed solution...",
      "submittedOn": "18 Nov 2025, 10:30 AM",
      "grade": "85 / 100",
      "remarks": "Good effort. Some calculations need review.",
      "graded": true
    },
    {
      "name": "Priya Patel",
      "fileName": "No File",
      "hasFile": false,
      "typedAnswer":
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      "submittedOn": "19 Nov 2025, 09:15 PM",
      "grade": "Not Graded",
      "remarks": "Awaiting review.",
      "graded": false
    },
    {
      "name": "Anjali Verma",
      "fileName": "Solution.pdf",
      "hasFile": true,
      "typedAnswer": "No typed answer provided.",
      "submittedOn": "20 Nov 2025, 11:50 AM",
      "grade": "45 / 100",
      "remarks":
      "Incomplete submission. Please follow the instructions carefully next time.",
      "graded": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Submissions for Assignment 1",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          return buildSubmissionCard(submissions[index]);
        },
      ),
    );
  }

  Widget buildSubmissionCard(Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff0F1A2B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Student Name
          Text(
            s["name"],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          // FILE TILE
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff162238),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  s["hasFile"] ? Icons.insert_drive_file : Icons.close,
                  color: s["hasFile"] ? Colors.blueAccent : Colors.grey,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    s["fileName"],
                    style: TextStyle(
                      color: s["hasFile"]
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                ),

                Icon(
                  Icons.download_outlined,
                  color: s["hasFile"]
                      ? Colors.white
                      : Colors.transparent,
                )
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text("Typed Answer",
              style: TextStyle(color: Colors.white54, fontSize: 12)),

          const SizedBox(height: 6),

          Text(
            s["typedAnswer"],
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),

          if (s["typedAnswer"].length > 50)
            const Text(
              "Read more",
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
            ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: info("Submitted On", s["submittedOn"]),
              ),
              Expanded(
                child: info(
                  "Grade",
                  s["grade"],
                  graded: s["graded"],
                  fail: s["graded"] && s["grade"].startsWith("4"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          info("Remarks", s["remarks"]),
        ],
      ),
    );
  }

  Widget info(String label, String value,
      {bool graded = false, bool fail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label\n",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: graded
                    ? fail
                    ? Colors.redAccent
                    : Colors.greenAccent
                    : Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
