import 'package:eduphin/manager_dashboard/account_statics/institute_manager/add_manager.dart';
import 'package:flutter/material.dart';

class Manager {
  final String name;
  final String designation;

  Manager({required this.name, required this.designation});
}

class ManagerListPage extends StatefulWidget {
  const ManagerListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ManagerListPageState();
}

class _ManagerListPageState extends State<ManagerListPage> {
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddManagerPage()));
            },child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add,color: theme.colorScheme.onSurface,),
                const SizedBox(width: 2,),
                Text("Add Manager",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
              ],
            ),)),
      ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Manager List",
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
              CustomManagerListBox(),
            ]),
          ),
        ));
  }
}

class CustomManagerListBox extends StatefulWidget {
  const CustomManagerListBox({super.key});

  @override
  State<CustomManagerListBox> createState() => _CustomManagerListBoxState();
}

class _CustomManagerListBoxState extends State<CustomManagerListBox> {
  String? _selectedManager = "Institute Manager";
  final List<String> _managerTypes = [
    "Institute Manager",
    "Branch Manager",
    "Department Manager",
  ];

  List<Manager> _managers = [];

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  // TODO: Implement API call to fetch managers
  void _fetchManagers() {
    // For now, using hardcoded data.
    // Replace this with your API call.
    setState(() {
      _managers = [
        Manager(name: "Rohan Mehra", designation: "Principal"),
        Manager(name: "Sunita Williams", designation: "Vice Principal"),
        Manager(name: "Anjali Sharma", designation: "Academic Head"),
        Manager(name: "Vikram Rathore", designation: "Admissions Officer"),
        Manager(name: "Priya Kapoor", designation: "HR Manager"),
        Manager(name: "Amit Dessai", designation: "Finance Manager"),
        Manager(name: "Sneha Verma", designation: "IT Head"),
        Manager(name: "Rajesh Kumar", designation: "Operations Manager"),
        Manager(name: "Deepa Singh", designation: "Librarian"),
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
              value: _selectedManager,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedManager = newValue;
                });
              },
              items: _managerTypes.map<DropdownMenuItem<String>>((String value) {
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _managers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final manager = _managers[index];
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
                            manager.name,
                            style: TextStyle(
                                fontSize: 16, color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            manager.designation,
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
