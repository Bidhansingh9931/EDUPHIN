import 'package:flutter/material.dart';

import 'add_librarian.dart';

class LibrarianListPage extends StatefulWidget {
  const LibrarianListPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibrarianListPageState();
}

class _LibrarianListPageState extends State<LibrarianListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FloatingActionButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddLibrarianPage()));
              },child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: theme.colorScheme.onSurface,),
                  const SizedBox(width: 2,),
                  Text("Add Librarian",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                ],
              ),)),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Librarian List",
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.download,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 115),
          child: SingleChildScrollView(
            child: const Column(children: [
              CustomLibrarianListBox(),
            ]),
          ),
        ));
  }
}

class CustomLibrarianListBox extends StatefulWidget {
  const CustomLibrarianListBox({super.key});

  @override
  State<CustomLibrarianListBox> createState() => _CustomLibrarianListBoxState();
}

class _CustomLibrarianListBoxState extends State<CustomLibrarianListBox> {
  String? _selectedLibrarian = "All Librarian";
  final List<String> _librarianTypes = [
    "All Librarian",
    "Institute Librarian",
    "Branch Librarian",
    "Department Librarian",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedLibrarian,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLibrarian = newValue;
                });
              },
              items: _librarianTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: theme.colorScheme.onPrimary), // Prefix icon
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rohan Mehra",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Principal",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sunita Williams",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vice Principal",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Anjali Sharma",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Academic Head",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Vikram Rathore",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Admissions Officer",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Priya Kapoor",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "HR Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Amit Dessai",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Finance Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sneha Verma",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "IT Head",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rajesh Kumar",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Operations Manager",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deepa Singh",
                        style: TextStyle(
                            fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Librarian",
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimary.withAlpha(180)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
