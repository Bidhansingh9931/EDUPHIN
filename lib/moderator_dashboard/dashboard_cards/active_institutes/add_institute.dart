import 'package:eduphin/services/error_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddNewInstitutePage extends StatefulWidget {
  const AddNewInstitutePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddInstitutePageState();
}

class _AddInstitutePageState extends State<AddNewInstitutePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _chairmanNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _affiliationDetailsController = TextEditingController();

  File? _logo;
  Uint8List? _webLogo;
  String? _fileName;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _establishedYearController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _chairmanNameController.dispose();
    _websiteController.dispose();
    _affiliationDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webLogo = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _logo = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _addInstitute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, String> fields = {
      'name': _nameController.text,
      'code': _codeController.text,
      'gst_number': _gstController.text,
      'pan_number': _panController.text,
      'established_year': _establishedYearController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'contact_email': _contactEmailController.text,
      'contact_phone': _contactPhoneController.text,
      'chairman_name': _chairmanNameController.text,
      'website': _websiteController.text,
      'affiliation_details': _affiliationDetailsController.text,
      'status': 'active',
    };

    try {
      http.StreamedResponse response;
      if (kIsWeb && _webLogo != null) {
        response = await ApiService.postMultipartFromBytes(
          'moderator/institutes',
          fields,
          files: {'logo': _webLogo!},
          fileNames: {'logo': _fileName!},
        );
      } else {
        final Map<String, File> files = {};
        if (_logo != null) {
          files['logo'] = _logo!;
        }
        response = await ApiService.postMultipart('moderator/institutes', fields, files: files);
      }

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Clear institute list cache to force refresh
        await CacheHelper.clear('institutes_list');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Institute added successfully!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } else {
        throw ApiException('Failed to add institute',
            statusCode: response.statusCode);
      }
    } on SocketException {
      if (mounted) ErrorHandler.showError(context, NetworkException());
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New Institute', style: TextStyle(fontSize: context.font(20))),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.responsive(600.0, tablet: 800.0, desktop: 1000.0)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildLogoPicker(context),
                  SizedBox(height: context.lg),
                  
                  _buildFormSection(context, title: "General Information", icon: Icons.info_outline_rounded, fields: [
                    _buildResponsiveRow(context, [
                      _buildTextField(context, controller: _nameController, label: 'Institute Name *', icon: Icons.business_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(context, controller: _codeController, label: 'Institute Code *', icon: Icons.qr_code_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, controller: _gstController, label: 'GST Number', icon: Icons.receipt_long_rounded),
                      _buildTextField(context, controller: _panController, label: 'PAN Number', icon: Icons.credit_card_rounded),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, controller: _chairmanNameController, label: 'Chairman Name *', icon: Icons.person_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(context, controller: _establishedYearController, label: 'Established Year *', icon: Icons.calendar_today_rounded, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                  ]),

                  _buildFormSection(context, title: "Contact Details", icon: Icons.contact_mail_outlined, fields: [
                    _buildResponsiveRow(context, [
                      _buildTextField(context, controller: _contactEmailController, label: 'Email *', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(context, controller: _contactPhoneController, label: 'Phone *', icon: Icons.phone_rounded, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                    _buildTextField(
                      context,
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language_rounded,
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

                  _buildFormSection(context, title: "Location Details", icon: Icons.map_outlined, fields: [
                    _buildTextField(context, controller: _addressController, label: 'Address *', icon: Icons.location_on_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, controller: _cityController, label: 'City *', validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(context, controller: _stateController, label: 'State *', validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(context, controller: _pincodeController, label: 'Pincode *', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                  ]),

                  _buildFormSection(context, title: "Others", icon: Icons.more_horiz_rounded, fields: [
                    _buildTextField(context, controller: _affiliationDetailsController, label: 'Affiliation Details', icon: Icons.verified_user_rounded, maxLines: 2),
                  ]),

                  SizedBox(height: context.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addInstitute,
                      icon: _isLoading 
                        ? SizedBox(
                            width: context.scale(20), 
                            height: context.scale(20), 
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary)
                          ) 
                        : Icon(Icons.add_business_rounded, size: context.scale(20)),
                      label: Text(_isLoading ? "REGISTERING..." : "REGISTER INSTITUTE", style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: context.scale(18)), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: context.scale(60)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPicker(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            radius: context.scale(60),
            localImage: _logo,
            webImage: _webLogo,
            onCameraTap: _pickLogo,
          ),
          SizedBox(height: context.sm),
          Text("Institutional Logo", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14), color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required IconData icon, required List<Widget> fields}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: context.sm),
            child: Row(
              children: [
                Icon(icon, size: context.scale(20), color: colorScheme.primary),
                SizedBox(width: context.sm),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: colorScheme.onSurface)),
              ],
            ),
          ),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.md), 
              child: Column(children: fields)
            )
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: context.md), child: c))).toList()
    );
  }

  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String label, IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
          prefixIcon: icon != null ? Icon(icon, size: context.scale(20), color: colorScheme.primary) : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
