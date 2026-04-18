import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<TeacherProfile> _profileFuture;
  TeacherProfile? _profile;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedPhoto;
  Uint8List? _webPhotoBytes;
  String? _photoName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = ApiService.getTeacherProfile();
    _profileFuture.then((profile) {
      if (mounted) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _genderController.text = profile.gender ?? '';
          _dobController.text = profile.dateOfBirth ?? '';
          _phoneController.text = profile.phone ?? '';
          _altPhoneController.text = profile.alternatePhone ?? '';
          _relationshipStatusController.text = profile.relationshipStatus ?? '';
          _addressController.text = profile.address ?? '';
          _cityController.text = profile.city ?? '';
          _stateController.text = profile.state ?? '';
          _pincodeController.text = profile.pincode ?? '';
          _accountNumberController.text = profile.bankAccountNumber ?? '';
          _ifscController.text = profile.ifscCode ?? '';
          _bankNameController.text = profile.bankName ?? '';
          _branchController.text = profile.branch ?? '';
        });
      }
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webPhotoBytes = bytes;
          _photoName = pickedFile.name;
        });
      } else {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_profile == null) return;

    if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      _profile!.name = _nameController.text;
      _profile!.gender = _genderController.text;
      _profile!.dateOfBirth = _dobController.text;
      _profile!.phone = _phoneController.text;
      _profile!.alternatePhone = _altPhoneController.text;
      _profile!.relationshipStatus = _relationshipStatusController.text;
      _profile!.address = _addressController.text;
      _profile!.city = _cityController.text;
      _profile!.state = _stateController.text;
      _profile!.pincode = _pincodeController.text;
      _profile!.bankAccountNumber = _accountNumberController.text;
      _profile!.ifscCode = _ifscController.text;
      _profile!.bankName = _bankNameController.text;
      _profile!.branch = _branchController.text;
      _profile!.password = _passwordController.text;
      _profile!.passwordConfirmation = _confirmPasswordController.text;

      if (kIsWeb) {
        await ApiService.updateTeacherProfileFromBytes(_profile!, _webPhotoBytes, _photoName);
      } else {
        _profile!.photo = _selectedPhoto;
        await ApiService.updateTeacherProfile(_profile!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
        _loadProfile();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _relationshipStatusController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.font(20),
          ),
        ),
      ),
      body: FutureBuilder<TeacherProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: context.font(14))));
          } else if (snapshot.hasData) {
            final profile = snapshot.data!;
            return SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      _buildHeader(profile),
                      SizedBox(height: context.xl),
                      AdaptiveFieldRow(children: [
                        ProfileSection(
                          title: "Personal Information",
                          icon: Icons.person_outline,
                          status: "Editable",
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileDropdown(
                                label: "Gender",
                                value: _genderController.text.isEmpty ? null : _genderController.text,
                                items: const ['Male', 'Female', 'Other'],
                                onChanged: (v) => setState(() => _genderController.text = v!),
                                icon: Icons.wc_outlined,
                              ),
                              ProfileTextField(
                                label: "Date of Birth",
                                controller: _dobController,
                                readOnly: true,
                                icon: Icons.calendar_today_rounded,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.tryParse(_dobController.text) ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() => _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
                                  }
                                },
                              ),
                            ]),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(
                                label: "Phone",
                                controller: _phoneController,
                                icon: Icons.phone_android,
                                keyboardType: TextInputType.phone,
                              ),
                              ProfileTextField(
                                label: "Alternate Phone",
                                controller: _altPhoneController,
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                            ]),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(
                                label: "Relationship Status",
                                controller: _relationshipStatusController,
                                icon: Icons.favorite_outline,
                              ),
                            ]),
                          ],
                        ),
                        ProfileSection(
                          title: "Address Information",
                          icon: Icons.home_outlined,
                          status: "Update",
                          children: [
                            ProfileTextField(
                              label: "Address",
                              controller: _addressController,
                              icon: Icons.map_outlined,
                              maxLines: 2,
                            ),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "City", controller: _cityController),
                              ProfileTextField(label: "State", controller: _stateController),
                            ]),
                            ProfileTextField(
                              label: "Pincode",
                              controller: _pincodeController,
                              icon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileSection(
                          title: "Banking Information",
                          icon: Icons.account_balance_outlined,
                          status: "Editable",
                          children: [
                            ProfileTextField(
                              label: "Bank Account Number",
                              controller: _accountNumberController,
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(
                                label: "IFSC Code",
                                controller: _ifscController,
                                icon: Icons.code,
                              ),
                              ProfileTextField(
                                label: "Bank Name",
                                controller: _bankNameController,
                                icon: Icons.account_balance,
                              ),
                            ]),
                            ProfileTextField(
                              label: "Branch Name",
                              controller: _branchController,
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                        ProfileSection(
                          title: "Security Settings",
                          icon: Icons.security_outlined,
                          status: "Editable",
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileTextField(
                                label: "New Password",
                                controller: _passwordController,
                                isPassword: true,
                                icon: Icons.lock_outline,
                              ),
                              ProfileTextField(
                                label: "Confirm Password",
                                controller: _confirmPasswordController,
                                isPassword: true,
                                icon: Icons.lock_outline,
                              ),
                            ]),
                          ],
                        ),
                      ]),
                      ProfileSection(
                        title: "Employment Details",
                        icon: Icons.work_outline,
                        status: "Read only",
                        isReadOnly: true,
                        children: [
                          AdaptiveFieldRow(children: [
                            ProfileBadge(
                              label: "POSITION",
                              value: profile.position ?? "N/A",
                              icon: Icons.badge_outlined,
                            ),
                            ProfileBadge(
                              label: "EMPLOYMENT TYPE",
                              value: profile.employmentType ?? "N/A",
                              icon: Icons.timer_outlined,
                            ),
                          ]),
                          AdaptiveFieldRow(children: [
                            ProfileBadge(
                              label: "JOINING DATE",
                              value: profile.joiningDate ?? "N/A",
                              icon: Icons.calendar_today_outlined,
                            ),
                            ProfileBadge(
                              label: "EXPERIENCE",
                              value: profile.experience ?? "N/A",
                              icon: Icons.history_outlined,
                            ),
                          ]),
                          ProfileBadge(
                            label: "STATUS",
                            value: profile.status?.toUpperCase() ?? "LIVE",
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                      SizedBox(height: context.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                          child: _isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                        ),
                      ),
                      SizedBox(height: context.xl * 2),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: Text('No data', style: TextStyle(fontSize: context.font(14))));
        },
      ),
    );
  }

  Widget _buildHeader(TeacherProfile profile) {
    final photoUrl = profile.photoUrl != null ? ApiService.getStorageUrl(profile.photoUrl) : null;
    return Flex(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileAvatar(
          radius: context.scale(60),
          imageUrl: photoUrl,
          localImage: _selectedPhoto,
          webImage: _webPhotoBytes,
          onCameraTap: _pickPhoto,
        ),
        if (!context.isMobile) SizedBox(width: context.xl),
        if (context.isMobile) SizedBox(height: context.md),
        Column(
          crossAxisAlignment: context.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(24),
              ),
            ),
            Text(
              profile.email,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(16),
              ),
            ),
            SizedBox(height: context.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.scale(12),
                vertical: context.scale(4),
              ),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(context.scale(20)),
              ),
              child: Text(
                profile.position?.toUpperCase() ?? "TEACHER",
                style: TextStyle(
                  color: context.theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
