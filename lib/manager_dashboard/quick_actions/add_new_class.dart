import 'dart:async';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewClass {
  String className = '';
  String classCode = '';
  String description = '';
  String? level;
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockClassApiService {
  Future<List<String>> fetchClassLevels() async {
    // Simulate fetching data for dropdowns from an API
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Primary', 'Secondary', 'Higher Secondary', 'Undergraduate', 'Postgraduate'];
  }

  Future<bool> addClass(NewClass newClass) async {
    // Simulate sending data to an API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Submitting to API:");
    debugPrint('ClassName: ${newClass.className}, ClassCode: ${newClass.classCode}, Level: ${newClass.level}, Description: ${newClass.description}');
    // Simulate a successful API call
    return true;
  }
}

class AddNewClassPage extends StatefulWidget {
  const AddNewClassPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewClassPageState();
}

class _AddNewClassPageState extends State<AddNewClassPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Class"),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CustomAddClassBox(),
        ),
      ),
    );
  }
}

class CustomAddClassBox extends StatefulWidget {
  const CustomAddClassBox({super.key});

  @override
  State<CustomAddClassBox> createState() => _CustomAddClassBoxState();
}

class _CustomAddClassBoxState extends State<CustomAddClassBox> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockClassApiService();
  late Future<List<String>> _levelsFuture;

  // Model to hold all form data
  final _newClass = NewClass();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _levelsFuture = _apiService.fetchClassLevels();
  }

  Future<void> _submitForm() async {
    if (_newClass.className.isEmpty || _newClass.classCode.isEmpty || _newClass.level == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.addClass(_newClass);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Class added successfully!' : 'Failed to add class.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<String>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final levels = snapshot.data!;
            _newClass.level ??= levels.isNotEmpty ? levels.first : null;

            return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Class Name",
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _newClass.className,
                        onChanged: (value) => _newClass.className = value,
                        decoration: InputDecoration(
                          hintText: "Enter Class Name",
                          hintStyle: TextStyle(color: theme.hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Class Code",
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _newClass.classCode,
                        onChanged: (value) => _newClass.classCode = value,
                        decoration: InputDecoration(
                          hintText: "Enter Class Code",
                          hintStyle: TextStyle(color: theme.hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Description (Optional)",
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _newClass.description,
                        onChanged: (value) => _newClass.description = value,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Enter a brief description of the class...",
                          hintStyle: TextStyle(color: theme.hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Level",
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _newClass.level,
                        hint: Text("Select Level", style: TextStyle(color: theme.hintColor)),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        items: levels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _newClass.level = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.onPrimary.withAlpha(25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary),
                                )),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                  : Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Add Class",
                                          style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary),
                                        ),
                                      ],
                                    )),
                        ],
                      )
                    ],
                  ),
                ));
          } else {
            return const Center(child: Text('No levels data available'));
          }
        });
  }
}
