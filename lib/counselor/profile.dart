import 'dart:io';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:eduphin/counselor/counselor_models.dart' as counselor_model;

class CounselorProfilePage extends StatefulWidget {
  const CounselorProfilePage({super.key});

  @override
  State<CounselorProfilePage> createState() => _CounselorProfilePageState();
}

class _CounselorProfilePageState extends State<CounselorProfilePage> {
  bool _isLoading = true;
  counselor_model.UserDetail? _userDetail;
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
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
  final _qualificationController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();
  final _aadharController = TextEditingController();
  final _xMarksController = TextEditingController();
  final _xiiMarksController = TextEditingController();
  final _salaryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _genderOptions = const ["Male", "Female", "Other"];
  final List<String> _marriageStatusOptions = const ["Single", "Married", "Divorced", "Widowed"];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _bankAccController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _relationshipController.dispose();
    _qualificationController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    _aadharController.dispose();
    _xMarksController.dispose();
    _xiiMarksController.dispose();
    _salaryController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    try {
      final json = await ApiService.getCounselorProfile();
      final userDetail = counselor_model.UserDetail.fromJson(json);
      if (!mounted) return;
      setState(() {
        _userDetail = userDetail;
        _nameController.text = userDetail.fullName;
        _genderController.text = userDetail.gender ?? '';
        _dobController.text = userDetail.dateOfBirth ?? '';
        _addressController.text = userDetail.address ?? '';
        _cityController.text = userDetail.city ?? '';
        _stateController.text = userDetail.state ?? '';
        _pincodeController.text = userDetail.pincode ?? '';
        _phoneController.text = userDetail.phone ?? '';
        _altPhoneController.text = userDetail.alternatePhone ?? '';
        _bankAccController.text = userDetail.bankAccountNumber ?? '';
        _ifscController.text = userDetail.ifscCode ?? '';
        _bankNameController.text = userDetail.bankName ?? '';
        _branchNameController.text = userDetail.branchName ?? '';
        _relationshipController.text = userDetail.relationshipStatus ?? '';
        _qualificationController.text = userDetail.qualification ?? '';
        _emergencyContactNameController.text = userDetail.emergencyContactName ?? '';
        _emergencyContactNumberController.text = userDetail.emergencyContactNumber ?? '';
        _aadharController.text = userDetail.aadharNumber ?? '';
        _xMarksController.text = userDetail.xMarks ?? '';
        _xiiMarksController.text = userDetail.xiiMarks ?? '';
        _salaryController.text = userDetail.salary ?? '';
        _experienceController.text = userDetail.experience ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching profile: $e")));
        setState(() => _isLoading = false);
      }
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
    if (picked != null && mounted) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

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
        'emergency_contact_name': _emergencyContactNameController.text,
        'emergency_contact_number': _emergencyContactNumberController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        fields['password'] = _passwordController.text;
        fields['password_confirmation'] = _confirmPasswordController.text;
      }

      if (kIsWeb) {
        await ApiService.updateCounselorProfileFromBytes(fields, _webImage, _fileName);
      } else {
        await ApiService.updateCounselorProfile(fields, photo: _imageFile);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
      setState(() {
        _imageFile = null;
        _webImage = null;
        _fileName = null;
      });
      _fetchProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (_isLoading && _userDetail == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Profile Settings",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProfile,
            icon: Icon(Icons.check, size: context.scale(24), color: theme.colorScheme.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(800)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  SizedBox(height: context.spacing * 2),
                  
                  ProfileSection(
                    title: "Personal Details", 
                    icon: Icons.person_outline_rounded,
                    children: [
                      ProfileTextField(
                        label: "Full Name", 
                        controller: _nameController,
                        enabled: false,
                        icon: Icons.person_outline,
                      ),
                      AdaptiveFieldRow(children: [
                        ProfileDropdown(
                          label: "Gender", 
                          value: _genderOptions.contains(_genderController.text) ? _genderController.text : null, 
                          items: _genderOptions, 
                          onChanged: (v) => setState(() => _genderController.text = v ?? ""),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        ProfileTextField(
                          label: "Date of Birth", 
                          controller: _dobController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          icon: Icons.calendar_today_rounded,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(
                          label: "Phone Number", 
                          controller: _phoneController,
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (v.length != 10) return "Must be 10 digits";
                            return null;
                          },
                        ),
                        ProfileTextField(
                          label: "Alternate Phone", 
                          controller: _altPhoneController,
                          icon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (v.length != 10) return "Must be 10 digits";
                            return null;
                          },
                        ),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileDropdown(
                          label: "Relationship", 
                          value: _marriageStatusOptions.contains(_relationshipController.text) ? _relationshipController.text : null,
                          items: _marriageStatusOptions,
                          onChanged: (v) => setState(() => _relationshipController.text = v ?? ""),
                        ),
                        ProfileTextField(
                          label: "Aadhar Number", 
                          controller: _aadharController,
                          icon: Icons.credit_card_outlined,
                          enabled: false,
                        ),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(
                          label: "Xth Marks (%)", 
                          controller: _xMarksController,
                          icon: Icons.grade_outlined,
                          enabled: false,
                        ),
                        ProfileTextField(
                          label: "XIIth Marks (%)", 
                          controller: _xiiMarksController,
                          icon: Icons.grade_outlined,
                          enabled: false,
                        ),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(
                          label: "Qualification", 
                          controller: _qualificationController,
                          icon: Icons.school_outlined,
                          enabled: false,
                        ),
                        ProfileTextField(
                          label: "Experience (Years)", 
                          controller: _experienceController,
                          icon: Icons.history_edu_outlined,
                          enabled: false,
                        ),
                      ]),
                    ]
                  ),

                  ProfileSection(
                    title: "Employment Info", 
                    icon: Icons.work_outline_rounded,
                    children: [
                      AdaptiveFieldRow(children: [
                        ProfileTextField(label: "Employee ID", controller: TextEditingController(text: _userDetail?.employeeId ?? ""), enabled: false),
                        ProfileTextField(label: "Joining Date", controller: TextEditingController(text: _userDetail?.joiningDate ?? ""), enabled: false),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(label: "Position", controller: TextEditingController(text: _userDetail?.position ?? ""), enabled: false),
                        ProfileTextField(label: "Salary", controller: _salaryController, enabled: false, icon: Icons.currency_rupee),
                      ]),
                    ]
                  ),

                  ProfileSection(
                    title: "Address Details", 
                    icon: Icons.location_on_outlined,
                    children: [
                      ProfileTextField(
                        label: "Full Address", 
                        controller: _addressController, 
                        icon: Icons.home_outlined,
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(
                          label: "City", 
                          controller: _cityController,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                        ProfileTextField(
                          label: "State", 
                          controller: _stateController,
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ]),
                      ProfileTextField(
                        label: "Pincode", 
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Required";
                          if (v.length != 6) return "Must be 6 digits";
                          return null;
                        },
                      ),
                    ]
                  ),

                  ProfileSection(
                    title: "Emergency Contact", 
                    icon: Icons.contact_phone_outlined,
                    children: [
                      AdaptiveFieldRow(children: [
                        ProfileTextField(
                          label: "Contact Name", 
                          controller: _emergencyContactNameController,
                          icon: Icons.person_outline,
                        ),
                        ProfileTextField(
                          label: "Contact Number", 
                          controller: _emergencyContactNumberController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v != null && v.isNotEmpty && v.length != 10) ? "Must be 10 digits" : null,
                        ),
                      ]),
                    ]
                  ),

                  ProfileSection(
                    title: "Banking Info (View Only)", 
                    icon: Icons.account_balance_outlined,
                    children: [
                      AdaptiveFieldRow(children: [
                        ProfileTextField(label: "Account Number", controller: _bankAccController, enabled: false),
                        ProfileTextField(label: "Bank Name", controller: _bankNameController, enabled: false),
                      ]),
                      AdaptiveFieldRow(children: [
                        ProfileTextField(label: "IFSC Code", controller: _ifscController, enabled: false),
                        ProfileTextField(label: "Branch Name", controller: _branchNameController, enabled: false),
                      ]),
                    ]
                  ),

                  ProfileSection(
                    title: "Security", 
                    icon: Icons.lock_reset_rounded,
                    children: [
                      AdaptiveFieldRow(children: [
                        ProfileTextField(label: "New Password", controller: _passwordController, isPassword: true, icon: Icons.password_rounded),
                        ProfileTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_outline_rounded),
                      ]),
                    ]
                  ),

                  SizedBox(height: context.spacing * 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.spacing),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                      child: _isLoading 
                          ? SizedBox(
                              width: context.scale(20),
                              height: context.scale(20),
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ) 
                          : Text("UPDATE PROFILE", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: context.spacing),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("LOGOUT", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

      if (confirm == true) {
        await ApiService.logout();
        if (mounted) {
          final navigator = Navigator.of(context);
          navigator.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    },
                      icon: Icon(Icons.logout, color: theme.colorScheme.error, size: context.scale(20)),
                      label: Text("LOGOUT", style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: context.font(14))),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: EdgeInsets.symmetric(vertical: context.spacing),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacing * 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: context.isMobile
          ? Column(
        children: [
          _buildAvatar(context),
          SizedBox(height: context.spacing),
          ..._buildHeaderInfo(context, theme),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(context),
          SizedBox(width: context.spacing * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildHeaderInfo(context, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return ProfileAvatar(
      imageUrl: _userDetail?.photo != null && _userDetail!.photo!.isNotEmpty
          ? ApiService.getStorageUrl(_userDetail!.photo)
          : null,
      radius: context.scale(60),
      localImage: _imageFile,
      webImage: _webImage,
      onCameraTap: _pickImage,
    );
  }

  List<Widget> _buildHeaderInfo(BuildContext context, ThemeData theme) {
    return [
      Text(
        _userDetail?.fullName ?? "Unknown User",
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
      ),
      Text(
        _userDetail?.position ?? "Counselor",
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
      ),
    ];
  }
}
