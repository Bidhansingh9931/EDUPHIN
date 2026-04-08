import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/my_class_model.dart';
import 'package:flutter/material.dart';
import 'class_models.dart';

class ClassesDetailsPage extends StatefulWidget {
  const ClassesDetailsPage({super.key});

  @override
  State<ClassesDetailsPage> createState() => _ClassesDetailsPageState();
}

class _ClassesDetailsPageState extends State<ClassesDetailsPage> {
  late Future<MyClassData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getMyClassData();
  }

  void _showSectionsDialog(
      BuildContext context, TeacherClass teacherClass, List<Schedule> schedules) {
    final theme = Theme.of(context);
    final classSections = schedules
        .where((schedule) => schedule.classInfo?.id == teacherClass.id)
        .map((schedule) => schedule.sectionInfo)
        .where((section) => section != null)
        .toSet() 
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sections in ${teacherClass.name}"),
          content: SizedBox(
            width: double.maxFinite,
            child: classSections.isEmpty
                ? const Center(child: Text("No sections found for this class."))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: classSections.length,
                    itemBuilder: (BuildContext context, int index) {
                      final section = classSections[index]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(section.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Capacity: ${section.capacity ?? 'N/A'}"),
                        ),
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Classes"),
      ),
      body: FutureBuilder<MyClassData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: context.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(snapshot.error.toString(), style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => setState(() => _dataFuture = ApiService.getMyClassData()),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final schedules = snapshot.data!.schedules;
              final uniqueClasses = schedules
                  .where((schedule) => schedule.classInfo != null)
                  .map((schedule) => schedule.classInfo!)
                  .toSet()
                  .toList();

              if (uniqueClasses.isEmpty) {
                return const Center(child: Text("No classes found."));
              }

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text("#")),
                        DataColumn(label: Text("Class Name")),
                        DataColumn(label: Text("Code")),
                        DataColumn(label: Text("Level")),
                        DataColumn(label: Text("Sections")),
                      ],
                      rows: uniqueClasses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final teacherClass = entry.value;
                        return DataRow(cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(teacherClass.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(teacherClass.code, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(Text(teacherClass.level ?? 'N/A')),
                          DataCell(TextButton.icon(
                            onPressed: () => _showSectionsDialog(context, teacherClass, schedules),
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            label: const Text("VIEW"),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: Text("No classes found."));
            }
          }),
    );
  }
}
