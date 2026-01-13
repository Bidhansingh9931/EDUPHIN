import 'package:flutter/material.dart';

import 'add_teacher.dart';



class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<StatefulWidget> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FloatingActionButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTeacherPage()));
              },child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: theme.colorScheme.onSurface,),
                  const SizedBox(width: 2,),
                  Text("Add Teacher",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                ],
              ),)),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Teacher List",
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.download,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 115),
          child: SingleChildScrollView(
            child: const Column(children: [
              CustomTeacherListBox(),
            ]),
          ),
        ));
  }
}

class CustomTeacherListBox extends StatefulWidget {
  const CustomTeacherListBox({super.key});

  @override
  State<CustomTeacherListBox> createState() => _CustomTeacherListBoxState();
}

class _CustomTeacherListBoxState extends State<CustomTeacherListBox> {
  String? _selectedTeacher = "All Teacher";
  final List<String> _teacherTypes = [
    "All Teacher",
    "Teacher Manager",
    "Teacher Manager new",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedTeacher,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTeacher = newValue;
                });
              },
              items: _teacherTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.menu_open_sharp, color: theme.colorScheme.onPrimary), // Prefix icon
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rohan Mehra",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Principal",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sunita Williams",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vice Principal",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Anjali Sharma",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Academic Head",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vikram Rathore",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Admissions Officer",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Priya Kapoor",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "HR Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amit Dessai",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Finance Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sneha Verma",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "IT Head",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rajesh Kumar",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Operations Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deepa Singh",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Librarian",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}