import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class CounselorProfilePage extends StatefulWidget {
  const CounselorProfilePage({super.key});

  @override
  State<CounselorProfilePage> createState() => _CounselorProfilePageState();
}

class _CounselorProfilePageState extends State<CounselorProfilePage> {
  bool _isLoading = true;
  UserDetail? _userDetail;
  File? _imageFile;

  final _formKey = GlobalKey<FormState>();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    try {
      final response = await ApiService.get('counselor/profile');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // The PHP API returns details inside 'data' directly
        final userDetail = UserDetail.fromJson(responseData['data'] ?? responseData);
        
        if (mounted) {
          setState(() {
            _userDetail = userDetail;
            _genderController.text = userDetail.gender ?? '';
            _dobController.text = userDetail.dateOfBirth ?? '';
            _addressController.text = userDetail.address ?? '';
            _cityController.text = userDetail.city ?? '';
            _stateController.text = userDetail.state ?? '';
            _pincodeController.text = userDetail.pincode ?? '';
            _phoneController.text = userDetail.phone ?? '';
            _altPhoneController.text = userDetail.phone ?? ''; 
            _bankAccController.text = userDetail.bankAccountNumber ?? '';
            _ifscController.text = userDetail.ifscCode ?? '';
            _bankNameController.text = userDetail.bankName ?? '';
            _branchNameController.text = userDetail.branchName ?? '';
            _relationshipController.text = userDetail.relationshipStatus ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final fields = {
        'gender': _genderController.text,
        'date_of_birth': _dobController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
        'relationship_status': _relationshipController.text,
        'bank_account_number': _bankAccController.text,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchNameController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        fields['password'] = _passwordController.text;
        fields['password_confirmation'] = _passwordController.text;
      }

      final files = _imageFile != null ? {'photo': _imageFile!} : null;
      final response = await ApiService.postMultipart('counselor/profile/update', fields, files: files);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading && _userDetail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        actions: [
          IconButton(onPressed: _updateProfile, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 32),
                  _buildSection(context, "Personal Details", [
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Gender", _genderController),
                      _buildTextField(context, "Date of Birth", _dobController),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Phone Number", _phoneController),
                      _buildTextField(context, "Relationship", _relationshipController),
                    ]),
                  ]),
                  _buildSection(context, "Employment Info", [
                    _buildReadOnlyField(context, "Employee ID", _userDetail?.employeeId ?? ""),
                    _buildReadOnlyField(context, "Joining Date", _userDetail?.joiningDate ?? ""),
                  ]),
                  _buildSection(context, "Address Details", [
                    _buildTextField(context, "Full Address", _addressController),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "City", _cityController),
                      _buildTextField(context, "State", _stateController),
                    ]),
                  ]),
                  _buildSection(context, "Banking Info", [
                    _buildTextField(context, "Account Number", _bankAccController),
                    _buildResponsiveRow(context, [
                      _buildTextField(context, "Bank Name", _bankNameController),
                      _buildTextField(context, "IFSC Code", _ifscController),
                    ]),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading ? const CircularProgressIndicator() : const Text("UPDATE PROFILE"),
                    ),
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

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary, width: 2)),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? ClipOval(
                          child: Image.network(
                            "${ApiService.baseImageUrl}/${_userDetail?.photo}",
                            width: 120, height: 120, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_userDetail?.fullName ?? "Unknown User", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(_userDetail?.position ?? "Counselor", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
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

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }
}
