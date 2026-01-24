import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/remarks.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/view_attendence.dart';
import 'package:flutter/material.dart';

// Data model for a Student
class Student {
  final String name;
  final String regNo;

  Student({required this.name, required this.regNo});
}

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  bool _isLoading = true;
  final List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    // Simulate API call to fetch students.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<Student> fetchedStudents = [
      Student(name: "Aarav Sharma", regNo: "S2023001"),
      Student(name: "Diya Patel", regNo: "S2023002"),
      Student(name: "Vihaan Singh", regNo: "S2023003"),
      Student(name: "Ananya Gupta", regNo: "S2023004"),
      Student(name: "Ishaan Kumar", regNo: "S2023005"),
      Student(name: "Riya Mishra", regNo: "S2023006"),
      Student(name: "Ankit Sharma", regNo: "S2023007"),
    ];

    if (mounted) {
      setState(() {
        _students.addAll(fetchedStudents);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Student List"),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              // Using LayoutBuilder to make the list responsive
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use GridView for wider screens (tablets, desktops)
                  if (constraints.maxWidth > 600) {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400, // Max width for each item
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5, // Adjust aspect ratio as needed
                      ),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return StudentCard(student: student);
                      },
                    );
                  } else {
                    // Use ListView for narrower screens (phones)
                    return ListView.separated(
                      itemCount: _students.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return StudentCard(student: student);
                      },
                    );
                  }
                },
              ),
            ),
    );
  }
}

// Widget for displaying a single student card
class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Better for GridView items
        children: [
          Text(
            student.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            "Reg No: ${student.regNo}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(35),
            ),
          ),
          const SizedBox(height: 12),
          // Using Expanded to make buttons responsive
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewAttendancePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    // Using theme colors for consistency
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("View Attendance"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RemarksPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    // Using theme colors for consistency
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add Remark"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
