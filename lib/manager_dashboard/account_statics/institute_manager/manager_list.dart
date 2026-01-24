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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddManagerPage()));
        },
        label: const Text("Add Manager"),
        icon: const Icon(Icons.add),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Manager List",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
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
          child: CustomManagerListBox(),
        ),
      ),
    );
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

  final List<Manager> _managers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    // Simulate API call to fetch managers.
    await Future.delayed(const Duration(seconds: 1));
    final List<Manager> newManagers = [
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

    if (mounted) {
      setState(() {
        _managers.addAll(newManagers);
        _isLoading = false;
      });
    }
  }

  Widget _buildManagerItem(BuildContext context, Manager manager) {
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
                  manager.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  manager.designation,
                  style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withAlpha(180)),
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
              icon: Icon(Icons.arrow_drop_down,
                  color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedManager = newValue;
                });
              },
              items:
                  _managerTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: theme.colorScheme.onPrimary), // Prefix icon
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.onPrimary),
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
                        itemCount: _managers.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                        ),
                        itemBuilder: (context, index) {
                          return _buildManagerItem(context, _managers[index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _managers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildManagerItem(context, _managers[index]);
                        },
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }
}
