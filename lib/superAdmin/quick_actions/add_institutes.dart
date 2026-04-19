import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddInstitutesQuickAction extends StatefulWidget {
  const AddInstitutesQuickAction({super.key});

  @override
  State<AddInstitutesQuickAction> createState() => _AddInstitutesQuickActionState();
}

class _AddInstitutesQuickActionState extends State<AddInstitutesQuickAction> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _chairmanController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  String _status = "active";
  File? _logoFile;
  Uint8List? _webLogo;
  String? _fileName;
  bool _isSaving = false;

  Future<void> _pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webLogo = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _logoFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'established_year': _yearController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'contact_email': _emailController.text.trim(),
        'contact_phone': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'chairman_name': _chairmanController.text.trim(),
        'affiliation_details': _affiliationController.text.trim(),
        'gst_number': _gstController.text.trim(),
        'pan_number': _panController.text.trim(),
        'status': _status,
      };

      await ApiService.storeSuperAdminInstitute(
        data,
        logo: _logoFile,
        logoBytes: _webLogo,
        fileName: _fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Institute created successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Institute Information"),
            Text("Register a new institute platform-wide.", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "Basic Details", Icons.info_outline),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "Institute Name *", "e.g., ABC College", Icons.business, _nameController),
                          _buildTextField(context, "Institute Code *", "e.g., INST001", Icons.tag, _codeController),
                        ]),
                        _buildFilePicker(context, "Institute Logo *"),
                        _buildTextField(context, "Established Year *", "2026", Icons.calendar_today, _yearController, keyboardType: TextInputType.number),

                        const SizedBox(height: 24),
                        _buildSectionHeader(context, "Location & Contact", Icons.location_on_outlined),
                        _buildTextField(context, "Address *", "Full Address", Icons.map, _addressController, maxLines: 2),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "City *", "e.g., Jaipur", Icons.location_city, _cityController),
                          _buildTextField(context, "State *", "Rajasthan", Icons.map, _stateController),
                        ]),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "Pincode *", "302001", Icons.pin_drop, _pincodeController, keyboardType: TextInputType.number),
                          _buildTextField(context, "Contact Email *", "info@example.com", Icons.email, _emailController, keyboardType: TextInputType.emailAddress),
                        ]),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "Contact Phone *", "9876543210", Icons.phone, _phoneController, keyboardType: TextInputType.phone),
                          _buildTextField(
                            context,
                            "Website",
                            "https://example.com",
                            Icons.language,
                            _websiteController,
                            keyboardType: TextInputType.url,
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              if (!v.startsWith('http://') && !v.startsWith('https://')) {
                                return 'URL must start with http:// or https://';
                              }
                              final uri = Uri.tryParse(v);
                              if (uri == null || !uri.hasAbsolutePath) {
                                return 'Enter a valid URL';
                              }
                              return null;
                            },
                          ),
                        ]),

                        const SizedBox(height: 24),
                        _buildSectionHeader(context, "Legal & Compliance", Icons.gavel_outlined),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "Chairman Name *", "Dr. John Doe", Icons.person, _chairmanController),
                          _buildTextField(context, "GST Number *", "07ABCDE1234F1Z5", Icons.receipt_long, _gstController),
                        ]),
                        _buildResponsiveRow(context, [
                          _buildTextField(context, "PAN Number *", "ABCDE1234F", Icons.badge, _panController),
                          _buildStatusDropdown(context),
                        ]),
                        _buildTextField(context, "Affiliation Details *", "Enter details", Icons.handshake, _affiliationController, maxLines: 2),

                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("CANCEL"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _save,
                                child: const Text("CREATE"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, IconData icon, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator ?? (v) => v == null || v.isEmpty ? "Required" : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Institute Status", style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _status,
            items: ["active", "inactive"].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _status = v!),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.check_circle_outline, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickLogo,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    ),
                    alignment: Alignment.center,
                    child: Text("Choose Logo", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        kIsWeb
                            ? (_fileName ?? "No file chosen")
                            : (_logoFile != null ? _logoFile!.path.split('/').last : "No file chosen"),
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
