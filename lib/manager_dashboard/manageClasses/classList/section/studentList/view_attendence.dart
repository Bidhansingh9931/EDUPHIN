import 'package:flutter/material.dart';

class ViewAttendancePage extends StatefulWidget{
  const ViewAttendancePage({super.key});

  @override
  State<StatefulWidget> createState() => ViewAttendancePageState();
}

class ViewAttendancePageState extends State<ViewAttendancePage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Attendance Details"),
            IconButton(onPressed: (){}, icon: Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16,16,16,50),
          child: Column(
            children: [
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
                    Text(
                      "Aarav Sharma",
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5),
                    Text("Roll No : 1", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    Text("Class : 10th - A", style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 5),

                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "25 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Thursday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 7/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "24 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Wednesday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 8/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "23 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Tuesday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 4/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "22 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Monday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 8/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "21 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Saturday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 4/4", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "19 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Friday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 6/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "18 Jul 2025, ",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Thursday", style: theme.textTheme.bodyLarge),
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Text("Attended: 8/8", style: theme.textTheme.bodyLarge),
                        Text("Total Classes", style: theme.textTheme.bodyMedium),
                      ],
                    ),

                  ],
                ),
              ),
              ]
          ),
        ),
      ),
    );
  }

}