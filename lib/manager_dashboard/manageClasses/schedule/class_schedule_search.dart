import 'package:flutter/material.dart';

import 'searchSchedule/daily_class_schedule.dart';

// import 'add_new_schedule.dart';

class ClassScheduleSearchPage extends StatefulWidget{
  const ClassScheduleSearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassScheduleSearchPageState();
}

class _ClassScheduleSearchPageState extends State<ClassScheduleSearchPage>{
  final TextEditingController _selectDateController = TextEditingController();

  bool classSelected = false;
  bool sectionSelected = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectDateController.dispose();
    super.dispose();
  }

  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      controller.text =
      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }
  @override
  Widget build(BuildContext context) {
    var selectedSubject = "Class 1";
    var selectedSection = "A";
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Class Schedule Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              Text("Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _selectDateController,
                readOnly: true,
                onTap: () => selectDate(context, _selectDateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select Date",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
              MaterialPageRoute(builder: (context) => const DailyClassSchedulePage()),
            );
          },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text("Search",style: TextStyle(color: Colors.white,fontSize: 20),)),
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