import 'package:flutter/material.dart';

class AddNewRemarksPage extends StatefulWidget{
  const AddNewRemarksPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewRemarksPageState();
}

class _AddNewRemarksPageState extends State<AddNewRemarksPage> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool positive = false;
  bool negative = false;
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("Add New Remarks")),
            IconButton(onPressed: (){
            }, icon: Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  customCheckbox(
                    "Positive",
                    positive,
                        (val) {
                      setState(() {
                        positive = val!;
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(width: 16),
                  customCheckbox(
                    "Negative",
                    negative,
                        (val) {
                      setState(() {
                        negative = val!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Remarks"),
              const SizedBox(height: 8),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter remark Description",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text("From Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _startDateController,
                readOnly: true,
                onTap: () => selectDate(context, _startDateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select start Date",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("To Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _endDateController,
                readOnly: true,
                onTap: () => selectDate(context, _endDateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select end Date",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 20),),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 20),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }
}


Widget customCheckbox(String title, bool value, Function(bool?) onChanged) {
  return Container(
    height: 60,
    width: 170,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF1C2530),
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Checkbox(
          value: value,
          activeColor: Colors.blue,
          onChanged: onChanged,
        ),
        Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white))),
      ],
    ),
  );
}