
import 'package:flutter/material.dart';
import 'add_review_model.dart';
import 'add_review_provider.dart';

class AddReviewsPage extends StatefulWidget {
  const AddReviewsPage({super.key});

  @override
  State<AddReviewsPage> createState() => _AddReviewsPageState();
}

class _AddReviewsPageState extends State<AddReviewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _designationController = TextEditingController();
  final _messageController = TextEditingController();
  final _addReviewProvider = AddReviewProvider();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _designationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final submission = ReviewSubmission(
        fullName: _fullNameController.text,
        designation: _designationController.text,
        message: _messageController.text,
      );

      try {
        await _addReviewProvider.submitReview(submission);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        _formKey.currentState!.reset();
        _fullNameController.clear();
        _designationController.clear();
        _messageController.clear();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset("assets/images/girl_image.webp",
                              width: 100, height: 100, fit: BoxFit.cover)),
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text("Full Name", style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a full name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Amelia Johnson",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("Designation", style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _designationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a designation';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.connect_without_contact),
                    hintText: "Parent, Grade 10",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("Message", style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                  maxLines: 5,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 90, left: 10),
                        child: Icon(
                          Icons.message,
                          size: 30,
                        ),
                      ),
                      hintText: "Enter review message here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitReview,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Send Reviews",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
