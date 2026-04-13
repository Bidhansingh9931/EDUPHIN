import 'dart:convert';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

import 'profile_model.dart';
import 'profile_provider.dart';

class ModeratorProfilePage extends StatefulWidget {
  const ModeratorProfilePage({super.key});

  @override
  State<ModeratorProfilePage> createState() => _ModeratorProfilePageState();
}

class _ModeratorProfilePageState extends State<ModeratorProfilePage> {
  final ProfileProvider _profileProvider = ProfileProvider();
  late Future<ProfileData> _profileDataFuture;
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _genderValue;
  String? _relationshipStatusValue;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _profileProvider.fetchProfileData();
    _profileDataFuture.then(_initializeControllers);
  }

  void _initializeControllers(ProfileData data) {
    _phoneController.text = data.phone;
    _altPhoneController.text = data.alternatePhone ?? '';
    _addressController.text = data.address;
    _cityController.text = data.city;
    _pincodeController.text = data.pincode;
    _stateController.text = data.state;
    setState(() {
      _genderValue = data.gender;
      _relationshipStatusValue = data.relationshipStatus;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_newPasswordController.text.isNotEmpty && _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentData = await _profileDataFuture;
      final updatedData = ProfileData(
        id: currentData.id,
        name: currentData.name,
        email: currentData.email,
        status: currentData.status,
        emailVerifiedAt: currentData.emailVerifiedAt,
        createdAt: currentData.createdAt,
        updatedAt: currentData.updatedAt,
        roleId: currentData.roleId,
        instituteId: currentData.instituteId,
        detailsId: currentData.detailsId,
        position: currentData.position,
        employmentType: currentData.employmentType,
        userId: currentData.userId,
        photo: currentData.photo,
        gender: _genderValue ?? currentData.gender,
        dateOfBirth: currentData.dateOfBirth,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        phone: _phoneController.text,
        alternatePhone: _altPhoneController.text,
        relationshipStatus: _relationshipStatusValue ?? currentData.relationshipStatus,
        // ... include other fields from currentData
        aadharNumber: currentData.aadharNumber,
        aadharPhoto: currentData.aadharPhoto,
        xMarks: currentData.xMarks,
        xMarksheetPhoto: currentData.xMarksheetPhoto,
        xiiMarks: currentData.xiiMarks,
        xiiMarksheetPhoto: currentData.xiiMarksheetPhoto,
        qualification: currentData.qualification,
        resume: currentData.resume,
        bankAccountNumber: currentData.bankAccountNumber,
        ifscCode: currentData.ifscCode,
        bankName: currentData.bankName,
        branchName: currentData.branchName,
        salary: currentData.salary,
        joiningDate: currentData.joiningDate,
        experience: currentData.experience,
        reference: currentData.reference,
        emergencyContactName: currentData.emergencyContactName,
        emergencyContactNumber: currentData.emergencyContactNumber,
      );

      await _profileProvider.saveProfileData(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully!"), backgroundColor: Colors.green));
        _profileDataFuture = _profileProvider.fetchProfileData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save changes: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoggingOut = true);
      try {
        await _profileProvider.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout failed: $e"), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Moderator Profile"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<ProfileData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final imageUrl = ApiService.getStorageUrl(data.photo);

            return SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeader(context, data, imageUrl),
                        const SizedBox(height: 32),
                        
                        _buildSection(context, title: "Personal Details", icon: Icons.person_outline_rounded, children: [
                          _buildResponsiveRow(context, [
                            CustomDropdown(
                              label: "Gender",
                              value: _genderValue,
                              items: const ["Male", "Female", "Other"],
                              onChanged: (v) => setState(() => _genderValue = v),
                            ),
                            CustomTextField(label: "Date of Birth", controller: TextEditingController(text: data.dateOfBirth), icon: Icons.calendar_today_rounded, enabled: false),
                          ]),
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "Phone Number", controller: _phoneController, icon: Icons.phone_android_rounded),
                            CustomTextField(label: "Alternate Phone", controller: _altPhoneController),
                          ]),
                          CustomDropdown(label: "Relationship Status", value: _relationshipStatusValue, items: const ["Single", "Married", "Divorced", "Widowed"], onChanged: (v) => setState(() => _relationshipStatusValue = v)),
                        ]),

                        _buildSection(context, title: "Address Info", icon: Icons.location_on_outlined, children: [
                          CustomTextField(label: "Full Address", controller: _addressController, icon: Icons.home_outlined),
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "City", controller: _cityController),
                            CustomTextField(label: "State", controller: _stateController),
                          ]),
                          CustomTextField(label: "Pincode", controller: _pincodeController),
                        ]),

                        _buildSection(context, title: "Banking & Finance", icon: Icons.account_balance_outlined, children: [
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "Account No.", controller: TextEditingController(text: data.bankAccountNumber ?? 'N/A'), enabled: false),
                            CustomTextField(label: "IFSC Code", controller: TextEditingController(text: data.ifscCode ?? 'N/A'), enabled: false),
                          ]),
                          CustomTextField(label: "Bank Name", controller: TextEditingController(text: data.bankName ?? 'N/A'), enabled: false),
                        ]),

                        _buildSection(context, title: "Security", icon: Icons.lock_reset_rounded, children: [
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "New Password", controller: _newPasswordController, isPassword: true, icon: Icons.password_rounded),
                            CustomTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_outline_rounded),
                          ]),
                        ]),

                        _buildSection(context, title: "Work Info", icon: Icons.work_outline_rounded, children: [
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "Position", controller: TextEditingController(text: data.position), enabled: false),
                            CustomTextField(label: "Employment Type", controller: TextEditingController(text: data.employmentType), enabled: false),
                          ]),
                          _buildResponsiveRow(context, [
                            CustomTextField(label: "Joining Date", controller: TextEditingController(text: data.joiningDate ?? 'N/A'), enabled: false),
                            CustomTextField(label: "Status", controller: TextEditingController(text: data.status), enabled: false),
                          ]),
                        ]),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("UPDATE PROFILE"),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileData data, String imageUrl) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: const AssetImage('assets/images/girl_image.webp'),
            foregroundImage: data.photo.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
          ),
          const SizedBox(height: 24),
          Text(data.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          Text(data.email, style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 12),
          Chip(label: Text(data.position.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
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
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: children))),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList());
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData? icon;
  final bool isPassword;

  const CustomTextField({super.key, required this.label, required this.controller, this.enabled = true, this.icon, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: !enabled,
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({super.key, required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
