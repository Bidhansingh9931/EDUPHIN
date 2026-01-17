import 'package:flutter/material.dart';

import 'searchSchedule/daily_class_schedule.dart';

// import 'add_new_schedule.dart';

class ClassScheduleSearchPage extends StatefulWidget {
  const ClassScheduleSearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassScheduleSearchPageState();
}

class _ClassScheduleSearchPageState extends State<ClassScheduleSearchPage> {
  final TextEditingController _selectDateController = TextEditingController();

  bool _isLoading = true;
  String? _selectedClass;
  String? _selectedSection;
  List<String> _classList = [];
  List<String> _sectionList = [];


  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  @override
  void dispose() {
    _selectDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    // Simulate API call to fetch dropdown data.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<String> fetchedClasses = [
      "Class 1",
      "Class 2",
      "Class 3",
      "Class 4"
    ];
    final List<String> fetchedSections = ["A", "B", "C", "D"];

    if (mounted) {
      setState(() {
        _classList = fetchedClasses;
        _sectionList = fetchedSections;
        _selectedClass = fetchedClasses.isNotEmpty ? fetchedClasses.first : null;
        _selectedSection = fetchedSections.isNotEmpty ? fetchedSections.first : null;
        _isLoading = false;
      });
    }
  }


  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      controller.text =
      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Class Schedule Search"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 115),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16,),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class",
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          value: _selectedClass,
                          items: _classList,
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                          },
                          hintText: "--Select Class",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Section",
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          value: _selectedSection,
                          items: _sectionList,
                          onChanged: (value) {
                            setState(() {
                              _selectedSection = value;
                            });
                          },
                          hintText: "--Select Section",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Date"),
              const SizedBox(height: 8),
              TextField(
                controller: _selectDateController,
                readOnly: true,
                onTap: () => selectDate(context, _selectDateController),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month,
                      color: theme.colorScheme.onPrimary),
                  filled: true,
                  fillColor: theme.primaryColor,
                  hintText: "Select Date",
                  hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(onPressed: () {
            if (_selectedClass != null &&
                _selectedSection != null &&
                _selectDateController.text.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DailyClassSchedulePage(
                      // You'll need to update DailyClassSchedulePage to accept these parameters
                      // e.g. DailyClassSchedulePage(className: _selectedClass!, section: _selectedSection!, date: _selectDateController.text)
                    )),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please select class, section, and date.')),
              );
            }
          },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text("Search",
                  style: TextStyle(color: Colors.white, fontSize: 20))),
        ),
      ),
    );
  }

}

class DropDownBox extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items:
        items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}
