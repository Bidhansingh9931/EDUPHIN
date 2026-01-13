import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/remarks.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/view_attendence.dart';
import 'package:flutter/material.dart';

class StudentListPage extends StatefulWidget{
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text("Student List"),
            Spacer(),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        child: SingleChildScrollView(
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aarav Sharma",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023001", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAttendancePage()));
                      },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withAlpha(55),
                            foregroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("View Attendance")),
                      const SizedBox(width: 8),
                      Spacer(),
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RemarksPage()));
                      },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.withAlpha(35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Add Remark")),
                  ]
            ),
          ],
          ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diya Patel",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023002", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vihaan Singh",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023003", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ananya Gupta",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023004", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ishaan Kumar",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023005", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Riya Mishra",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023006", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ankit Sharma",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 1),
                  Text("Reg No: S2023007", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Row(
                      children: [
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(55),
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("View Attendance")),
                        const SizedBox(width: 8),
                        Spacer(),
                        ElevatedButton(onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add Remark")),
                      ]
                  ),
                ],
              ),
            ),
              ]
              ),
        ),
      ),
    );
  }
}