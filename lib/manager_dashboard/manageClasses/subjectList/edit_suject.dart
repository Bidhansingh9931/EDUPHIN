import 'package:flutter/material.dart';

class UpdateSubjectPage extends StatefulWidget {
  const UpdateSubjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _UpdateSubjectPageState();
}

class _UpdateSubjectPageState extends State<UpdateSubjectPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
  }

  Future<void> _fetchSubjectDetails() async {
    // Simulate API call to fetch current subject data
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for an existing subject
    final subjectData = {
      'name': 'Financial Accounting Basics',
      'code': 'FAB-101',
      'description': 'An introductory course covering the fundamentals of financial accounting principles and practices.',
      'credit': '4',
      'type': 'Theory',
      'status': 'Active',
    };

    if (mounted) {
      setState(() {
        _nameController.text = subjectData['name']!;
        _codeController.text = subjectData['code']!;
        _descriptionController.text = subjectData['description']!;
        _creditController.text = subjectData['credit']!;
        _selectedType = subjectData['type'];
        _selectedStatus = subjectData['status'];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSubject() async {
    if (_nameController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _creditController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate API call to update data
    await Future.delayed(const Duration(seconds: 2));

    final updatedData = {
      'name': _nameController.text,
      'code': _codeController.text,
      'description': _descriptionController.text,
      'credit': _creditController.text,
      'type': _selectedType,
      'status': _selectedStatus,
    };

    print('Updating subject with data: $updatedData');

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject updated successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Update Subject"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Subject Name"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Enter Subject Name",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Subject Code"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: "Enter Subject Code",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Description (Optional)"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Enter a brief description of the subject...",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Credit"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _creditController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter Subject Credit",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Type"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: ['Theory', 'Practical'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Status"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        items: ['Active', 'Inactive'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _updateSubject,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.withAlpha(65)),
                                child: _isSaving
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                    : Text("Update Subject",
                                    style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel",
                                      style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 16))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
