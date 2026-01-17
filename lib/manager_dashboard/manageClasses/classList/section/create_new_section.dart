import 'package:flutter/material.dart';

class CreateNewSectionPage extends StatefulWidget {
  const CreateNewSectionPage({super.key});

  @override
  State<CreateNewSectionPage> createState() => _CreateNewSectionPageState();
}

class _CreateNewSectionPageState extends State<CreateNewSectionPage> {
  final _sectionNameController = TextEditingController();
  final _mentorController = TextEditingController();
  final _limitController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createSection() async {
    // Basic validation
    if (_sectionNameController.text.isEmpty ||
        _mentorController.text.isEmpty ||
        _limitController.text.isEmpty) {
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

    final sectionData = {
      'name': _sectionNameController.text,
      'mentor': _mentorController.text,
      'limit': _limitController.text,
    };

    // In a real app, you would send this to your API
    print('Creating section: $sectionData');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section created successfully!')),
      );
      Navigator.pop(context); // Go back after creation
    }
  }

  @override
  void dispose() {
    _sectionNameController.dispose();
    _mentorController.dispose();
    _limitController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create New Section"),
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
                      const Text("Section Name"),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: _sectionNameController,
                        decoration: InputDecoration(
                          hintText: "e.g., Section A",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text("Mentor Teacher"),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: _mentorController,
                        decoration: InputDecoration(
                          hintText: "e.g., Mrs. Anjali Sharma",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text("Class Limit"),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: _limitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "e.g., 40",
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createSection,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white))
                                  : Flexible(
                                    child: Text("Create Section",
                                    style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16)),
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(onPressed: (){
                              Navigator.pop(context);
                            }, child: Text("Cancel",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
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
