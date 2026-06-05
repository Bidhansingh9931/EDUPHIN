import 'package:eduphin/services/error_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddAccountPage extends StatefulWidget {
  final String instituteId;
  final String roleId;

  const AddAccountPage({
    super.key,
    required this.instituteId,
    required this.roleId,
  });

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadharController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _bankAccountController = TextEditingController();

  File? _photo;
  File? _aadharPhoto;
  File? _xMarksheet;
  File? _xiiMarksheet;
  File? _resume;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(File) onSelect) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        onSelect(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fields = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'employment_type': _employmentTypeController.text,
      'gender': _genderController.text,
      'date_of_birth': _dobController.text,
      'aadhar_number': _aadharController.text,
      'phone': _phoneController.text,
      'alternate_phone': _altPhoneController.text,
      'bank_account_number': _bankAccountController.text,
      'institute_id': widget.instituteId,
      'role_id': widget.roleId,
    };

    final files = <String, File>{};
    if (_photo != null) {
      files['photo'] = _photo!;
    }
    if (_aadharPhoto != null) {
      files['aadhar_photo'] = _aadharPhoto!;
    }
    if (_xMarksheet != null) {
      files['x_marksheet_photo'] = _xMarksheet!;
    }
    if (_xiiMarksheet != null) {
      files['xii_marksheet_photo'] = _xiiMarksheet!;
    }
    if (_resume != null) {
      files['resume'] = _resume!;
    }

    try {
      final response = await ApiService.postMultipart('moderator/accounts', fields, files: files);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Clear accounts list cache for this institute
        await CacheHelper.clear('accounts_list_${widget.instituteId}');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Go back and indicate success
      } else {
        final error = jsonDecode(responseBody);
        throw ApiException(error['message'] ?? 'Failed to create account',
            statusCode: response.statusCode);
      }
    } on SocketException {
      if (mounted) ErrorHandler.showError(context, NetworkException());
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Account', style: TextStyle(fontSize: context.font(20))),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(800)),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(context.scale(12)),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextFormField(context, _nameController, 'Name'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _emailController, 'Email'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _passwordController, 'Password', obscureText: true),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _employmentTypeController, 'Employment Type'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _genderController, 'Gender'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _dobController, 'Date of Birth (YYYY-MM-DD)'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _aadharController, 'Aadhar Number'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _phoneController, 'Phone'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _altPhoneController, 'Alternate Phone'),
                      SizedBox(height: context.md),
                      _buildTextFormField(context, _bankAccountController, 'Bank Account Number'),
                      SizedBox(height: context.lg),
                      _buildFileUploadSection(context),
                      SizedBox(height: context.lg),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(12)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold),
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

  Widget _buildTextFormField(BuildContext context, TextEditingController controller, String label, {bool obscureText = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildFileUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
          style: TextStyle(
            fontSize: context.font(18), 
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.md),
        _buildFileUploadButton(context, 'Photo', _photo, (file) => setState(() => _photo = file)),
        _buildFileUploadButton(context, 'Aadhar Photo', _aadharPhoto, (file) => setState(() => _aadharPhoto = file)),
        _buildFileUploadButton(context, 'X Marksheet', _xMarksheet, (file) => setState(() => _xMarksheet = file)),
        _buildFileUploadButton(context, 'XII Marksheet', _xiiMarksheet, (file) => setState(() => _xiiMarksheet = file)),
        _buildFileUploadButton(context, 'Resume', _resume, (file) => setState(() => _resume = file)),
      ],
    );
  }

  Widget _buildFileUploadButton(BuildContext context, String title, File? file, Function(File) onSelect) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sm),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => _pickImage(onSelect),
            icon: Icon(Icons.upload_file, size: context.scale(20)),
            label: Text('Upload $title', style: TextStyle(fontSize: context.font(13))),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, context.scale(46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scale(8)),
              ),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: Text(
              file?.path.split('/').last ?? 'No file selected',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}
