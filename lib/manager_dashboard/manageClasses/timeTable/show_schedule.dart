import 'package:flutter/material.dart';

class ShowSchedulePage extends StatefulWidget{
  const ShowSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _ShowSchedulePageState();
}

class _ShowSchedulePageState extends State<ShowSchedulePage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Mathematics - Sec A"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Monday"),
              SizedBox(height: 8,),
              CustomContainer(
                title: "Mathematics",
                subtitle: "Prof John Doe",
                time: "9:00 AM - 10:00 AM",
              ),
              SizedBox(height: 16,),
              Text("Tuesday"),
              SizedBox(height: 8,),
              CustomContainer(
                title: "Mathematics",
                subtitle: "Prof John Doe",
                time: "11:00 AM - 12:00 AM",
              ),
              SizedBox(height: 16,),
              Text("Wednesday"),
              SizedBox(height: 8,),
              CustomContainer(
                title: "Mathematics",
                subtitle: "Prof John Doe",
                time: "9:00 AM - 10:00 AM",
              ),
              SizedBox(height: 16,),
              Text("Friday"),
              SizedBox(height: 8,),
              CustomContainer(
                title: "Mathematics",
                subtitle: "Prof John Doe",
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
              Text(title,style: TextStyle(fontSize: 16,color: Colors.white),),
              Icon(Icons.delete,color: Colors.green,size: 20),
            ],
          ),
            Text(subtitle,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(75))),
            Text(time,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(75)),
            ),
          ],
        ),
      ),
    );
  }

}
