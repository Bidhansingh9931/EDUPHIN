import 'dart:ui';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/create_new_subject.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/edit_suject.dart';
import 'package:flutter/material.dart';

class  SubjectListPage extends StatefulWidget{
  const SubjectListPage({super.key});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateNewSubjectPage()));
            },
            backgroundColor: theme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 5,),
                Text("Create New Class"),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(

        title: Text("Subject List"),
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
                            Text("Financial Accounting Basics",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: theme.colorScheme.onPrimary.withAlpha(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text("Active",style: TextStyle(color: Colors.green,fontSize: 16),),
                                ))
                          ],
                        ),
                        Text("An introductory course covering the fundamentals of financial accounting principles and practices.",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subject Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                            Text("Credit",style: TextStyle(color: Colors.grey,fontSize: 14),),
                            Text("Type",style: TextStyle(color: Colors.grey,fontSize: 14)),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("FAB-101",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                            Text("4",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                            Text("Theory",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                          ],
                        ),
                        Divider(
                          color: theme.colorScheme.onPrimary.withAlpha(180),
                          thickness: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateSubjectPage()));
                              },style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                                children: [
                                  Icon(Icons.edit,color: Colors.blue,size: 20,),
                                  SizedBox(width: 5,),
                                  Text("Edit",style: TextStyle(color: Colors.blue,fontSize: 20)),

                                ],
                              ),),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(onPressed: ()=> showDeleteDialog(context),style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.delete,color: Colors.red,size: 20,),
                                      SizedBox(width: 3,),
                                      Text("Delete",style: TextStyle(color: Colors.red,fontSize: 20),),

                                    ],
                                  ),
                                ],
                              ),),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
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
                            Text("Advanced Corporate Finance",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: theme.colorScheme.onPrimary.withAlpha(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text("Inactive",style: TextStyle(color: Colors.red,fontSize: 16),),
                                ))
                          ],
                        ),
                        Text("In-depth study of financial theories and their application to corporate financial policy and strategy.",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subject Code",style: TextStyle(color: Colors.grey,fontSize: 14)),
                            Text("Credit",style: TextStyle(color: Colors.grey,fontSize: 14),),
                            Text("Type",style: TextStyle(color: Colors.grey,fontSize: 14)),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ACF-310",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                            Text("4",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                            Text("Theory",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                          ],
                        ),
                        Divider(
                          color: theme.colorScheme.onPrimary.withAlpha(180),
                          thickness: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                                children: [
                                  Icon(Icons.edit,color: Colors.blue,size: 20),
                                  SizedBox(width: 3,),
                                  Text("Edit",style: TextStyle(color: Colors.blue,fontSize: 20)),

                                ],
                              ),),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(onPressed: ()=> showDeleteDialog(context),style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.delete,color: Colors.red,size: 20,),
                                      SizedBox(width: 3,),
                                      Text("Delete",style: TextStyle(color: Colors.red,fontSize: 20),),

                                    ],
                                  ),
                                ],
                              ),),
                            ),

                          ],
                        ),

                      ],
                    ),
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

void showDeleteDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return const DeleteManagerDialog(
        managerName: "Rajeev K.Malhotra",
      );
    },
  );
}
class DeleteManagerDialog extends StatelessWidget {
  final String managerName;

  const DeleteManagerDialog({
    super.key,
    required this.managerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete this section "
                        "This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // 🔥 delete logic here
                      },
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}