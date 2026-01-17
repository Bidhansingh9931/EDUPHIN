import 'package:flutter/material.dart';

import 'fee_details.dart';

// Data model for student fee details
class StudentFeeInfo {
  final String name;
  final String regNo;
  final String className;
  final String status;
  final String imageUrl;

  StudentFeeInfo({
    required this.name,
    required this.regNo,
    required this.className,
    required this.status,
    required this.imageUrl,
  });
}

class StudentFeeDetailsPage extends StatefulWidget {
  const StudentFeeDetailsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudentFeeDetailsPageState();
}

class _StudentFeeDetailsPageState extends State<StudentFeeDetailsPage> {
  String _selectClass = "Class 1";
  String _selectSection = "Section A";

  // Dummy data - replace with API call
  final List<StudentFeeInfo> _studentFeeDetails = [
    StudentFeeInfo(
      name: "Ananya Sharma",
      regNo: "S-1024",
      className: "10-A",
      status: "Active",
      imageUrl: "assets/images/random_boy.jpg",
    ),
    StudentFeeInfo(
      name: "Rohan Verma",
      regNo: "S-1025",
      className: "10-A",
      status: "Active",
      imageUrl: "assets/images/random_boy.jpg",
    ),
    StudentFeeInfo(
      name: "Priya Singh",
      regNo: "S-1026",
      className: "10-A",
      status: "Inactive",
      imageUrl: "assets/images/random_boy.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      DropDownBox(
                        key: ValueKey(_selectClass),
                        initialValue: _selectClass,
                        items: const [
                          "Class 1",
                          "Class 2",
                          "Class 3",
                          "Class 4",
                          "Class 5",
                          "Class 6",
                          "Class 7",
                          "Class 8",
                          "Class 9",
                          "Class 10",
                          "Class 11",
                          "Class 12"
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectClass = value;
                            });
                          }
                        },
                        hintText: "--Select Subject",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Section",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      DropDownBox(
                        key: ValueKey(_selectSection),
                        initialValue: _selectSection,
                        items: const [
                          "Section A",
                          "Section B",
                          "Section C",
                          "Section D",
                          "Section E",
                          "Section F"
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectSection = value;
                            });
                          }
                        },
                        hintText: "--Select Section",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _studentFeeDetails.length,
                itemBuilder: (context, index) {
                  final student = _studentFeeDetails[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomStudentInfoFeeDetailContainerBox(
                      heading: student.name,
                      subHeading: "Reg. No: ${student.regNo}, Class: ${student.className}",
                      isActive: student.status,
                      imageUrl: student.imageUrl,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropDownBox extends StatelessWidget {
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        initialValue: initialValue,
        isExpanded: true,
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}

class CustomStudentInfoFeeDetailContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String isActive;
  final String imageUrl;

  const CustomStudentInfoFeeDetailContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.isActive,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActiveStatus = isActive == "Active";

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
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image(
                      image: AssetImage(imageUrl),
                      height: 50,
                      width: 50,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(heading,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 20)),
                      Text(subHeading,
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary.withAlpha(150),
                              fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                      color: isActiveStatus
                          ? Colors.green.withAlpha(700)
                          : Colors.red.withAlpha(700),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        isActive,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeeDetailsPage(
                            studentName: heading,
                            studentDetails: subHeading
                          ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Fee Details",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
