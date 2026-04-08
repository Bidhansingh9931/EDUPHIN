import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddNewInstitutePage extends StatefulWidget {
  const AddNewInstitutePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddInstitutePageState();
}

class _AddInstitutePageState extends State<AddNewInstitutePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
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
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  Future<void> _addInstitute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final token = await ApiService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication token not found.')));
        setState(() => _isLoading = false);
      }
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/moderator/institutes'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields.addAll({
      'name': _nameController.text,
      'code': _codeController.text,
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
      'status': 'pending',
    });

    if (_logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', _logo!.path));
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institute added successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } else {
        final error = jsonDecode(responseBody);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error['message'] ?? 'Failed to add'}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Institute'),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildLogoPicker(theme),
                  const SizedBox(height: 32),
                  
                  _buildFormSection(context, title: "General Information", icon: Icons.info_outline_rounded, fields: [
                    _buildResponsiveRow(context, [
                      _buildTextField(controller: _nameController, label: 'Institute Name *', icon: Icons.business_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(controller: _codeController, label: 'Institute Code *', icon: Icons.qr_code_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(controller: _chairmanNameController, label: 'Chairman Name *', icon: Icons.person_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(controller: _establishedYearController, label: 'Established Year *', icon: Icons.calendar_today_rounded, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                  ]),

                  _buildFormSection(context, title: "Contact Details", icon: Icons.contact_mail_outlined, fields: [
                    _buildResponsiveRow(context, [
                      _buildTextField(controller: _contactEmailController, label: 'Email *', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(controller: _contactPhoneController, label: 'Phone *', icon: Icons.phone_rounded, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                    _buildTextField(controller: _websiteController, label: 'Website', icon: Icons.language_rounded, keyboardType: TextInputType.url),
                  ]),

                  _buildFormSection(context, title: "Location Details", icon: Icons.map_outlined, fields: [
                    _buildTextField(controller: _addressController, label: 'Address *', icon: Icons.location_on_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    _buildResponsiveRow(context, [
                      _buildTextField(controller: _cityController, label: 'City *', validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(controller: _stateController, label: 'State *', validator: (v) => v!.isEmpty ? 'Required' : null),
                      _buildTextField(controller: _pincodeController, label: 'Pincode *', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                    ]),
                  ]),

                  _buildFormSection(context, title: "Others", icon: Icons.more_horiz_rounded, fields: [
                    _buildTextField(controller: _affiliationDetailsController, label: 'Affiliation Details', icon: Icons.verified_user_rounded, maxLines: 2),
                  ]),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addInstitute,
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.add_business_rounded),
                      label: Text(_isLoading ? "REGISTERING..." : "REGISTER INSTITUTE"),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPicker(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2), width: 4),
                  image: _logo != null ? DecorationImage(image: FileImage(_logo!), fit: BoxFit.cover) : null,
                ),
                child: _logo == null ? Icon(Icons.business_rounded, size: 50, color: theme.colorScheme.primary.withOpacity(0.5)) : null,
              ),
              InkWell(
                onTap: _pickLogo,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Institutional Logo", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required IconData icon, required List<Widget> fields}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: fields))),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList());
  }

  Widget _buildTextField({required TextEditingController controller, required String label, IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: icon != null ? Icon(icon, size: 20) : null),
        validator: validator,
      ),
    );
  }
}
