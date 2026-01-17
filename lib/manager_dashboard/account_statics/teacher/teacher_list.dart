import 'package:flutter/material.dart';

import 'add_teacher.dart';

class Teacher {
  final String name;
  final String designation;

  Teacher({required this.name, required this.designation});
}

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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddTeacherPage()));
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
        body: const Padding(
          padding: EdgeInsets.only(bottom: 115),
          child: SingleChildScrollView(
            child: Column(children: [
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

  List<Teacher> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  // TODO: Implement API call to fetch teachers
  Future<void> _fetchTeachers() async {
    // For now, using hardcoded data.
    // Replace this with your API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Teacher> newTeachers = [
      Teacher(name: "Rohan Mehra", designation: "Principal"),
      Teacher(name: "Sunita Williams", designation: "Vice Principal"),
      Teacher(name: "Anjali Sharma", designation: "Academic Head"),
      Teacher(name: "Vikram Rathore", designation: "Admissions Officer"),
      Teacher(name: "Priya Kapoor", designation: "HR Manager"),
      Teacher(name: "Amit Dessai", designation: "Finance Manager"),
      Teacher(name: "Sneha Verma", designation: "IT Head"),
      Teacher(name: "Rajesh Kumar", designation: "Operations Manager"),
      Teacher(name: "Deepa Singh", designation: "Librarian"),
    ];

    setState(() {
      _teachers.addAll(newTeachers);
      _isLoading = false;
    });
  }

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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _teachers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final teacher = _teachers[index];
              return Container(
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
                            teacher.name,
                            style: TextStyle(
                                fontSize: 16, color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher.designation,
                            style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onPrimary.withAlpha(180)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
