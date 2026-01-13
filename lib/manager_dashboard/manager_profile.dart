import 'dart:async';

import 'package:eduphin/login_logout/login.dart';
import 'package:flutter/material.dart';

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

  factory ManagerProfile.fromMap(Map<String, dynamic> map) {
    return ManagerProfile(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      phone: map['phone'] ?? '',
      altPhone: map['alt_phone'] ?? '',
      marriageStatus: map['marriage_status'] ?? '',
      address1: map['address1'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      pincode: map['pincode'] ?? '',
      bankAccount: map['bank_account'] ?? '',
      ifsc: map['ifsc'] ?? '',
      bankName: map['bank_name'] ?? '',
      employerBranch: map['employer_branch'] ?? '',
      zone: map['zone'] ?? '',
      emergencyContactName: map['emergency_contact_name'] ?? '',
      emergencyContactNumber: map['emergency_contact_number'] ?? '',
      userName: map['user_name'] ?? '',
      position: map['position'] ?? '',
      employmentType: map['employment_type'] ?? '',
      joiningDate: map['joining_date'] ?? '',
      experience: map['experience'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockProfileApiService {
  Future<ManagerProfile> fetchProfileData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this data would come from an API
    final data = {
      "name": "Rajeev K.Malhotra",
      "role": "General Manager",
      "email": "raj@iias",
      "avatar": "assets/images/girl_image.webp",
      "gender": "Female",
      "dob": "22-04-2004",
      "phone": "9812345678",
      "alt_phone": "8877665544",
      "marriage_status": "Single",
      "address1": "Flat 101, Amber Crest",
      "city": "Jaipur",
      "district": "Rajapark",
      "pincode": "302004",
      "bank_account": "111122223333",
      "ifsc": "UN11100010",
      "bank_name": "Unity Bank",
      "employer_branch": "Unity Branch - Sector 2",
      "zone": "Sector 2",
      "emergency_contact_name": "Shaurya Verma",
      "emergency_contact_number": "9090909090",
      "user_name": "Priya Verma",
      "position": "Assistant",
      "employment_type": "Full-time",
      "joining_date": "20 Jan 2023",
      "experience": "1.5 years",
      "status": "Active",
    };
    return ManagerProfile.fromMap(data);
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
  final _apiService = MockProfileApiService();

  // Text editing controllers for editable fields
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _dobController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State for dropdowns
  String? _genderValue;
  String? _marriageStatusValue;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchAndInitializeProfileData();
  }

  Future<ManagerProfile> _fetchAndInitializeProfileData() async {
    final data = await _apiService.fetchProfileData();

    // Initialize controllers and state variables with fetched data
    _phoneController.text = data.phone;
    _altPhoneController.text = data.altPhone;
    _address1Controller.text = data.address1;
    _cityController.text = data.city;
    _districtController.text = data.district;
    _pincodeController.text = data.pincode;
    _dobController.text = data.dob;
    _genderValue = data.gender;
    _marriageStatusValue = data.marriageStatus;

    return data;
  }

  void _saveChanges() {
    // In a real app, you would send the updated data to an API
    final updatedData = {
      "phone": _phoneController.text,
      "alt_phone": _altPhoneController.text,
      "gender": _genderValue,
      "marriage_status": _marriageStatusValue,
      "dob": _dobController.text,
      "address1": _address1Controller.text,
      "city": _cityController.text,
      "district": _districtController.text,
      "pincode": _pincodeController.text,
      "new_password": _newPasswordController.text,
    };
    debugPrint("Saving data: $updatedData");
    // For demonstration, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Changes saved successfully! (Simulated)"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _phoneController.dispose();
    _altPhoneController.dispose();
    _address1Controller.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _dobController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Manager Profile", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20)),
            Icon(Icons.download, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
      floatingActionButton: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: SizedBox(
                width: 200,
                height: 50,
                child: FloatingActionButton(
                  onPressed: _saveChanges,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 2),
                      Text("SAVE CHANGES", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20)),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
                width: 150,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: Text("Log Out", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20)),
                )),
          ),
        ],
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

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  children: [
                    // -------- PROFILE HEADER --------
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(data.avatar),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(data.role, style: const TextStyle(color: Colors.white54)),
                    Text(data.email, style: const TextStyle(color: Colors.white54)),
                    const SizedBox(height: 25),

                    // -------- PERSONAL INFO --------
                    SectionCard(
                      title: "Personal Information",
                      icon: Icons.person,
                      children: [
                        CustomDropdown(
                          label: "Gender",
                          value: _genderValue,
                          items: const ["Male", "Female", "Others"],
                          onChanged: (newValue) {
                            setState(() {
                              _genderValue = newValue;
                            });
                          },
                        ),
                        CustomTextField(label: "Date of Birth", controller: _dobController, icon: Icons.calendar_month, editable: true),
                        CustomTextField(label: "Phone", controller: _phoneController),
                        CustomTextField(label: "Alternate Phone", controller: _altPhoneController),
                        CustomDropdown(
                          label: "Marriage Status",
                          value: _marriageStatusValue,
                          items: const ["Single", "Married", "Divorced", "Widowed"],
                          onChanged: (newValue) {
                            setState(() {
                              _marriageStatusValue = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- ADDRESS INFO --------
                    SectionCard(
                      title: "Address Information",
                      icon: Icons.location_on,
                      children: [
                        CustomTextField(label: "Address Line 1", controller: _address1Controller),
                        CustomTextField(label: "City", controller: _cityController),
                        CustomTextField(label: "District", controller: _districtController),
                        CustomTextField(label: "Pincode", controller: _pincodeController),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- BANKING INFO --------
                    SectionCard(
                      title: "Banking Information",
                      icon: Icons.account_balance,
                      children: [
                        CustomTextField(label: "Bank Account Number", controller: TextEditingController(text: data.bankAccount), editable: false),
                        CustomTextField(label: "IFSC Code", controller: TextEditingController(text: data.ifsc), editable: false),
                        CustomTextField(label: "Bank Name", controller: TextEditingController(text: data.bankName), editable: false),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24),
                        CustomTextField(label: "Employer Branch", controller: TextEditingController(text: data.employerBranch), editable: false),
                        CustomTextField(label: "Zone / Sector", controller: TextEditingController(text: data.zone), editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- EMERGENCY CONTACT --------
                    SectionCard(
                      title: "Emergency Contact",
                      icon: Icons.phone_in_talk,
                      children: [
                        CustomTextField(label: "Contact Name", controller: TextEditingController(text: data.emergencyContactName), editable: false),
                        CustomTextField(label: "Contact Number", controller: TextEditingController(text: data.emergencyContactNumber), editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- SECURITY SETTINGS --------
                    SectionCard(
                      title: "Security Settings",
                      icon: Icons.lock,
                      children: [
                        CustomTextField(label: "New Password", controller: _newPasswordController, isPassword: true),
                        CustomTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- ACCOUNT DETAILS --------
                    SectionCard(
                      title: "Account Details",
                      icon: Icons.person_pin,
                      children: [
                        CustomTextField(label: "User Name", controller: TextEditingController(text: data.userName), editable: false),
                        CustomTextField(label: "Email Address", controller: TextEditingController(text: data.email), editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // -------- EMPLOYMENT DETAILS --------
                    SectionCard(
                      title: "Employment Details",
                      icon: Icons.badge,
                      children: [
                        CustomTextField(label: "Position", controller: TextEditingController(text: data.position), editable: false),
                        CustomTextField(label: "Employment Type", controller: TextEditingController(text: data.employmentType), editable: false),
                        CustomTextField(label: "Joining Date", controller: TextEditingController(text: data.joiningDate), editable: false),
                        CustomTextField(label: "Experience", controller: TextEditingController(text: data.experience), editable: false),
                        CustomTextField(label: "Status", controller: TextEditingController(text: data.status), editable: false),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No profile data found.', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }
}

//
// ───────────────────────────────────────────────────────────
//                       REUSABLE WIDGETS
// ───────────────────────────────────────────────────────────
//

// -------- SECTION CARD --------
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

// -------- TEXT FIELD --------
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editable;
  final IconData? icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.editable = true,
    this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: editable ? const Color(0xFF0D1B2A) : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              enabled: editable,
              obscureText: isPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: icon != null ? Icon(icon, color: Colors.white54, size: 20) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------- DROPDOWN --------
class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1B263B),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
