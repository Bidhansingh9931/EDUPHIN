import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchPolicy() async {
    if (!mounted) return;
    try {
      final data = await ApiService.getPrivacyPolicy();
      if (data != null && mounted) {
        setState(() {
          _contentController.text = data['content'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error fetching Privacy Policy: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePolicy() async {
    if (_contentController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updatePrivacyPolicy(_contentController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Privacy Policy updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(fontSize: context.font(20))),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _isSaving ? null : _updatePolicy,
              icon: _isSaving
                  ? SizedBox(width: context.scale(20), height: context.scale(20), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.save, size: context.scale(24)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(900)),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(24.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, color: theme.colorScheme.primary, size: context.scale(24)),
                              SizedBox(width: context.scale(12)),
                              Text(
                                "Platform Privacy Policy",
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
                              ),
                            ],
                          ),
                          SizedBox(height: context.scale(8)),
                          Text("Manage and update the global privacy terms for all users.",
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
                          Divider(height: context.scale(48)),
                          TextField(
                            controller: _contentController,
                            maxLines: 25,
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: const InputDecoration(
                              hintText: "Enter policy content...",
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          SizedBox(height: context.scale(24)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _updatePolicy,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, context.scale(54)),
                              ),
                              icon: Icon(Icons.check_circle_outline, size: context.scale(20)),
                              label: Text("SAVE AND PUBLISH", style: TextStyle(fontSize: context.font(16))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
