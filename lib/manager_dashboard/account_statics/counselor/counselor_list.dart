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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddCounselorPage()));
          },
          label: const Text("Add Counselor"),
          icon: const Icon(Icons.add),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Counselor List",
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
            child: CustomCounselorListBox(),
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

  final List<Counselor> _counselors = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchCounselors();
  }

  Future<void> _fetchCounselors() async {
    // Simulate API call to fetch counselors.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Counselor> newCounselors = [
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
    if(mounted){
        setState(() {
            _counselors.addAll(newCounselors);
            _isLoading = false;
        });
    }
  }

  Widget _buildCounselorItem(BuildContext context, Counselor counselor) {
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
            child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  counselor.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  counselor.designation,
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
                        Icon(Icons.person_outline, color: theme.colorScheme.onPrimary), // Prefix icon
                        const SizedBox(width: 8),
                        Text(
                          value,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary),
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
                    itemCount: _counselors.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.5,
                    ),
                    itemBuilder: (context, index) {
                      return _buildCounselorItem(context, _counselors[index]);
                    },
                  );
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _counselors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCounselorItem(context, _counselors[index]);
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
