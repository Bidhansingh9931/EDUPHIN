import 'package:flutter/material.dart';

class CreateNewClassPage extends StatefulWidget{
  const CreateNewClassPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateNewClassPageState();
}

class _CreateNewClassPageState extends State<CreateNewClassPage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Create New Class"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Class Name"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Grade 10-Section A",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    ),
                    SizedBox(height: 16,),
                    Text("Class Code"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "G10-A",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    ),
                    SizedBox(height: 16,),
                    Text("Description (Optional)"),
                    SizedBox(height: 8,),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "This is the primary section for 10th grade students.",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    ),
                    SizedBox(height: 16,),
                    Text("Level"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.square),
                        hintText: "Intermediate",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(onPressed: (){},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(65)),
                                child: Text("Update Class",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
                        ),
                        SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(onPressed: (){}, child: Text("Cancel",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

}