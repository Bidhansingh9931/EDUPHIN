import 'package:flutter/material.dart';

import 'add_counselor.dart';

class Counselor {
  final String name;
  final String designation;

  Counselor({required this.name, required this.designation});
}

class CounselorListPage extends StatefulWidget {
  const CounselorListPage({super.key});

  @override
  State<StatefulWidget> createState() => _CounselorListPageState();
}

class _CounselorListPageState extends State<CounselorListPage> {
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddCounselorPage()));
              },child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: theme.colorScheme.onSurface,),
                  const SizedBox(width: 2,),
                  Text("Add Counselor",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                ],
              ),)),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Counselor List",
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
              CustomCounselorListBox(),
            ]),
          ),
        ));
  }
}

class CustomCounselorListBox extends StatefulWidget {
  const CustomCounselorListBox({super.key});

  @override
  State<CustomCounselorListBox> createState() => _CustomCounselorListBoxState();
}

class _CustomCounselorListBoxState extends State<CustomCounselorListBox> {
  String? _selectedCounselor = "All Counselor";
  final List<String> _counselorTypes = [
    "All Counselor",
    "Counselor Manager",
    "Counselor Manager new",
  ];

  List<Counselor> _counselors = [];

  @override
  void initState() {
    super.initState();
    _fetchCounselors();
  }

  // TODO: Implement API call to fetch counselors
  void _fetchCounselors() {
    // For now, using hardcoded data.
    // Replace this with your API call.
    setState(() {
      _counselors = [
        Counselor(name: "Rohan Mehra", designation: "Principal"),
        Counselor(name: "Sunita Williams", designation: "Vice Principal"),
        Counselor(name: "Anjali Sharma", designation: "Academic Head"),
        Counselor(name: "Vikram Rathore", designation: "Admissions Officer"),
        Counselor(name: "Priya Kapoor", designation: "HR Manager"),
        Counselor(name: "Amit Dessai", designation: "Finance Manager"),
        Counselor(name: "Sneha Verma", designation: "IT Head"),
        Counselor(name: "Rajesh Kumar", designation: "Operations Manager"),
        Counselor(name: "Deepa Singh", designation: "Librarian"),
      ];
    });
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
              value: _selectedCounselor,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCounselor = newValue;
                });
              },
              items: _counselorTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.menu_open_sharp, color: theme.colorScheme.onPrimary), // Prefix icon
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _counselors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final counselor = _counselors[index];
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
                            counselor.name,
                            style: TextStyle(
                                fontSize: 16, color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            counselor.designation,
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
