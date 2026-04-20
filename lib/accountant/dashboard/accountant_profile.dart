import 'package:eduphin/login_logout/login.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
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
  bool _isActionLoading = false;
  File? _image;
  Uint8List? _imageBytes;
  String? _fileName;
  late Stream<UserDetail> _profileStream;

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
  final _passwordConfirmationController = TextEditingController();
  String? _gender;
  String? _relationshipStatus;

  @override
  void initState() {
    super.initState();
    _profileStream = ApiService.getAccountantProfileStream();
  }

  void _populateFields(UserDetail user) {
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
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.isNotEmpty && _passwordController.text != _passwordConfirmationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    setState(() => _isActionLoading = true);
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
        data['password_confirmation'] = _passwordConfirmationController.text;
      }

      if (kIsWeb && _imageBytes != null) {
        await ApiService.updateAccountantProfileFromBytes(data, _imageBytes, _fileName);
      } else {
        await ApiService.updateAccountantProfile(data, photo: _image);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        setState(() {
          _image = null;
          _imageBytes = null;
          _fileName = null;
          _profileStream = ApiService.getAccountantProfileStream();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

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
          _imageBytes = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() => _image = File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserDetail>(
      stream: _profileStream,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Accountant Profile", style: TextStyle(fontSize: context.font(20))),
            actions: [
              IconButton(
                tooltip: "Logout",
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ApiService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          body: LoadingWrapper<UserDetail>(
            snapshot: snapshot,
            skeleton: _buildSkeleton(context),
            onRetry: () => setState(() => _profileStream = ApiService.getAccountantProfileStream()),
            builder: (user) {
              _populateFields(user);
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildHeader(context, user),
                              SizedBox(height: context.xl),
                              AdaptiveFieldRow(children: [
                                ProfileSection(
                                  title: "Account Info",
                                  icon: Icons.account_circle_outlined,
                                  children: [
                                    ProfileTextField(
                                      label: "Full Name",
                                      controller: _nameController,
                                      enabled: false,
                                      icon: Icons.person_outline,
                                    ),
                                    ProfileTextField(
                                      label: "Email Address",
                                      controller: _emailController,
                                      enabled: false,
                                      icon: Icons.email_outlined,
                                    ),
                                  ],
                                ),
                                ProfileSection(
                                  title: "Personal Info",
                                  icon: Icons.person_outline,
                                  children: [
                                    AdaptiveFieldRow(children: [
                                      ProfileDropdown(
                                        label: "Gender",
                                        value: _gender,
                                        items: const ['Male', 'Female', 'Other'],
                                        onChanged: (v) => setState(() => _gender = v),
                                        icon: Icons.wc_outlined,
                                      ),
                                      ProfileDropdown(
                                        label: "Relationship",
                                        value: _relationshipStatus,
                                        items: const ['Single', 'Married', 'Divorced', 'Widowed'],
                                        onChanged: (v) => setState(() => _relationshipStatus = v),
                                        icon: Icons.favorite_outline,
                                      ),
                                    ]),
                                    ProfileTextField(
                                      label: "Date of Birth",
                                      controller: _dobController,
                                      readOnly: true,
                                      icon: Icons.calendar_today_rounded,
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(() => _dobController.text = DateFormat('yyyy-MM-dd').format(picked));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ]),
                              AdaptiveFieldRow(children: [
                                ProfileSection(
                                  title: "Contact Details",
                                  icon: Icons.contact_phone_outlined,
                                  children: [
                                    ProfileTextField(
                                      label: "Phone Number",
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      icon: Icons.phone_android,
                                    ),
                                    ProfileTextField(
                                      label: "Alternate Phone",
                                      controller: _altPhoneController,
                                      keyboardType: TextInputType.phone,
                                      icon: Icons.phone,
                                    ),
                                  ],
                                ),
                                ProfileSection(
                                  title: "Residential Address",
                                  icon: Icons.home_outlined,
                                  children: [
                                    ProfileTextField(
                                      label: "Full Address",
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
                                      keyboardType: TextInputType.number,
                                      icon: Icons.pin_drop_outlined,
                                    ),
                                  ],
                                ),
                              ]),
                              ProfileSection(
                                title: "Banking & Documents",
                                icon: Icons.account_balance_outlined,
                                children: [
                                  ProfileTextField(
                                    label: "Bank Name",
                                    controller: _bankNameController,
                                    icon: Icons.account_balance_outlined,
                                  ),
                                  ProfileTextField(
                                    label: "Account Number",
                                    controller: _bankAccountController,
                                    keyboardType: TextInputType.number,
                                    icon: Icons.numbers,
                                  ),
                                  AdaptiveFieldRow(children: [
                                    ProfileTextField(label: "IFSC Code", controller: _ifscController),
                                    ProfileTextField(label: "Branch", controller: _branchController),
                                  ]),
                                ],
                              ),
                              ProfileSection(
                                title: "Security",
                                icon: Icons.security_outlined,
                                children: [
                                  AdaptiveFieldRow(children: [
                                    ProfileTextField(
                                      label: "New Password (Optional)",
                                      controller: _passwordController,
                                      isPassword: true,
                                      icon: Icons.lock_outline,
                                    ),
                                    ProfileTextField(
                                      label: "Confirm New Password",
                                      controller: _passwordConfirmationController,
                                      isPassword: true,
                                      icon: Icons.lock_outline,
                                    ),
                                  ]),
                                ],
                              ),
                              SizedBox(height: context.xl),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                  ),
                                  child: Text("SAVE CHANGES", style: TextStyle(fontSize: context.font(14))),
                                ),
                              ),
                              SizedBox(height: context.xl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isActionLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          ),
        );
      },
    );

  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Skeleton(height: context.scale(120), width: context.scale(120), borderRadius: context.scale(60)),
                  SizedBox(width: context.xl),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(height: context.font(24), width: context.scale(200)),
                      SizedBox(height: context.scale(8)),
                      Skeleton(height: context.font(16), width: context.scale(150)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.xl),
              Skeleton(height: context.scale(150), width: double.infinity, borderRadius: context.scale(12)),
              SizedBox(height: context.xl),
              Skeleton(height: context.scale(150), width: double.infinity, borderRadius: context.scale(12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserDetail? user) {
    return Flex(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileAvatar(
          radius: context.scale(60),
          localImage: _image,
          webImage: _imageBytes,
          imageUrl: ApiService.getStorageUrl(user?.photo),
          onCameraTap: _pickImage,
        ),
        if (!context.isMobile) SizedBox(width: context.xl),
        if (context.isMobile) SizedBox(height: context.md),
        Column(
          crossAxisAlignment: context.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              _nameController.text,
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(24),
              ),
            ),
            Text(
              _emailController.text,
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
                "ACCOUNTANT",
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
