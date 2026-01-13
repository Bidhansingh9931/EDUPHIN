import 'package:flutter/material.dart';

import 'add_new_remarks.dart';

class RemarksPage extends StatefulWidget{
  const RemarksPage({super.key});

  @override
  State<StatefulWidget> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("Remarks for Aarav Sharma")),
            IconButton(onPressed: (){
            }, icon: Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNewRemarksPage()));
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_sharp,color: Colors.white,size: 25,),
                    SizedBox(width: 5),
                    Text("Add New Remark",style: TextStyle(color: Colors.white,fontSize: 16),)
                  ],
                )),
              ),
              SizedBox(height: 16,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(35),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Positive",style: TextStyle(color: Colors.green,fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Excellent performance in the recent mathematics quiz. Showed great problem solving skills."),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Remarks",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("20 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("From Date - To Date",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("15 Oct 2023 - 20 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
          
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(35),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Negative",style: TextStyle(color: Colors.red,fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Frequently late to the first period class. Needs to improve punctuality."),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Remarks",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("18 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("From Date - To Date",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("10 Oct 2023 - 18 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
          
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(35),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Positive",style: TextStyle(color: Colors.green,fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Actively participates in class discussions and helps other students"),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Remarks",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("15 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("From Date - To Date",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("1 Oct 2023 - 15 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
          
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(35),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Negative",style: TextStyle(color: Colors.red,fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Incomplete homework assignment submitted for the science project."),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Remarks",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("12 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("From Date - To Date",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("10 Oct 2023 - 12 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
          
                  ],
                ),
              ),
              SizedBox(height: 16,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(35),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Positive",style: TextStyle(color: Colors.green,fontSize: 16),
                            ),
                          ),
                        ),
                        IconButton(onPressed: (){}, icon: Icon(Icons.delete)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Excellent performance in the recent mathematics quiz. Showed great problem solving skills."),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date of Remarks",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("20 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("From Date - To Date",style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110),fontSize: 14),),
                        Text("1 Oct 2023 - 20 Oct 2023",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 14),),
                      ],
                    ),
          
                  ],
                ),
              ),
          
            ],
          ),
        ),
      ),
    );
  }
}
