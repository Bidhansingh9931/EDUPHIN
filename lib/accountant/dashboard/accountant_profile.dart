import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';
import 'package:intl/intl.dart';

class AccountantProfile extends StatefulWidget {
  const AccountantProfile({super.key});

  @override
  State<AccountantProfile> createState() => _AccountantProfileState();
}

class _AccountantProfileState extends State<AccountantProfile> {
  bool _isLoading = true;
  UserDetail? _user;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender;
  String? _relationshipStatus;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    try {
      final user = await ApiService.getAccountantProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          _altPhoneController.text = user.alternatePhone ?? '';
          _dobController.text = user.dateOfBirth ?? '';
          _addressController.text = user.address ?? '';
          _cityController.text = user.city ?? '';
          _stateController.text = user.state ?? '';
          _pincodeController.text = user.pincode ?? '';
          _bankAccountController.text = user.bankAccountNumber ?? '';
          _ifscController.text = user.ifscCode ?? '';
          _bankNameController.text = user.bankName ?? '';
          _branchController.text = user.branchName ?? '';
          _emergencyNameController.text = user.emergencyContactName ?? '';
          _emergencyPhoneController.text = user.emergencyContactNumber ?? '';
          _gender = user.gender;
          _relationshipStatus = user.relationshipStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, String> data = {
        'gender': _gender ?? 'Male',
        'date_of_birth': _dobController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
        'relationship_status': _relationshipStatus ?? 'Single',
        'bank_account_number': _bankAccountController.text,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_number': _emergencyPhoneController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      await ApiService.updateAccountantProfile(data, photo: _image);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accountant Profile"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileImage(context),
                        const SizedBox(height: 32),
                        _buildResponsiveSection(context, [
                          _buildSection(context, "Account Info", [
                            _buildTextField(context, "Full Name", _nameController, enabled: false, icon: Icons.person_outline),
                            _buildTextField(context, "Email Address", _emailController, enabled: false, icon: Icons.email_outlined),
                          ]),
                          _buildSection(context, "Personal Info", [
                            _buildResponsiveRow(context, [
                              _buildDropdown(context, "Gender", _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v)),
                              _buildDropdown(context, "Relationship", _relationshipStatus, ['Single', 'Married', 'Divorced', 'Widowed'], (v) => setState(() => _relationshipStatus = v)),
                            ]),
                            _buildDateField(context, "Date of Birth", _dobController),
                          ]),
                        ]),
                        _buildResponsiveSection(context, [
                          _buildSection(context, "Contact Details", [
                            _buildTextField(context, "Phone Number", _phoneController, keyboardType: TextInputType.phone, icon: Icons.phone_android),
                            _buildTextField(context, "Alternate Phone", _altPhoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
                          ]),
                          _buildSection(context, "Residential Address", [
                            _buildTextField(context, "Full Address", _addressController, icon: Icons.home_outlined, maxLines: 2),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "City", _cityController),
                              _buildTextField(context, "State", _stateController),
                            ]),
                            _buildTextField(context, "Pincode", _pincodeController, keyboardType: TextInputType.number, icon: Icons.pin_drop_outlined),
                          ]),
                        ]),
                        _buildSection(context, "Banking & Documents", [
                          _buildTextField(context, "Bank Name", _bankNameController, icon: Icons.account_balance_outlined),
                          _buildTextField(context, "Account Number", _bankAccountController, keyboardType: TextInputType.number, icon: Icons.numbers),
                          _buildResponsiveRow(context, [
                            _buildTextField(context, "IFSC Code", _ifscController),
                            _buildTextField(context, "Branch", _branchController),
                          ]),
                        ]),
                        _buildSection(context, "Security", [
                          _buildTextField(context, "New Password (Optional)", _passwordController, obscureText: true, icon: Icons.lock_outline),
                        ]),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text("SAVE CHANGES"),
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

  Widget _buildProfileImage(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary, width: 2)),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : (_user?.photo != null ? NetworkImage("${ApiService.baseUrl}/storage/${_user!.photo}") : null) as ImageProvider?,
              child: _image == null && _user?.photo == null ? Icon(Icons.person, size: 60, color: theme.colorScheme.primary) : null,
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
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
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

  Widget _buildResponsiveSection(BuildContext context, List<Widget> sections) {
    if (!context.isTablet) return Column(children: sections);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: s))).toList(),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, {bool enabled = true, bool obscureText = false, TextInputType? keyboardType, IconData? icon, int maxLines = 1}) {
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
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            ),
            validator: (value) => value!.isEmpty && enabled ? "Required" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
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
            readOnly: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today_rounded, size: 18),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.list, size: 18)),
          ),
        ],
      ),
    );
  }
}
