import 'dart:convert';

import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/api_service.dart';
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
  final String district; // Note: API might call this 'state'
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
      // Construct the full image URL from the base URL and the path from the API.
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


// ───────────────────────────────────────────────────────────
//                         API SERVICE
// ───────────────────────────────────────────────────────────

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

// ───────────────────────────────────────────────────────────
//                         PROFILE PAGE
// ───────────────────────────────────────────────────────────

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
    } else {
      _genderValue = null;
    }

    if (_marriageStatusOptions.contains(data.marriageStatus)) {
      _marriageStatusValue = data.marriageStatus;
    } else {
      _marriageStatusValue = null;
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
      if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red),
      );
      }
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
        );
      }
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
       // Include non-editable but required fields
      "bank_account_number": _bankAccountController.text,
    };

    try {
      await _apiService.updateProfile(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Changes saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _profileDataFuture = _fetchAndInitializeProfileData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
        if (screenWidth > 1200) return baseSize * 1.2;
        if (screenWidth > 600) return baseSize * 1.1;
        return baseSize;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Manager Profile", style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18))),
            const Icon(Icons.download, color: Colors.white),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0D1B2A),
      body: FutureBuilder<ManagerProfile>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ProfileAvatar(
                      avatarUrl: data.avatar,
                      radius: screenWidth * 0.12,
                    ),
                    const SizedBox(height: 12),
                    Text(data.name, style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(22), fontWeight: FontWeight.bold)),
                    Text(data.role, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14))),
                    Text(data.email, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14))),
                    const SizedBox(height: 25),
                    SectionCard(title: "Personal Information", icon: Icons.person, children: [
                      CustomDropdown(
                        label: "Gender",
                        value: _genderValue,
                        items: _genderOptions,
                        onChanged: (v) => setState(() => _genderValue = v),
                        validator: (value) => value == null ? 'Gender is required' : null,
                      ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            label: "Date of Birth",
                            controller: _dobController,
                            icon: Icons.calendar_month,
                            validator: (value) => value == null || value.isEmpty ? 'Date of Birth is required' : null,
                          ),
                        ),
                      ),
                      CustomTextField(
                        label: "Phone",
                        controller: _phoneController,
                        validator: (value) => value == null || value.isEmpty ? 'Phone is required' : null,
                      ),
                      CustomTextField(
                        label: "Alternate Phone",
                        controller: _altPhoneController,
                        validator: (value) => value == null || value.isEmpty ? 'Alternate phone is required' : null,
                      ),
                      CustomDropdown(label: "Marriage Status", value: _marriageStatusValue, items: _marriageStatusOptions, onChanged: (v) => setState(() => _marriageStatusValue = v)),
                    ]),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Address Details',
                      icon: Icons.location_city,
                      children: [
                        CustomTextField(label: "Address", controller: _address1Controller),
                        CustomTextField(label: "City", controller: _cityController),
                        CustomTextField(label: "District", controller: _districtController),
                        CustomTextField(label: "Pincode", controller: _pincodeController),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Bank Details',
                      icon: Icons.account_balance,
                      children: [
                        CustomTextField(label: "Bank Account No.", controller: _bankAccountController, enabled: false),
                        CustomTextField(label: "IFSC Code", controller: _ifscController, enabled: false),
                        CustomTextField(label: "Bank Name", controller: _bankNameController, enabled: false),
                        CustomTextField(label: "Employer Branch", controller: _employerBranchController, enabled: false),
                      ],
                    ),
                     const SizedBox(height: 16),
                    SectionCard(
                      title: 'Emergency Contact',
                      icon: Icons.contact_emergency,
                      children: [
                        CustomTextField(label: "Contact Person", controller: _emergencyContactNameController),
                        CustomTextField(label: "Contact Number", controller: _emergencyContactNumberController),
                      ],
                    ),
                     const SizedBox(height: 16),
                    SectionCard(
                      title: 'Employment Details',
                      icon: Icons.work,
                      children: [
                        CustomTextField(label: "User Name", controller: _userNameController, enabled: false),
                        CustomTextField(label: "Position", controller: _positionController, enabled: false),
                        CustomTextField(label: "Employment Type", controller: _employmentTypeController, enabled: false),
                        CustomTextField(label: "Joining Date", controller: _joiningDateController, enabled: false),
                        CustomTextField(label: "Experience", controller: _experienceController, enabled: false),
                        CustomTextField(label: "Status", controller: _statusController, enabled: false),
                      ],
                    ),
                     const SizedBox(height: 16),
                    SectionCard(
                      title: 'Security',
                      icon: Icons.security,
                      children: [
                        CustomTextField(label: "New Password", controller: _newPasswordController, obscureText: true),
                        CustomTextField(label: "Confirm Password", controller: _confirmPasswordController, obscureText: true),
                      ],
                    ),
                    const SizedBox(height: 30),
                     _isSaving
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _saveChanges(data),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: 15),
                              textStyle: TextStyle(fontSize: responsiveFontSize(16)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                     const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No profile data available.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         CUSTOM WIDGETS
// ───────────────────────────────────────────────────────────

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // Print the URL for debugging purposes.
    // Check your console output to see what URL is being used.
    print('Attempting to load avatar from URL: $avatarUrl');

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF1B2A41),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Log error for easier debugging
                  print('Failed to load profile image: $error'); 
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/man_image.png', // Your placeholder asset
      fit: BoxFit.cover,
      width: radius * 2,
      height: radius * 2,
    );
  }
}


class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1B2A41),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Divider(color: Colors.white24, thickness: 1, height: 20),
            ...children,
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        style: TextStyle(color: enabled ? Colors.white : Colors.grey[400]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: enabled ? const Color(0xFF0D1B2A) : Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF0D1B2A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF1B2A41),
        validator: validator,
      ),
    );
  }
}
