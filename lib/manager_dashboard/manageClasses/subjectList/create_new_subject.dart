import 'package:flutter/material.dart';

class CreateNewSubjectPage extends StatefulWidget{
  const CreateNewSubjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateNewSubjectPageState();
}

class _CreateNewSubjectPageState extends State<CreateNewSubjectPage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Add New Subject"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
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
                      Text("Subject Name"),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Subject Name",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
          
                      ),
                      SizedBox(height: 16,),
                      Text("Subject Code"),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Subject Code",
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
                          hintText: "Enter a brief description of the subject...",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text("Credit"),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Subject Credit",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
          
                      ),
                      SizedBox(height: 16,),
                      Text("Type"),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.square),
                          hintText: "Select Type",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text("Status"),
                      SizedBox(height: 8,),
                      TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.square),
                          hintText: "Active",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 16,),
                      Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(onPressed: (){},
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(65)),
                                child: Text("Add Subject",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
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
      ),
    );
  }

}