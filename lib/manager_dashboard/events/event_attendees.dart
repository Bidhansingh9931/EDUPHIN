import 'package:flutter/material.dart';

class EventAttendees extends StatefulWidget{
  const EventAttendees({super.key});

  @override
  State<StatefulWidget> createState() => _EventAttendeesState();
}

class _EventAttendeesState extends State<EventAttendees>{
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    var arrName = ["Aarav Sharma","Diya Patel","Rohan Kumar","Ms.Anjali Mehta","Arjun Gupta","Mr.Vikram Rathore","Vivaan Reddy"];
    var attended = ['Attended','Not Attended','Attended','Attended','Non Attended','Not Attended','Attended'];
    var arrName1 =["aarav.sharma@school.com","diya.patel@school.com","rohan.kumar@school.com","anjali.mehta@school.com","arjun.gupta@school.com","vikram.rathore@school.com","vivaan.reddy@school.com"];
    var status = ["Student","Student","Student","Teacher","Student","Staff","Student"];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Event Attendees"),
            Icon(Icons.download),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Annual Sports Day"),
              const SizedBox(height: 8),
              SearchBar(
                leading:
                Icon(Icons.search, color: theme.colorScheme.onSurface),
                hintText: "Search for students, teachers...",
                hintStyle: WidgetStateProperty.all(TextStyle(
                  color: theme.hintColor,
                )),
                elevation: const WidgetStatePropertyAll(2),
                backgroundColor: WidgetStatePropertyAll(theme.cardColor),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    side: BorderSide(color: theme.dividerColor, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ATTENDEE LIST (85) "),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: <String>["All", "Attended", "Not Attended"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,style: TextStyle(color: Colors.blueAccent)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Divider(
                color: theme.dividerColor,
                thickness: 2,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                final isAttended = attended[index] == 'Attended';
                return ListTile(
                  title: Text(arrName[index],style: TextStyle(color: Colors.white,fontSize: 16),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(arrName1[index],style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(180),fontSize: 14),),
                      const SizedBox(height: 4),
                      Text(status[index],style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(180),fontSize: 14),)
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(attended[index],style: TextStyle(color: isAttended ? Colors.green : Colors.red,fontSize: 14),),
                      const SizedBox(width: 8),
                      Icon(isAttended ? Icons.check_circle_outline : Icons.cancel_outlined,color: isAttended ? Colors.green : Colors.red,size: 16,),
                    ],
                  ),
                );
              }, separatorBuilder: (context,index)=>Divider(color: theme.dividerColor,thickness: 1,), itemCount: arrName.length),
          
              ],
          ),
        ),
      ),
    );
  }
}
