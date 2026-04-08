import 'package:eduphin/services/responsive_helper.dart';
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(theme),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reviewer Information", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          _buildFieldLabel(theme, "Full Name"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fullNameController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              hintText: "e.g. Amelia Johnson",
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildFieldLabel(theme, "Designation / Role"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _designationController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined),
                              hintText: "e.g. Parent, Grade 10",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Feedback", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _messageController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: "Share your thoughts about the institute...",
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitReview,
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                      label: Text(_isLoading ? "Submitting..." : "SUBMIT REVIEW"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 4),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage: const AssetImage("assets/images/girl_image.webp"),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
        letterSpacing: 1.1,
      ),
    );
  }
}
