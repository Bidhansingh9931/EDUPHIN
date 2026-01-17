import 'dart:ui';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/create_new_subject.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/edit_suject.dart';
import 'package:flutter/material.dart';

// Data model for a Subject
class Subject {
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final String credit;
  final String type;

  Subject({
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    required this.credit,
    required this.type,
  });
}

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({super.key});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  bool _isLoading = true;
  final List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    // Simulate API call to fetch subjects.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<Subject> fetchedSubjects = [
      Subject(
        name: "Financial Accounting Basics",
        description: "An introductory course covering the fundamentals of financial accounting principles and practices.",
        isActive: true,
        code: "FAB-101",
        credit: "4",
        type: "Theory",
      ),
      Subject(
        name: "Advanced Corporate Finance",
        description: "In-depth study of financial theories and their application to corporate financial policy and strategy.",
        isActive: false,
        code: "ACF-310",
        credit: "4",
        type: "Theory",
      ),
    ];

    if (mounted) {
      setState(() {
        _subjects.addAll(fetchedSubjects);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateNewSubjectPage()));
            },
            backgroundColor: theme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                SizedBox(width: 5),
                Text("Create New Subject"),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Subject List"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: ListView.separated(
                itemCount: _subjects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  return SubjectCard(subject: subject);
                },
              ),
            ),
    );
  }
}

// Widget for displaying a single subject card
class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = subject.isActive ? Colors.green : Colors.red;
    final statusText = subject.isActive ? "Active" : "Inactive";

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
                Expanded(
                  child: Text(
                    subject.name,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.colorScheme.onPrimary.withAlpha(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(statusText,
                        style: TextStyle(color: statusColor, fontSize: 16)),
                  ),
                )
              ],
            ),
            Text(subject.description,
                style: TextStyle(
                    color: theme.colorScheme.onPrimary.withAlpha(180),
                    fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Subject Code",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text("Credit",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text("Type",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subject.code,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        fontSize: 14)),
                Text(subject.credit,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        fontSize: 14)),
                Text(subject.type,
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        fontSize: 14)),
              ],
            ),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateSubjectPage()));
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 5),
                        Text("Edit",
                            style: TextStyle(color: Colors.blue, fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showDeleteDialog(context, subject.name),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 3),
                        Text("Delete",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                      ],
                    ),
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

void showDeleteDialog(BuildContext context, String subjectName) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSubjectDialog(
        subjectName: subjectName,
      );
    },
  );
}

class DeleteSubjectDialog extends StatelessWidget {
  final String subjectName;

  const DeleteSubjectDialog({
    super.key,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Subject",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete the subject: '$subjectName'? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Implement delete logic here
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}