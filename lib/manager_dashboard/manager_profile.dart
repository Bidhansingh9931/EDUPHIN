import 'dart:convert';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
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
    String rawImageUrl = json['photo']?.toString() ?? '';
    return ManagerProfile(
      name: json['name']?.toString() ?? 'N/A',
      role: json['role']?['name']?.toString() ?? 'Manager',
      email: json['email']?.toString() ?? 'N/A',
      avatar: rawImageUrl.isNotEmpty ? '${ApiService.baseImageUrl}/storage/$rawImageUrl' : '',
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

class ProfileApiService {
  Future<ManagerProfile> fetchProfileData() async {
    final response = await ApiService.get('manager/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return ManagerProfile.fromJson(data['data']);
      } else {
        throw Exception('API returned an error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load profile data. Status: ${response.statusCode}');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final response = await ApiService.post('manager/profile/update', data);
    if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to update profile: ${responseBody['message'] ?? 'Unknown error'}');
    }
  }
}

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  late Future<ManagerProfile> _profileDataFuture;
  final _apiService = ProfileApiService();
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

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchAndInitializeProfileData();
  }

  Future<ManagerProfile> _fetchAndInitializeProfileData() async {
    final data = await _apiService.fetchProfileData();

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
      "gender": _genderValue,
      "relationship_status": _marriageStatusValue,
      "date_of_birth": _dobController.text,
      "address": _address1Controller.text,
      "city": _cityController.text,
      "state": _districtController.text,
      "pincode": _pincodeController.text,
      if (_newPasswordController.text.isNotEmpty) "password": _newPasswordController.text,
    };

    try {
      await _apiService.updateProfile(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved successfully!")),
        );
        setState(() {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 8),
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
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _profileDataFuture = _fetchAndInitializeProfileData();
                    }),
                    child: const Text("Retry"),
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
                        const SizedBox(height: 32),
                        
                        _buildSection(
                          context, 
                          title: "Personal Information", 
                          icon: Icons.person_outline_rounded,
                          children: [
                            _buildResponsiveRow(context, [
                              CustomDropdown(
                                label: "Gender",
                                value: _genderValue,
                                items: _genderOptions,
                                onChanged: (v) => setState(() => _genderValue = v),
                                validator: (value) => value == null ? 'Required' : null,
                              ),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: CustomTextField(
                                    label: "Date of Birth",
                                    controller: _dobController,
                                    icon: Icons.calendar_today_rounded,
                                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ),
                            ]),
                            _buildResponsiveRow(context, [
                              CustomTextField(
                                label: "Phone",
                                controller: _phoneController,
                                icon: Icons.phone_android_rounded,
                                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                              ),
                              CustomTextField(
                                label: "Alternate Phone",
                                controller: _altPhoneController,
                                icon: Icons.phone_callback_rounded,
                              ),
                            ]),
                            CustomDropdown(
                              label: "Marriage Status", 
                              value: _marriageStatusValue, 
                              items: _marriageStatusOptions, 
                              onChanged: (v) => setState(() => _marriageStatusValue = v)
                            ),
                          ]
                        ),

                        _buildSection(
                          context, 
                          title: 'Address Details', 
                          icon: Icons.location_on_outlined, 
                          children: [
                            CustomTextField(label: "Full Address", controller: _address1Controller, icon: Icons.home_outlined),
                            _buildResponsiveRow(context, [
                              CustomTextField(label: "City", controller: _cityController),
                              CustomTextField(label: "State/District", controller: _districtController),
                            ]),
                            CustomTextField(label: "Pincode", controller: _pincodeController),
                          ]
                        ),

                        _buildSection(
                          context, 
                          title: 'Employment Information', 
                          icon: Icons.work_outline_rounded, 
                          children: [
                            _buildResponsiveRow(context, [
                              CustomTextField(label: "Position", controller: _positionController, enabled: false),
                              CustomTextField(label: "Employment Type", controller: _employmentTypeController, enabled: false),
                            ]),
                            _buildResponsiveRow(context, [
                              CustomTextField(label: "Joining Date", controller: _joiningDateController, enabled: false),
                              CustomTextField(label: "Experience", controller: _experienceController, enabled: false),
                            ]),
                            CustomTextField(label: "Current Status", controller: _statusController, enabled: false),
                          ]
                        ),

                        _buildSection(
                          context, 
                          title: 'Bank Details (View Only)', 
                          icon: Icons.account_balance_outlined, 
                          children: [
                            _buildResponsiveRow(context, [
                              CustomTextField(label: "Account Number", controller: _bankAccountController, enabled: false),
                              CustomTextField(label: "IFSC Code", controller: _ifscController, enabled: false),
                            ]),
                            CustomTextField(label: "Bank Name", controller: _bankNameController, enabled: false),
                          ]
                        ),

                        _buildSection(
                          context, 
                          title: 'Update Security', 
                          icon: Icons.lock_reset_rounded, 
                          children: [
                            _buildResponsiveRow(context, [
                              CustomTextField(label: "New Password", controller: _newPasswordController, obscureText: true, icon: Icons.password_rounded),
                              CustomTextField(label: "Confirm New Password", controller: _confirmPasswordController, obscureText: true, icon: Icons.lock_outline_rounded),
                            ]),
                          ]
                        ),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _saveChanges(data),
                            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
                            label: Text(_isSaving ? "Saving..." : "Save Changes"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 4),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.surface,
                  backgroundImage: data.avatar.isNotEmpty ? NetworkImage(data.avatar) : null,
                  child: data.avatar.isEmpty ? Icon(Icons.person_rounded, size: 60, color: colorScheme.primary) : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(data.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(data.role.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 12),
          Text(data.email, style: TextStyle(color: theme.hintColor)),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList(),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  final IconData? icon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: !enabled,
          fillColor: !enabled ? Theme.of(context).disabledColor.withOpacity(0.05) : null,
        ),
        validator: validator,
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
