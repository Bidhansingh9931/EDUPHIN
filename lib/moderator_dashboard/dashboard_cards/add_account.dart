import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/api_service.dart';
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        Navigator.pop(context, true); // Go back and indicate success
      } else {
        if (!mounted) return;
        final error = jsonDecode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: ${error['message']}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Add New Account', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFF1B263B),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(_nameController, 'Name'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_emailController, 'Email'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_passwordController, 'Password', obscureText: true),
                  const SizedBox(height: 16),
                  _buildTextFormField(_employmentTypeController, 'Employment Type'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_genderController, 'Gender'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_dobController, 'Date of Birth (YYYY-MM-DD)'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_aadharController, 'Aadhar Number'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_phoneController, 'Phone'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_altPhoneController, 'Alternate Phone'),
                  const SizedBox(height: 16),
                  _buildTextFormField(_bankAccountController, 'Bank Account Number'),
                  const SizedBox(height: 24),
                  _buildFileUploadSection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFF0D1B2A).withOpacity(0.5),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Documents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        _buildFileUploadButton('Photo', _photo, (file) => setState(() => _photo = file)),
        _buildFileUploadButton('Aadhar Photo', _aadharPhoto, (file) => setState(() => _aadharPhoto = file)),
        _buildFileUploadButton('X Marksheet', _xMarksheet, (file) => setState(() => _xMarksheet = file)),
        _buildFileUploadButton('XII Marksheet', _xiiMarksheet, (file) => setState(() => _xiiMarksheet = file)),
        _buildFileUploadButton('Resume', _resume, (file) => setState(() => _resume = file)),
      ],
    );
  }

  Widget _buildFileUploadButton(String title, File? file, Function(File) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _pickImage(onSelect),
            icon: const Icon(Icons.upload_file),
            label: Text('Upload $title'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2).withOpacity(0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              file?.path.split('/').last ?? 'No file selected',
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
