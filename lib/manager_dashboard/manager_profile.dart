import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class ManagerProfile {
  final String name;
  final String role;
  final String email;
  final String avatar;
  final String gender;
  final String dob;
  final String phone;
  final String altPhone;
  final String marriageStatus;
  final String address1;
  final String city;
  final String district;
  final String pincode;
  final String bankAccount;
  final String ifsc;
  final String bankName;
  final String employerBranch;
  final String zone;
  final String emergencyContactName;
  final String emergencyContactNumber;
  final String userName;
  final String position;
  final String employmentType;
  final String joiningDate;
  final String experience;
  final String status;

  ManagerProfile({
    required this.name,
    required this.role,
    required this.email,
    required this.avatar,
    required this.gender,
    required this.dob,
    required this.phone,
    required this.altPhone,
    required this.marriageStatus,
    required this.address1,
    required this.city,
    required this.district,
    required this.pincode,
    required this.bankAccount,
    required this.ifsc,
    required this.bankName,
    required this.employerBranch,
    required this.zone,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
    required this.userName,
    required this.position,
    required this.employmentType,
    required this.joiningDate,
    required this.experience,
    required this.status,
  });

  factory ManagerProfile.fromJson(Map<String, dynamic> json) {
    return ManagerProfile(
      name: json['name']?.toString() ?? 'N/A',
      role: json['role']?['name']?.toString() ?? 'Manager',
      email: json['email']?.toString() ?? 'N/A',
      avatar: ApiService.getStorageUrl(json['photo']?.toString()),
      gender: json['gender']?.toString() ?? '',
      dob: json['date_of_birth']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      altPhone: json['alternate_phone']?.toString() ?? '',
      marriageStatus: json['relationship_status']?.toString() ?? '',
      address1: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      bankAccount: json['bank_account_number']?.toString() ?? '',
      ifsc: json['ifsc_code']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      employerBranch: json['branch_name']?.toString() ?? '',
      zone: json['zone']?.toString() ?? '',
      emergencyContactName: json['emergency_contact_name']?.toString() ?? '',
      emergencyContactNumber: json['emergency_contact_number']?.toString() ?? '',
      userName: json['name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      employmentType: json['employment_type']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  late Future<ManagerProfile> _profileDataFuture;
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _dobController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _employerBranchController = TextEditingController();
  final _zoneController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _statusController = TextEditingController();

  final List<String> _genderOptions = const ["Male", "Female", "Other"];
  final List<String> _marriageStatusOptions = const ["Single", "Married", "Divorced", "Widowed"];

  String? _genderValue;
  String? _marriageStatusValue;
  bool _isSaving = false;

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchAndInitializeProfileData();
  }

  Future<ManagerProfile> _fetchAndInitializeProfileData() async {
    final dataMap = await ApiService.getManagerProfile();
    final data = ManagerProfile.fromJson(dataMap);

    _phoneController.text = data.phone;
    _altPhoneController.text = data.altPhone;
    _address1Controller.text = data.address1;
    _cityController.text = data.city;
    _districtController.text = data.district;
    _pincodeController.text = data.pincode;
    _dobController.text = data.dob;
    _bankAccountController.text = data.bankAccount;
    _ifscController.text = data.ifsc;
    _bankNameController.text = data.bankName;
    _employerBranchController.text = data.employerBranch;
    _zoneController.text = data.zone;
    _emergencyContactNameController.text = data.emergencyContactName;
    _emergencyContactNumberController.text = data.emergencyContactNumber;
    _userNameController.text = data.userName;
    _emailController.text = data.email;
    _positionController.text = data.position;
    _employmentTypeController.text = data.employmentType;
    _joiningDateController.text = data.joiningDate;
    _experienceController.text = data.experience;
    _statusController.text = data.status;

    if (_genderOptions.contains(data.gender)) {
      _genderValue = data.gender;
    }

    if (_marriageStatusOptions.contains(data.marriageStatus)) {
      _marriageStatusValue = data.marriageStatus;
    }

    return data;
  }

  Future<void> _pickImage() async {
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
          _imageBytes = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('yyyy-MM-dd').parse(_dobController.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveChanges(ManagerProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text.isNotEmpty && _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updatedData = {
      "phone": _phoneController.text,
      "alternate_phone": _altPhoneController.text,
      "gender": _genderValue ?? "",
      "relationship_status": _marriageStatusValue ?? "",
      "date_of_birth": _dobController.text,
      "address": _address1Controller.text,
      "city": _cityController.text,
      "state": _districtController.text,
      "pincode": _pincodeController.text,
      "bank_account_number": _bankAccountController.text,
      "ifsc_code": _ifscController.text,
      "bank_name": _bankNameController.text,
      "branch_name": _employerBranchController.text,
      "emergency_contact_name": _emergencyContactNameController.text,
      "emergency_contact_number": _emergencyContactNumberController.text,
      if (_newPasswordController.text.isNotEmpty) "password": _newPasswordController.text,
    };

    try {
      if (kIsWeb && _imageBytes != null) {
        await ApiService.updateManagerProfileFromBytes(
          updatedData,
          _imageBytes,
          _fileName
        );
      } else {
        await ApiService.updateManagerProfile(
          updatedData,
          photo: _imageFile
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved successfully!")),
        );
        setState(() {
          _imageFile = null;
          _imageBytes = null;
          _fileName = null;
          _profileDataFuture = _fetchAndInitializeProfileData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _altPhoneController.dispose();
    _address1Controller.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _dobController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _employerBranchController.dispose();
    _zoneController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _employmentTypeController.dispose();
    _joiningDateController.dispose();
    _experienceController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("My Profile", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(20))),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout_rounded, color: Colors.redAccent, size: context.scale(24)),
          ),
          SizedBox(width: context.scale(8)),
        ],
      ),
      body: FutureBuilder<ManagerProfile>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: context.scale(48), color: Colors.red),
                  SizedBox(height: context.scale(16)),
                  Text("Error: ${snapshot.error}", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
                  SizedBox(height: context.scale(16)),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _profileDataFuture = _fetchAndInitializeProfileData();
                    }),
                    child: Text("Retry", style: TextStyle(fontSize: context.font(14))),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeader(context, data),
                        SizedBox(height: context.scale(32)),
                        
                        ProfileSection(
                          title: "Personal Information", 
                          icon: Icons.person_outline_rounded,
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileDropdown(
                                label: "Gender",
                                value: _genderValue,
                                items: _genderOptions,
                                onChanged: (v) => setState(() => _genderValue = v),
                                validator: (value) => value == null ? 'Required' : null,
                              ),
                              ProfileTextField(
                                label: "Date of Birth",
                                controller: _dobController,
                                icon: Icons.calendar_today_rounded,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ]),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(
                                label: "Phone",
                                controller: _phoneController,
                                icon: Icons.phone_android_rounded,
                                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                              ),
                              ProfileTextField(
                                label: "Alternate Phone",
                                controller: _altPhoneController,
                                icon: Icons.phone_callback_rounded,
                              ),
                            ]),
                            ProfileDropdown(
                              label: "Marriage Status", 
                              value: _marriageStatusValue, 
                              items: _marriageStatusOptions, 
                              onChanged: (v) => setState(() => _marriageStatusValue = v)
                            ),
                          ]
                        ),

                        ProfileSection(
                          title: 'Address Details', 
                          icon: Icons.location_on_outlined, 
                          children: [
                            ProfileTextField(label: "Full Address", controller: _address1Controller, icon: Icons.home_outlined),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "City", controller: _cityController),
                              ProfileTextField(label: "State/District", controller: _districtController),
                            ]),
                            ProfileTextField(label: "Pincode", controller: _pincodeController),
                          ]
                        ),

                        ProfileSection(
                          title: 'Employment Information', 
                          icon: Icons.work_outline_rounded, 
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "Position", controller: _positionController, enabled: false),
                              ProfileTextField(label: "Employment Type", controller: _employmentTypeController, enabled: false),
                            ]),
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "Joining Date", controller: _joiningDateController, enabled: false),
                              ProfileTextField(label: "Experience", controller: _experienceController, enabled: false),
                            ]),
                            ProfileTextField(label: "Current Status", controller: _statusController, enabled: false),
                          ]
                        ),

                        ProfileSection(
                          title: 'Bank Details (View Only)', 
                          icon: Icons.account_balance_outlined, 
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "Account Number", controller: _bankAccountController, enabled: false),
                              ProfileTextField(label: "IFSC Code", controller: _ifscController, enabled: false),
                            ]),
                            ProfileTextField(label: "Bank Name", controller: _bankNameController, enabled: false),
                          ]
                        ),

                        ProfileSection(
                          title: 'Update Security', 
                          icon: Icons.lock_reset_rounded, 
                          children: [
                            AdaptiveFieldRow(children: [
                              ProfileTextField(label: "New Password", controller: _newPasswordController, isPassword: true, icon: Icons.password_rounded),
                              ProfileTextField(label: "Confirm New Password", controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_outline_rounded),
                            ]),
                          ]
                        ),

                        SizedBox(height: context.scale(40)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _saveChanges(data),
                            icon: _isSaving ? SizedBox(width: context.scale(20), height: context.scale(20), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.save_rounded, size: context.scale(20)),
                            label: Text(_isSaving ? "Saving..." : "Save Changes", style: TextStyle(fontSize: context.font(16))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: context.scale(18)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                            ),
                          ),
                        ),
                        SizedBox(height: context.scale(60)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No profile data available.'));
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ManagerProfile data) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(32)),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.scale(24)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: context.isMobile
          ? Column(
        children: [
          _buildAvatar(context, colorScheme, data),
          SizedBox(height: context.scale(24)),
          ..._buildHeaderInfo(context, data, theme, colorScheme),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context, colorScheme, data),
          SizedBox(width: context.scale(32)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildHeaderInfo(context, data, theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ColorScheme colorScheme, ManagerProfile data) {
    return ProfileAvatar(
      imageUrl: data.avatar,
      radius: context.scale(60),
      localImage: _imageFile,
      webImage: _imageBytes,
      onCameraTap: _pickImage,
    );
  }

  List<Widget> _buildHeaderInfo(BuildContext context, ManagerProfile data, ThemeData theme, ColorScheme colorScheme) {
    return [
      Text(
        data.name,
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: context.font(24)),
      ),
      SizedBox(height: context.scale(4)),
      Center(
        heightFactor: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(context.scale(20))),
          child: Text(data.role.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 1.2)),
        ),
      ),
      SizedBox(height: context.scale(12)),
      Text(
        data.email,
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: TextStyle(color: theme.hintColor, fontSize: context.font(14)),
      ),
    ];
  }
}
