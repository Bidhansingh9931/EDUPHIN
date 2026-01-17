import 'package:flutter/material.dart';

import 'add_librarian.dart';

class Librarian {
  final String name;
  final String designation;

  Librarian({required this.name, required this.designation});
}

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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddLibrarianPage()));
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
        body: const Padding(
          padding: EdgeInsets.only(bottom: 115),
          child: SingleChildScrollView(
            child: Column(children: [
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

  final List<Librarian> _librarians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLibrarians();
  }

  Future<void> _fetchLibrarians() async {
    // Simulate API call to fetch librarians.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Librarian> newLibrarians = [
      Librarian(name: "Rohan Mehra", designation: "Principal"),
      Librarian(name: "Sunita Williams", designation: "Vice Principal"),
      Librarian(name: "Anjali Sharma", designation: "Academic Head"),
      Librarian(name: "Vikram Rathore", designation: "Admissions Officer"),
      Librarian(name: "Priya Kapoor", designation: "HR Manager"),
      Librarian(name: "Amit Dessai", designation: "Finance Manager"),
      Librarian(name: "Sneha Verma", designation: "IT Head"),
      Librarian(name: "Rajesh Kumar", designation: "Operations Manager"),
      Librarian(name: "Deepa Singh", designation: "Librarian"),
    ];

    if (mounted) {
      setState(() {
        _librarians.addAll(newLibrarians);
        _isLoading = false;
      });
    }
  }

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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _librarians.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final librarian = _librarians[index];
                    return Container(
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
                                  librarian.name,
                                  style: TextStyle(
                                      fontSize: 16, color: theme.colorScheme.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  librarian.designation,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onPrimary.withAlpha(180)),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
