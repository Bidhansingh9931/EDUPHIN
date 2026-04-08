import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../services/api_service.dart';

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
      final data = await ApiService.getCancellationPolicy();
      if (mounted) {
        setState(() {
          _contentController.text = data['content'] ?? '';
        });
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cancellation Policy"),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.visibility),
            tooltip: _isPreviewMode ? "Switch to Editor" : "Switch to Preview",
          ),
          if (!_isLoading)
            IconButton(
              onPressed: _isSaving ? null : _updatePolicy,
              icon: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cancel_outlined, color: theme.colorScheme.primary, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isPreviewMode ? "Preview Policy" : "Cancellation & Refund Policy",
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isPreviewMode, 
                                onChanged: (v) => setState(() => _isPreviewMode = v)
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPreviewMode 
                              ? "Viewing the rendered version of your policy." 
                              : "Manage refund terms and order cancellation rules using HTML.", 
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                          const Divider(height: 48),
                          
                          _isPreviewMode 
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: HtmlWidget(
                                  _contentController.text.isEmpty ? "<em>No content</em>" : _contentController.text,
                                  textStyle: theme.textTheme.bodyMedium,
                                ),
                              )
                            : TextField(
                                controller: _contentController,
                                maxLines: 25,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: "Enter policy content (HTML supported)...",
                                  contentPadding: EdgeInsets.all(16),
                                  border: OutlineInputBorder(),
                                ),
                              ),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _updatePolicy,
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: const Text("UPDATE POLICY"),
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
