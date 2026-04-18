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
    final theme = context.theme;
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
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
          ),
          title: Text("Sections in ${teacherClass.name}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
          content: SizedBox(
            width: context.isMobile ? double.maxFinite : context.scale(400),
            child: classSections.isEmpty
                ? Center(child: Text("No sections found for this class.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: classSections.length,
                    itemBuilder: (BuildContext context, int index) {
                      final section = classSections[index]!;
                      return Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerLow,
                        surfaceTintColor: Colors.transparent,
                        margin: EdgeInsets.symmetric(vertical: context.scale(6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.scale(16)),
                          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(4)),
                          title: Text(section.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15))),
                          subtitle: Text("Capacity: ${section.capacity ?? 'N/A'}", style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant)),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, size: context.scale(14), color: theme.colorScheme.primary),
                        ),
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("CLOSE", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
                      SizedBox(height: context.spacing),
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
                return Center(child: Text("No classes found.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)));
              }

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(20)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(context.scale(20)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: context.scale(32),
                            headingRowHeight: context.scale(56),
                            dataRowMaxHeight: context.scale(56),
                            dividerThickness: 0.5,
                            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                            columns: [
                              DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                              DataColumn(label: Text("Class Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                              DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                              DataColumn(label: Text("Level", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                              DataColumn(label: Text("Sections", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                            ],
                            rows: uniqueClasses.asMap().entries.map((entry) {
                              final index = entry.key;
                              final teacherClass = entry.value;
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                                DataCell(Text(teacherClass.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
                                DataCell(Container(
                                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(context.scale(8)),
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
                                  ),
                                  child: Text(teacherClass.code, style: TextStyle(color: theme.colorScheme.primary, fontSize: context.font(11), fontWeight: FontWeight.bold)),
                                )),
                                DataCell(Text(teacherClass.level ?? 'N/A', style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                                DataCell(TextButton.icon(
                                  onPressed: () => _showSectionsDialog(context, teacherClass, schedules),
                                  icon: Icon(Icons.visibility_outlined, size: context.scale(18), color: theme.colorScheme.primary),
                                  label: Text("VIEW", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: Text("No classes found.", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)));
            }
          }),
    );
  }
}
