import 'dart:io';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

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
      final data = await _profileDataFuture;
      final Map<String, String> updatedData = {
        "phone": _phoneController.text,
        "alternate_phone": _altPhoneController.text,
        "gender": _genderValue ?? '',
        "relationship_status": _relationshipStatusValue ?? '',
        "address": _addressController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "pincode": _pincodeController.text,
        "date_of_birth": data.dateOfBirth ?? '',
        "bank_account_number": data.bankAccountNumber ?? '',
        "bank_name": data.bankName ?? '',
        "ifsc_code": data.ifscCode ?? '',
        "branch_name": data.branchName ?? '',
        "emergency_contact_name": data.emergencyContactName ?? '',
        "emergency_contact_number": data.emergencyContactNumber ?? '',
        "qualification": data.qualification ?? '',
        "aadhar_number": data.aadharNumber ?? '',
        "x_marks": data.xMarks.toString(),
        "xii_marks": data.xiiMarks.toString(),
        "position": data.position,
        "employment_type": data.employmentType,
        "salary": data.salary ?? '',
        "joining_date": data.joiningDate ?? '',
        "experience": data.experience?.toString() ?? '',
        "status": data.status ?? '',
        "reference": data.reference ?? '',
        if (_newPasswordController.text.isNotEmpty) "password": _newPasswordController.text,
      };

      await _profileProvider.saveProfileData(updatedData, photo: _imageFile, webImage: _webImage, fileName: _fileName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully!"), backgroundColor: Colors.green));
        setState(() {
          _imageFile = null;
          _webImage = null;
          _fileName = null;
          _profileDataFuture = _profileProvider.fetchProfileData();
        });
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
      try {
        await _profileProvider.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logout failed: $e"), backgroundColor: Colors.red));
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Moderator Profile", style: TextStyle(fontSize: context.font(20))),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
          SizedBox(width: context.scale(8)),
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
                  constraints: BoxConstraints(maxWidth: context.scale(900)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeader(context, data, imageUrl),
                        SizedBox(height: context.scale(32)),
                        
                        ProfileSection(title: "Personal Details", icon: Icons.person_outline_rounded, children: [
                          AdaptiveFieldRow(children: [
                            ProfileDropdown(
                              label: "Gender",
                              value: _genderValue,
                              items: const ["Male", "Female", "Other"],
                              onChanged: (v) => setState(() => _genderValue = v),
                            ),
                            ProfileTextField(label: "Date of Birth", controller: TextEditingController(text: data.dateOfBirth), icon: Icons.calendar_today_rounded, enabled: false),
                          ]),
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "Phone Number", controller: _phoneController, icon: Icons.phone_android_rounded),
                            ProfileTextField(label: "Alternate Phone", controller: _altPhoneController),
                          ]),
                          ProfileDropdown(label: "Relationship Status", value: _relationshipStatusValue, items: const ["Single", "Married", "Divorced", "Widowed"], onChanged: (v) => setState(() => _relationshipStatusValue = v)),
                        ]),

                        ProfileSection(title: "Address Info", icon: Icons.location_on_outlined, children: [
                          ProfileTextField(label: "Full Address", controller: _addressController, icon: Icons.home_outlined),
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "City", controller: _cityController),
                            ProfileTextField(label: "State", controller: _stateController),
                          ]),
                          ProfileTextField(label: "Pincode", controller: _pincodeController),
                        ]),

                        ProfileSection(title: "Banking & Finance", icon: Icons.account_balance_outlined, children: [
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "Account No.", controller: TextEditingController(text: data.bankAccountNumber ?? 'N/A'), enabled: false),
                            ProfileTextField(label: "IFSC Code", controller: TextEditingController(text: data.ifscCode ?? 'N/A'), enabled: false),
                          ]),
                          ProfileTextField(label: "Bank Name", controller: TextEditingController(text: data.bankName ?? 'N/A'), enabled: false),
                        ]),

                        ProfileSection(title: "Security", icon: Icons.lock_reset_rounded, children: [
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "New Password", controller: _newPasswordController, isPassword: true, icon: Icons.password_rounded),
                            ProfileTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_outline_rounded),
                          ]),
                        ]),

                        ProfileSection(title: "Work Info", icon: Icons.work_outline_rounded, children: [
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "Position", controller: TextEditingController(text: data.position), enabled: false),
                            ProfileTextField(label: "Employment Type", controller: TextEditingController(text: data.employmentType), enabled: false),
                          ]),
                          AdaptiveFieldRow(children: [
                            ProfileTextField(label: "Joining Date", controller: TextEditingController(text: data.joiningDate ?? 'N/A'), enabled: false),
                            ProfileTextField(label: "Status", controller: TextEditingController(text: data.status), enabled: false),
                          ]),
                        ]),

                        SizedBox(height: context.scale(40)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: context.scale(18)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16)))),
                            child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("UPDATE PROFILE"),
                          ),
                        ),
                        SizedBox(height: context.scale(60)),
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
    final theme = context.theme;
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(isMobile ? 24 : 32)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(24)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            imageUrl: imageUrl,
            radius: context.scale(isMobile ? 50 : 60),
            localImage: _imageFile,
            webImage: _webImage,
            onCameraTap: _pickImage,
          ),
          SizedBox(
            width: isMobile ? 0 : context.scale(32),
            height: isMobile ? context.scale(20) : 0,
          ),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: context.font(24),
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                Text(
                  data.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.scale(12)),
                Chip(
                  label: Text(
                    data.position.toUpperCase(),
                    style: TextStyle(
                      fontSize: context.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
