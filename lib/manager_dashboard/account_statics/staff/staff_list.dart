import 'package:eduphin/manager_dashboard/account_statics/staff/add_staff.dart';
import 'package:flutter/material.dart';

class Staff {
  final String name;
  final String designation;

  Staff({required this.name, required this.designation});
}

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StatefulWidget> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font size
    double responsiveFontSize(double baseSize) {
      if (screenWidth < 600) {
        return baseSize;
      } else if (screenWidth < 1200) {
        return baseSize * 1.25;
      } else {
        return baseSize * 1.5;
      }
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: screenWidth > 600 ? 400 : screenWidth * 0.9,
        height: 50,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStaffPage()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                "Add Staff",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: responsiveFontSize(18),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Staff List",
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: responsiveFontSize(20),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return const SingleChildScrollView(
              child: CustomStaffListBox(),
            );
          },
        ),
      ),
    );
  }
}

class CustomStaffListBox extends StatefulWidget {
  const CustomStaffListBox({super.key});

  @override
  State<CustomStaffListBox> createState() => _CustomStaffListBoxState();
}

class _CustomStaffListBoxState extends State<CustomStaffListBox> {
  String? _selectedStaff = "All Staff";
  final List<String> _staffTypes = [
    "All Staff",
    "Branch Staff",
    "Department Staff",
  ];

  final List<Staff> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    // Simulate API call to fetch staff.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Staff> newStaff = [
      Staff(name: "Rohan Mehra", designation: "Principal"),
      Staff(name: "Sunita Williams", designation: "Vice Principal"),
      Staff(name: "Anjali Sharma", designation: "Academic Head"),
      Staff(name: "Vikram Rathore", designation: "Admissions Officer"),
      Staff(name: "Priya Kapoor", designation: "HR Manager"),
      Staff(name: "Amit Dessai", designation: "Finance Manager"),
      Staff(name: "Sneha Verma", designation: "IT Head"),
      Staff(name: "Rajesh Kumar", designation: "Operations Manager"),
      Staff(name: "Deepa Singh", designation: "Librarian"),
    ];

    if (mounted) {
      setState(() {
        _staff.addAll(newStaff);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font size
    double responsiveFontSize(double baseSize) {
      if (screenWidth < 600) {
        return baseSize;
      } else if (screenWidth < 1200) {
        return baseSize * 1.25;
      } else {
        return baseSize * 1.5;
      }
    }

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
              value: _selectedStaff,
              underline: const SizedBox(),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onPrimary),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStaff = newValue;
                });
              },
              items: _staffTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: theme.colorScheme.onPrimary), // Prefix icon
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: responsiveFontSize(16)),
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
                  itemCount: _staff.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final staffMember = _staff[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staffMember.name,
                                  style: TextStyle(
                                      fontSize: responsiveFontSize(16),
                                      color: theme.colorScheme.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  staffMember.designation,
                                  style: TextStyle(
                                      fontSize: responsiveFontSize(14),
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
