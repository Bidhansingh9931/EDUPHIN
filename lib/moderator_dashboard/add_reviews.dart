import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/common_widgets.dart';
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
          ErrorHandler.showError(context, e);
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(800)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileAvatar(
                      radius: context.scale(50),
                      imageUrl: null, // No image yet
                      onCameraTap: () {
                        // Image picking logic would go here
                      },
                    ),
                  ),
                  SizedBox(height: context.scale(32)),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(24.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reviewer Information", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                          SizedBox(height: context.scale(24)),
                          _buildFieldLabel(theme, "Full Name"),
                          SizedBox(height: context.scale(8)),
                          TextFormField(
                            controller: _fullNameController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              hintText: "e.g. Amelia Johnson",
                            ),
                          ),
                          SizedBox(height: context.scale(24)),
                          _buildFieldLabel(theme, "Designation / Role"),
                          SizedBox(height: context.scale(8)),
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
                  SizedBox(height: context.scale(24)),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(24.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Feedback", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                          SizedBox(height: context.scale(24)),
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
                  SizedBox(height: context.scale(32)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitReview,
                      icon: _isLoading
                        ? SizedBox(width: context.scale(20), height: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                        : Icon(Icons.send_rounded, size: context.scale(20)),
                      label: Text(_isLoading ? "Submitting..." : "SUBMIT REVIEW", style: TextStyle(fontSize: context.font(14))),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.scale(18)),
                      ),
                    ),
                  ),
                  SizedBox(height: context.scale(50)),
                ],
              ),
            ),
          ),
        ),
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
        fontSize: context.font(12),
      ),
    );
  }
}
