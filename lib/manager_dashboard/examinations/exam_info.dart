// import 'dart:ui';

import 'package:eduphin/manager_dashboard/examinations/create_new_exam.dart';
import 'package:eduphin/manager_dashboard/examinations/edit_exam.dart';
import 'package:flutter/material.dart';

class Exam {
  final String heading;
  final String subHeading;
  final String type;
  final String examCode;
  final String isActive;
  final String startEndDate;

  Exam({
    required this.heading,
    required this.subHeading,
    required this.type,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
  });
}

class ExamInfoPage extends StatefulWidget {
  const ExamInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamInfoPageState();
}

class _ExamInfoPageState extends State<ExamInfoPage> {
  final List<Exam> _exams = [
    Exam(
      heading: "#1",
      subHeading: "Mid-Term Examination 2025",
      type: "Objective",
      examCode: "MTE-2025-01",
      isActive: "Active",
      startEndDate: "15 Dec 2025 - 22 Dec 2025",
    ),
    Exam(
      heading: "#2",
      subHeading: "Final Examination 2024",
      type: "Written",
      examCode: "FE-2024-02",
      isActive: "Inactive",
      startEndDate: "1 Jun 2025 - 10 Jun 2025",
    ),
    Exam(
      heading: "#3",
      subHeading: "Unit Test - 1 (Science)",
      type: "Objective",
      examCode: "UT1-SCI-2025",
      isActive: "Active",
      startEndDate: "20 Oct 2025 - 20 Oct 2025",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateExamScreen()));
            },
            backgroundColor: Colors.blue.shade900,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_sharp,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Create New Exam",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Exam List"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: ListView.separated(
          itemCount: _exams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final exam = _exams[index];
            return CustomExamListContainerBox(
              heading: exam.heading,
              subHeading: exam.subHeading,
              type: exam.type,
              examCode: exam.examCode,
              isActive: exam.isActive,
              startEndDate: exam.startEndDate,
            );
          },
        ),
      ),
    );
  }
}

class CustomExamListContainerBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final String type;
  final String examCode;
  final String isActive;
  final String startEndDate;

  const CustomExamListContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.type,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(heading,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(150),
                        fontSize: 14)),
                Container(
                    decoration: BoxDecoration(
                      color: isActiveStatus ? Colors.green : Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        isActive,
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
            Text(subHeading,
                style:
                    TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type",
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary.withAlpha(150),
                            fontSize: 14)),
                    Text(type,
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Exam Code",
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary.withAlpha(150),
                            fontSize: 14)),
                    Text(examCode,
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Start Date - End Date",
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(150),
                        fontSize: 14)),
                Text(startEndDate,
                    style: const TextStyle(color: Colors.blue, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditExamPage(
                                  // Assuming EditExamPage takes these parameters.
                                  examName: subHeading,
                                  examType: type,
                                  examCode: examCode,
                                  isActive: isActive == "Active",
                                  startEndDate: startEndDate,
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withAlpha(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Edit",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Manage Schedule",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
