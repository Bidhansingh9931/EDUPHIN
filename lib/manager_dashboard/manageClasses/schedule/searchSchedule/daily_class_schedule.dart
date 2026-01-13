import 'package:eduphin/manager_dashboard/manageClasses/schedule/searchSchedule/overrideSchedule/override_schedule.dart';
import 'package:flutter/material.dart';

class DailyClassSchedulePage extends StatefulWidget{
  const DailyClassSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _DailyClassSchedulePageState();
}

class _DailyClassSchedulePageState extends State<DailyClassSchedulePage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Daily Class Schedule"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(
                title: "Mathematics",
                subtitle: "Mr. John Smith",
                time: "9:00 AM - 10:00 AM",
              ),
              SizedBox(height: 16,),
              CustomContainer(
                title: "Physics",
                subtitle: "Ms. Emily White",
                time: "10:00 AM - 11:00 AM",
              ),
              SizedBox(height: 16,),
              CustomContainer(
                title: "Chemistry",
                subtitle: "Dr. Alan Grant",
                time: "11:00 AM - 12:00 AM",
              ),
              SizedBox(height: 16,),
              CustomContainer(
                title: "Biology",
                subtitle: "Mrs. Sarah Conner",
                time: "1:00 AM - 2:00 AM",
              ),
              SizedBox(height: 16,),
              CustomContainer(
                title: "English Literature",
                subtitle: "Mr. David Chen",
                time: "2:00 AM - 3:00 AM",
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class CustomContainer extends StatelessWidget{
  final String title;
  final String subtitle;
  final String time;

  const CustomContainer({
    super.key,
    required this.title,
    required this.subtitle,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OverrideSchedulePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ), child: Text("Override",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ],
            ),
            Text(subtitle,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(400),fontWeight: FontWeight.bold)),
            Text(time,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(400),fontWeight: FontWeight.bold),

            ),
          ],
        ),
      ),
    );
  }

}
