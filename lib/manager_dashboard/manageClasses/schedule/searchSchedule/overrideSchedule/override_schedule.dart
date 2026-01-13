import 'package:flutter/material.dart';

class OverrideSchedulePage extends StatefulWidget{
  const OverrideSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _OverrideSchedulePageState();
}

class _OverrideSchedulePageState extends State<OverrideSchedulePage>{
  final TextEditingController _selectedDateController = TextEditingController();

  bool classSelected = false;
  bool sectionSelected = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _selectedDateController.dispose();
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
        title: Text("Override Schedule"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(title: "Original Schedule Details", className: "Class X - A", subject: "Mathematics", teacher: "Mr. John Smith",time: "09:00 AM - 10:00 AM",),
              SizedBox(height: 16,),
              Text("Reason to Override"),
              SizedBox(height: 8,),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.withAlpha(20),
                  hint: Text("Enter reason here..."),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Text("Date of Override"),
              SizedBox(height: 8,),
              TextField(
                controller: _selectedDateController,
                readOnly: true,
                onTap: () => selectDate(context, _selectedDateController),
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
              SizedBox(height: 16,),
              Text("Note (optional)"),
              SizedBox(height: 8,),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.withAlpha(20),
                  hint: Text("Enter optional note..."),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OverrideSchedulePage()));
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), child: Text("Override",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ),
              SizedBox(height: 16,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OverrideSchedulePage()));
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), child: Text("Cancel",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ),

            ],
          )
        ),
      ),
    );
  }

}
class CustomContainer extends StatelessWidget{
  final String title;
  final String className;
  final String subject;
  final String teacher;
  final String time;

  const CustomContainer({
    super.key,
    required this.title,
    required this.className,
    required this.subject,
    required this.teacher,
    required this.time,
  });
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(title,style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(height: 16,),
            Text("Class Name",style: TextStyle(fontSize: 12,color: Colors.white60),),
            SizedBox(height: 5,),
            Text(className,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold)),
            SizedBox(height: 16,),
            Text("Subject",style: TextStyle(fontSize: 12,color: Colors.white60),),
            SizedBox(height: 5,),
            Text(subject,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(height: 16,),
            Text("Teacher",style: TextStyle(fontSize: 12,color: Colors.white60),),
            SizedBox(height: 5,),
            Text(teacher,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(height: 16,),
            Text("Time (From - To)",style: TextStyle(fontSize: 12,color: Colors.white60),),
            SizedBox(height: 5,),
            Text(time,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
            SizedBox(height: 16,),

          ],
        ),
      ),
    );
  }

}
