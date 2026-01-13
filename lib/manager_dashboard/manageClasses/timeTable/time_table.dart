import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:flutter/material.dart';

import 'add_new_schedule.dart';

class TimeTableClassesPage extends StatefulWidget{
  const TimeTableClassesPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableClassesPageState();
}

class _TimeTableClassesPageState extends State<TimeTableClassesPage>{
  @override
  Widget build(BuildContext context) {
    var selectedSubject = "Class 1";
    var selectedSection = "A";
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Time Table"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddNewSchedulePage()),
                  );
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                    ),
                    child: Text("Add New Schedule",style: TextStyle(color: Colors.white,fontSize: 20),)),

              ),
              SizedBox(height: 16,),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class",
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          key: ValueKey(selectedSubject),
                          initialValue: selectedSubject,
                          items: const [
                            "Class 1",
                            "Class 2",
                            "Class 3",
                            "Class 4"
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSubject = value;
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
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          key: ValueKey(selectedSection),
                          initialValue: selectedSection,
                          items: const ["A", "B", "C", "D"],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedSection = value;
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowSchedulePage()),
            );
          },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text("Show Schedule",style: TextStyle(color: Colors.white,fontSize: 20),)),
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
    return DropdownButtonFormField(
        initialValue: initialValue,
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}