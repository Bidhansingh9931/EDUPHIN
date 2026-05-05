import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

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
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('privacy_policy');
    if (cachedData != null && mounted) {
      setState(() {
        _contentController.text = cachedData['content'] ?? '';
        _isLoading = false;
      });
    }
    _fetchPolicy();
  }

  Future<void> _fetchPolicy() async {
    if (!mounted) return;
    if (_contentController.text.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getPrivacyPolicy();
      if (data != null && mounted) {
        setState(() {
          _contentController.text = data['content'] ?? '';
          _isLoading = false;
        });
        await SuperAdminCacheService.save('privacy_policy', data);
      }
    } catch (e) {
      debugPrint("Error fetching Privacy Policy: $e");
      if (mounted) ErrorHandler.showError(context, e);
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
        ErrorHandler.showError(context, e);
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
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _contentController.text.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
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
                  const Row(
                    children: [
                      SuperAdminSkeleton(height: 24, width: 24),
                      SizedBox(width: 12),
                      SuperAdminSkeleton(height: 24, width: 250),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SuperAdminSkeleton(height: 14, width: 350),
                  SizedBox(height: context.scale(24)),
                  const Divider(),
                  SizedBox(height: context.scale(24)),
                  const SuperAdminSkeleton(height: 400),
                  SizedBox(height: context.scale(24)),
                  const SuperAdminSkeleton(height: 54),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
