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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FloatingActionButton.extended(
                heroTag: 'addTeacherBtn',
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddTeacherPage()));
                },
                label: Text(
                  "Add Teacher",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
              ),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Teacher List",
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
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
          padding: EdgeInsets.fromLTRB(16, 16, 16, 50),
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

    if (mounted) {
      setState(() {
        _teachers.addAll(newTeachers);
        _isLoading = false;
      });
    }
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
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
              : LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildTeacherList(theme);
              } else {
                return _buildTeacherGrid(theme);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherList(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _teachers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final teacher = _teachers[index];
        return _buildTeacherTile(teacher, theme);
      },
    );
  }

  Widget _buildTeacherGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _teachers.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 4, // Adjust aspect ratio as needed
      ),
      itemBuilder: (context, index) {
        final teacher = _teachers[index];
        return _buildTeacherTile(teacher, theme);
      },
    );
  }

  Widget _buildTeacherTile(Teacher teacher, ThemeData theme) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  teacher.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacher.designation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(200),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
