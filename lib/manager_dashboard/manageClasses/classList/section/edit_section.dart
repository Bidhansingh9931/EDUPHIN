import 'package:flutter/material.dart';

class EditSectionPage extends StatefulWidget{
  const EditSectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Edit Section"),
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
                    Text("Section Name"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Section A",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    ),
                    SizedBox(height: 16,),
                    Text("Section Limit"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "30",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    ),
                    SizedBox(height: 16,),
                    Text("Mentor Name"),
                    SizedBox(height: 8,),
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.square),
                        hintText: "Dr.Emily Carter",
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
                          width: 160,
                          height: 50,
                          child: ElevatedButton(onPressed: (){},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(65)),
                              child: Text("Update Section",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
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