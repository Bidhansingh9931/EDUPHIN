import 'dart:ui';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/edit_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/student_list.dart';
import 'package:flutter/material.dart';

import '../create_new_class.dart';

class SectionsPage extends StatefulWidget{
  const SectionsPage({super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateNewClassPage()));
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sections for Class VIII"),
            Icon(Icons.menu),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Section A",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text("Class Limit",style: TextStyle(color: Colors.green,fontSize: 16),),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mentor: Mrs. Anjali Sharma",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        Text("40",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.colorScheme.onPrimary.withAlpha(180),
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditSectionPage()));
                        },style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 1,),
                            Text("Edit"),

                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentListPage()));
                        },style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.people_alt_outlined,color: theme.colorScheme.onPrimary,size: 16,),
                            SizedBox(width: 1,),
                            Text("Student List",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16),),
                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: ()=> showDeleteDialog(context),style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,size: 16,),
                                SizedBox(width: 1,),
                                Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),),

                              ],
                            ),
                          ],
                        ),),

                      ],
                    ),

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
                        Text("Section B",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text("Class Limit",style: TextStyle(color: Colors.green,fontSize: 16),),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mentor: Mr. Vikram Singh",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        Text("42",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.colorScheme.onPrimary.withAlpha(180),
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 1,),
                            Text("Edit"),

                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.people_alt_outlined,color: theme.colorScheme.onPrimary,size: 16,),
                            SizedBox(width: 1,),
                            Text("Student List",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16),),
                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,size: 16,),
                                SizedBox(width: 1,),
                                Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),),

                              ],
                            ),
                          ],
                        ),),

                      ],
                    ),

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
                        Text("Section c",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text("Class Limit",style: TextStyle(color: Colors.green,fontSize: 16),),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mentor: Ms. Priya Kumari",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        Text("38",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.colorScheme.onPrimary.withAlpha(180),
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 1,),
                            Text("Edit"),

                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.people_alt_outlined,color: theme.colorScheme.onPrimary,size: 16,),
                            SizedBox(width: 1,),
                            Text("Student List",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16),),
                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,size: 16,),
                                SizedBox(width: 1,),
                                Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),),

                              ],
                            ),
                          ],
                        ),),

                      ],
                    ),

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
                        Text("Section D",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text("Class Limit",style: TextStyle(color: Colors.green,fontSize: 16),),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mentor: Mr. Rajeev Mehta",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),
                        Text("41",style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180),fontSize: 14)),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.colorScheme.onPrimary.withAlpha(180),
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 1,),
                            Text("Edit"),

                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withAlpha(45)), child: Row(
                          children: [
                            Icon(Icons.people_alt_outlined,color: theme.colorScheme.onPrimary,size: 16,),
                            SizedBox(width: 1,),
                            Text("Student List",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16),),
                          ],
                        ),),
                        Spacer(),
                        ElevatedButton(onPressed: ()=> showDeleteDialog(context),style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withAlpha(45)), child: Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,size: 16,),
                                SizedBox(width: 1,),
                                Text("Delete",style: TextStyle(color: Colors.red,fontSize: 16),),

                              ],
                            ),
                          ],
                        ),),

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