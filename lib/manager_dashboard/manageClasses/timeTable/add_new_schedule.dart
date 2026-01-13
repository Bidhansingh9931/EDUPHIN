import 'package:flutter/material.dart';

class AddNewSchedulePage extends StatefulWidget{
  const AddNewSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSchedulePageState();
}

class _AddNewSchedulePageState extends State<AddNewSchedulePage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Schedule'),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAddNewScheduleBox(),
            ],
          ),
        ),
      ),
    );
  }

}
class CustomAddNewScheduleBox extends StatefulWidget {
  const CustomAddNewScheduleBox({super.key});

  @override
  State<CustomAddNewScheduleBox> createState() => _CustomAddNewScheduleBoxState();
}

class _CustomAddNewScheduleBoxState extends State<CustomAddNewScheduleBox> {

  String selectedClass = "Class 1";
  String selectedSection = "A";
  String selectedSubject = "Math";
  String selectedTeacher = "Mr. Smith";
  String selectedWeekday = "Monday";
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
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
            Text("Class",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
            const SizedBox(height: 8),
            DropDownBox(
              initialValue: selectedClass,
              items: const ["Class 1", "Class 2", "Class 3", "Class 4"],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedClass = value;
                  });
                }
              },
              hintText: "--Select Class",
            ),
            const SizedBox(height: 16),
            Text("Section",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
            const SizedBox(height: 8),
            DropDownBox(
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
            const SizedBox(height: 16),
            Text("Subject",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
            const SizedBox(height: 8),
            DropDownBox(
              initialValue: selectedSubject,
              items: const ["Math", "Science", "History", "English"],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSubject = value;
                  });
                }
              },
              hintText: "--Select Subject",
            ),
            const SizedBox(height: 16),
            Text("Teacher",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
            const SizedBox(height: 8),
            DropDownBox(
              initialValue: selectedTeacher,
              items: const ["Mr. Smith", "Mrs. Jones", "Mr. Williams", "Ms. Brown"],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTeacher = value;
                  });
                }
              },
              hintText: "--Select Teacher",
            ),
            const SizedBox(height: 16),
            Text("Weekdays",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
            const SizedBox(height: 8),
            DropDownBox(
              initialValue: selectedWeekday,
              items: const ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedWeekday = value;
                  });
                }
              },
              hintText: "--Select Weekday",
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Start Time",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _selectTime(context, isStartTime: true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: theme.hintColor)
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startTime?.format(context) ?? "__:__:__",
                                style: TextStyle(color: theme.hintColor, fontSize: 23),
                              ),
                              Icon(Icons.access_time, color: theme.hintColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("End Time",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _selectTime(context, isStartTime: false),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: theme.hintColor)
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                endTime?.format(context) ?? "__:__:__",
                                style: TextStyle(color: theme.hintColor, fontSize: 23),
                              ),
                              Icon(Icons.access_time, color: theme.hintColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Divider(
              color: theme.colorScheme.onPrimary,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 140,
                  height: 40,
                  child: ElevatedButton(onPressed: (){ Navigator.pop(context); },
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),)),
                      child: Text("Cancel",style: TextStyle(fontSize: 20,color: theme.colorScheme.onPrimary),)
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: (){},
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),)),
                    child: Row(
                      children: [
                        Icon(Icons.add,color: theme.colorScheme.onPrimary,),
                        const SizedBox(width: 10),
                        Text("Add Schedule",style: TextStyle(fontSize: 20,color: theme.colorScheme.onPrimary),),
                      ],
                    )
                ),
              ],
            ),


          ],
        )
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
