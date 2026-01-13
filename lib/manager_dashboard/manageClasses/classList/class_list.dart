import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:flutter/material.dart';

class ClassListPage extends StatefulWidget{
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(

        title: Text("Class List"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>SectionsPage())),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Class VIII",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: theme.colorScheme.onPrimary.withAlpha(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text("Secondary",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                                ))
                          ],
                        ),
                        Text("Class for 8th grade students",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        const SizedBox(height: 8),
                        Divider(
                          color: theme.colorScheme.onPrimary.withAlpha(180),
                          thickness: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                            Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("C-VIII",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                            Text("4",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                          ],
                        )

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Class IX",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.onPrimary.withAlpha(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text("Secondary",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                              ))
                        ],
                      ),
                      Text("Class for 9th grade students",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                          Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("C-IX",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                          Text("5",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                        ],
                      )

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Class X",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.onPrimary.withAlpha(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text("Sr. Sec",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                              ))
                        ],
                      ),
                      Text("Class for 10th grade students",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                          Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("C-X",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                          Text("4",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                        ],
                      )

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Class XI",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.onPrimary.withAlpha(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text("Sr. Sec",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                              ))
                        ],
                      ),
                      Text("Class for 11th grade students",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                          Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("C-XI",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                          Text("6",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                        ],
                      )

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Class V",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.onPrimary.withAlpha(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text("Primary",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                              ))
                        ],
                      ),
                      Text("Class for 5th grade students",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                          Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("C-V",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                          Text("3",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                        ],
                      )

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("B.Com",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: theme.colorScheme.onPrimary.withAlpha(25),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Text("Graduation",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                              ))
                        ],
                      ),
                      Text("Batchelor of Commerce",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.onPrimary.withAlpha(180),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                          Text("Total Sections",style: TextStyle(color: Colors.grey,fontSize: 14)),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("BCOM-1",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                          Text("2",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                        ],
                      )

                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
            ],
          ),
        ),
      ),

    );
  }
}