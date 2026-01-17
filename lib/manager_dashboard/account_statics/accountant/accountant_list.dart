import 'package:eduphin/manager_dashboard/account_statics/accountant/add_accountant.dart';
import 'package:flutter/material.dart';

class Accountant {
  final String name;
  final String designation;

  Accountant({required this.name, required this.designation});
}

class AccountantListPage extends StatefulWidget {
  const AccountantListPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountantListPageState();
}

class _AccountantListPageState extends State<AccountantListPage> {
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddAccountantPage()));
              },child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: theme.colorScheme.onSurface,),
                  const SizedBox(width: 2,),
                  Text("Add Accountant",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                ],
              ),)),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Accountant List",
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
              CustomAccountantListBox(),
            ]),
          ),
        ));
  }
}

class CustomAccountantListBox extends StatefulWidget {
  const CustomAccountantListBox({super.key});

  @override
  State<CustomAccountantListBox> createState() => _CustomAccountantListBoxState();
}

class _CustomAccountantListBoxState extends State<CustomAccountantListBox> {
  String? _selectedAccountant = "All Accountant";
  final List<String> _accountantTypes = [
    "All Accountant",
    "Accountant Manager",
    "Accountant Branch",
    "Accountant Department",
  ];

  final List<Accountant> _accountants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountants();
  }

  Future<void> _fetchAccountants() async {
    // Simulate API call to fetch accountants.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Accountant> newAccountants = [
      Accountant(name: "Rohan Mehra", designation: "Principal"),
      Accountant(name: "Sunita Williams", designation: "Vice Principal"),
      Accountant(name: "Anjali Sharma", designation: "Academic Head"),
      Accountant(name: "Vikram Rathore", designation: "Admissions Officer"),
      Accountant(name: "Priya Kapoor", designation: "HR Manager"),
      Accountant(name: "Amit Dessai", designation: "Finance Manager"),
      Accountant(name: "Sneha Verma", designation: "IT Head"),
      Accountant(name: "Rajesh Kumar", designation: "Operations Manager"),
      Accountant(name: "Deepa Singh", designation: "Librarian"),
    ];

    if (mounted) {
      setState(() {
        _accountants.addAll(newAccountants);
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
              value: _selectedAccountant,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAccountant = newValue;
                });
              },
              items: _accountantTypes.map<DropdownMenuItem<String>>((String value) {
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
                  itemCount: _accountants.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final accountant = _accountants[index];
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
                                  accountant.name,
                                  style: TextStyle(
                                      fontSize: 16, color: theme.colorScheme.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  accountant.designation,
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
