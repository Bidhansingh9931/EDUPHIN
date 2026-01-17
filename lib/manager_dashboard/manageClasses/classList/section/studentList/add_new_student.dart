import 'package:flutter/material.dart';

class AddNewStudentPage extends StatefulWidget {
  const AddNewStudentPage({super.key});

  @override
  State<AddNewStudentPage> createState() => _AddNewStudentPageState();
}

class _AddNewStudentPageState extends State<AddNewStudentPage> {
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty || _regNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call to add student
    await Future.delayed(const Duration(seconds: 2));

    final studentData = {
      'name': _nameController.text,
      'regNo': _regNoController.text,
    };

    print('Adding student: $studentData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Student"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Student Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _regNoController,
              decoration: InputDecoration(
                labelText: "Registration Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addStudent,
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Text("Add Student"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
