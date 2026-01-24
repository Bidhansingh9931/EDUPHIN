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
        // Changed bottom padding to 50 as requested
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
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
                        // Using theme for scalable font
                        style: theme.textTheme.titleMedium,
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
                        // Using theme for scalable font
                        style: theme.textTheme.titleMedium,
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
              // Using LayoutBuilder for responsive list/grid
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Use GridView for wider screens
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 500, // Max width for each item
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.5, // Adjust for content
                      ),
                      itemCount: _studentFeeDetails.length,
                      itemBuilder: (context, index) {
                        final student = _studentFeeDetails[index];
                        return CustomStudentInfoFeeDetailContainerBox(
                          heading: student.name,
                          subHeading: "Reg. No: ${student.regNo}, Class: ${student.className}",
                          isActive: student.status,
                          imageUrl: student.imageUrl,
                        );
                      },
                    );
                  } else {
                    // Use ListView for narrower screens
                    return ListView.builder(
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
                    );
                  }
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
    final theme = Theme.of(context);
    return DropdownButtonFormField(
        initialValue: initialValue,
        isExpanded: true,
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
           enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image(
                    image: AssetImage(imageUrl),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading,
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary)),
                    Text(subHeading,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(150))),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    color: isActiveStatus
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      isActive,
                      style:
                          theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ))
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            // Removed fixed height to make button responsive
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
                  // Using theme color for button
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Fee Details",
                  // Using theme for scalable font
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSecondary),
                )),
          ),
        ],
      ),
    );
  }
}
