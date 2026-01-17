import 'package:flutter/material.dart';

class CreateNewSubjectPage extends StatefulWidget {
  const CreateNewSubjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateNewSubjectPageState();
}

class _CreateNewSubjectPageState extends State<CreateNewSubjectPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  String? _selectedType = 'Theory';
  String? _selectedStatus = 'Active';
  bool _isLoading = false;

  Future<void> _addSubject() async {
    if (_nameController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _creditController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final subjectData = {
      'name': _nameController.text,
      'code': _codeController.text,
      'description': _descriptionController.text,
      'credit': _creditController.text,
      'type': _selectedType,
      'status': _selectedStatus,
    };

    print('Adding subject: $subjectData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject added successfully!')),
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
        title: const Text("Add New Subject"),
        centerTitle: true,
      ),
      body: Padding(
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
                        value: _selectedType,
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
                        value: _selectedStatus,
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
                                onPressed: _isLoading ? null : _addSubject,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.withAlpha(65)),
                                child: _isLoading
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                    : Text("Add Subject",
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
