import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('terms_of_service');
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
      final data = await ApiService.getTermsOfService();
      if (data != null && mounted) {
        setState(() {
          _contentController.text = data['content'] ?? '';
          _isLoading = false;
        });
        await SuperAdminCacheService.save('terms_of_service', data);
      }
    } catch (e) {
      debugPrint("Error fetching Terms of Service: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePolicy() async {
    if (_contentController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updateTermsOfService(_contentController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terms of Service updated successfully")),
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
        title: Text("Terms of Service", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _isSaving ? null : _updatePolicy,
              icon: _isSaving
                  ? SizedBox(width: context.scale(20), height: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onSurface))
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
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing * 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: context.scale(24)),
                              SizedBox(width: context.scale(12)),
                              Text(
                                "Platform Terms & Conditions",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(18)),
                              ),
                            ],
                          ),
                          SizedBox(height: context.scale(8)),
                          Text("Define the legal agreement between the platform and users.",
                              style: TextStyle(color: theme.hintColor, fontSize: context.font(12))),
                          Divider(height: context.scale(48)),
                          TextField(
                            controller: _contentController,
                            maxLines: 25,
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: InputDecoration(
                              hintText: "Enter terms content...",
                              contentPadding: EdgeInsets.all(context.scale(16)),
                            ),
                          ),
                          SizedBox(height: context.scale(24)),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _updatePolicy,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                              ),
                              icon: Icon(Icons.published_with_changes, size: context.scale(20)),
                              label: Text("SAVE AND PUBLISH", style: TextStyle(fontSize: context.font(14))),
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
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.spacing * 1.5),
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
                  SizedBox(height: context.scale(48)),
                  const Divider(),
                  SizedBox(height: context.scale(48)),
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
