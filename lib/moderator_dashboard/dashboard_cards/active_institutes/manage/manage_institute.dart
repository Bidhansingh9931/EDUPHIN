import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/add_employee.dart';
import 'package:flutter/material.dart';

import 'employ_details.dart';

class ManageInstitute extends StatefulWidget {
  const ManageInstitute({super.key});

  @override
  State<StatefulWidget> createState() => _ManageInstitutePageState();
}

class _ManageInstitutePageState extends State<ManageInstitute> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Global Tech Academy'),
            InkWell(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const ModeratorDashboardPage())),
                child: Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: Icon(Icons.search,color: theme.colorScheme.onSurface),
                      hintText: "Search institutes...",
                      hintStyle: WidgetStateProperty.all( TextStyle(
                        color: theme.hintColor,
                      )),
                      elevation: const WidgetStatePropertyAll(2),
                      backgroundColor: WidgetStatePropertyAll(theme.cardColor),
                      shape:  WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(30)),
                          side: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.cardColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            side: BorderSide(color: theme.dividerColor, width: 1)
                        ),
                        child: const Icon(Icons.school_outlined,size: 30,)
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    UiHelp.customScroller(context, 'All'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'Institute Manager'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'Counselors'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'Librarian'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'Administrator'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'IT Support'),
                    const SizedBox(
                      width: 8,
                    ),
                    UiHelp.customScroller(context, 'Art Teacher'),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EmployeeDetailsPage()));
                },
                child: UiHelp.customContainer(context, 'Dr.Evelyn Reed', 'Principal'),
              ),

              UiHelp.customContainer(context, "Marcus Chen", "Head of Mathematics"),
              UiHelp.customContainer(context, 'Sophia Rodriguez', 'Science Teacher'),
              UiHelp.customContainer(context, 'David Kim', 'Librarian'),
              UiHelp.customContainer(context, 'Linda Williams', 'Administrator'),
              UiHelp.customContainer(context, 'James Brown', 'IT Support'),
              UiHelp.customContainer(context, 'Anita Singh', 'Art Teacher'),
              UiHelp.customContainer(
                  context, 'Robert Johnson', 'Physical Education'),
            ],
          ),
        ),
      ),
    );
  }
}

class UiHelp {
  static customContainer(
    BuildContext context,
    String text,
    String codeText,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Hero(
        tag: text,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.cardColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        height: 50,
                        width: 50,
                        color: theme.scaffoldBackgroundColor,
                        child: Icon(
                          Icons.person_outline_sharp,

                          size: 40,
                        )),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          codeText,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static customScroller(
    BuildContext context,
    String text,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
        ),
        child: Center(
            child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
