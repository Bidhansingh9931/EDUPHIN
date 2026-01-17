import 'package:flutter/material.dart';

// Data model for Section
class Section {
  final String name;
  final int limit;
  final String mentor;

  Section({required this.name, required this.limit, required this.mentor});
}

class EditSectionPage extends StatefulWidget {
  const EditSectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _mentorController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSectionDetails();
  }

  Future<void> _fetchSectionDetails() async {
    // Simulate API call to fetch current section data
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for an existing section
    final section = Section(name: "Section A", limit: 30, mentor: "Dr. Emily Carter");

    if (mounted) {
      setState(() {
        _nameController.text = section.name;
        _limitController.text = section.limit.toString();
        _mentorController.text = section.mentor;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSection() async {
    if (_nameController.text.isEmpty ||
        _limitController.text.isEmpty ||
        _mentorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
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
      'limit': _limitController.text,
      'mentor': _mentorController.text,
    };

    print('Updating section with data: $updatedData');

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section updated successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    _mentorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Section"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
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
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Section A",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text("Section Limit"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "30",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text("Mentor Name"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _mentorController,
                            decoration: InputDecoration(
                              suffixIcon: const Icon(Icons.person_search),
                              hintText: "Dr. Emily Carter",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _updateSection,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.withAlpha(65)),
                                    child: _isSaving
                                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)
                                        : Text("Update Section",
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
                                  child: ElevatedButton(onPressed: () {
                                    Navigator.of(context).pop();
                                  }, child: Text("Cancel",style: TextStyle(color: theme.colorScheme.onPrimary,fontSize: 16))),
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
    );
  }
}