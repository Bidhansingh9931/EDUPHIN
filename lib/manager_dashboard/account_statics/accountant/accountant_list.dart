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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddAccountantPage()));
          },
          label: const Text("Add Accountant"),
          icon: const Icon(Icons.add),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Accountant List",
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.download,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 50),
            child: CustomAccountantListBox(),
          ),
        ));
  }
}

class CustomAccountantListBox extends StatefulWidget {
  const CustomAccountantListBox({super.key});

  @override
  State<CustomAccountantListBox> createState() =>
      _CustomAccountantListBoxState();
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

  Widget _buildAccountantItem(BuildContext context, Accountant accountant) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child:
                Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accountant.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  accountant.designation,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                icon: Icon(Icons.arrow_drop_down,
                    color: theme.colorScheme.onPrimary),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAccountant = newValue;
                  });
                },
                items:
                    _accountantTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: theme.colorScheme.onPrimary), // Prefix icon
                        const SizedBox(width: 8),
                        Text(
                          value,
                          style:
                              theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary),
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
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isLargeScreen = constraints.maxWidth > 600;
                      if (isLargeScreen) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _accountants.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3.5,
                          ),
                          itemBuilder: (context, index) {
                            return _buildAccountantItem(
                                context, _accountants[index]);
                          },
                        );
                      } else {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _accountants.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildAccountantItem(
                                context, _accountants[index]);
                          },
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
