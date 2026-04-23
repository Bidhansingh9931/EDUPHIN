import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../services/api_service.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

class CancellationPolicyScreen extends StatefulWidget {
  const CancellationPolicyScreen({super.key});

  @override
  State<CancellationPolicyScreen> createState() => _CancellationPolicyScreenState();
}

class _CancellationPolicyScreenState extends State<CancellationPolicyScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('cancellation_policy');
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
      final data = await ApiService.getCancellationPolicy();
      if (mounted) {
        setState(() {
          _contentController.text = data['content'] ?? '';
          _isLoading = false;
        });
        await SuperAdminCacheService.save('cancellation_policy', data);
      }
    } catch (e) {
      debugPrint("Error fetching Cancellation Policy: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePolicy() async {
    if (_contentController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updateCancellationPolicy(_contentController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Policy updated successfully")),
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
        title: Text("Cancellation Policy", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility, size: context.scale(24)),
            tooltip: _isPreviewMode ? "Switch to Editor" : "Switch to Preview",
          ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cancel_outlined, color: theme.colorScheme.primary, size: context.scale(24)),
                                  SizedBox(width: context.scale(12)),
                                  Text(
                                    _isPreviewMode ? "Preview Policy" : "Cancellation & Refund Policy",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(18)),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isPreviewMode,
                                onChanged: (v) => setState(() => _isPreviewMode = v)
                              ),
                            ],
                          ),
                          SizedBox(height: context.scale(8)),
                          Text(
                            _isPreviewMode
                              ? "Viewing the rendered version of your policy."
                              : "Manage refund terms and order cancellation rules using HTML.",
                            style: TextStyle(color: theme.hintColor, fontSize: context.font(12))),
                          Divider(height: context.scale(48)),

                          _isPreviewMode
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(context.scale(16)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(context.scale(8)),
                                ),
                                child: HtmlWidget(
                                  _contentController.text.isEmpty ? "<em>No content</em>" : _contentController.text,
                                  textStyle: TextStyle(fontSize: context.font(14), color: theme.textTheme.bodyMedium?.color),
                                ),
                              )
                            : TextField(
                                controller: _contentController,
                                maxLines: 25,
                                style: TextStyle(fontFamily: 'monospace', fontSize: context.font(13)),
                                decoration: InputDecoration(
                                  hintText: "Enter policy content (HTML supported)...",
                                  contentPadding: EdgeInsets.all(context.scale(16)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.scale(8))),
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
                              icon: Icon(Icons.cloud_upload_outlined, size: context.scale(20)),
                              label: Text("UPDATE POLICY", style: TextStyle(fontSize: context.font(14))),
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
