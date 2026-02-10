import 'package:eduphin/login_logout/login.dart';
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
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    final currentData = await _profileDataFuture;

    // Create a new ProfileData instance with updated values
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
      aadharNumber: currentData.aadharNumber,
      aadharPhoto: currentData.aadharPhoto,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      phone: _phoneController.text,
      xMarks: currentData.xMarks,
      xMarksheetPhoto: currentData.xMarksheetPhoto,
      xiiMarks: currentData.xiiMarks,
      xiiMarksheetPhoto: currentData.xiiMarksheetPhoto,
      qualification: currentData.qualification,
      resume: currentData.resume,
      alternatePhone: _altPhoneController.text,
      relationshipStatus: _relationshipStatusValue ?? currentData.relationshipStatus,
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


    try {
      await _profileProvider.saveProfileData(updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Changes saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save changes: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _profileProvider.logout();

      if (!mounted) return;
      // Navigate to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, // This predicate removes all routes
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have been logged out."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
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
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) {
        return baseFontSize * 1.2;
      } else if (screenWidth > 600) {
        return baseFontSize * 1.1;
      }
      return baseFontSize;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Profile",
                style: TextStyle(
                    color: Colors.white, fontSize: responsiveFontSize(20))),
            const Icon(Icons.download, color: Colors.white),
          ],
        ),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      backgroundColor: const Color(0xFF0D1B2A),
      body: FutureBuilder<ProfileData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            // Construct the full image URL
            final imageUrl = data.photo.startsWith('http')
                ? data.photo
                : '${ApiService.baseUrl.replaceAll("/api", "")}/storage/${data.photo}';


            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.12,
                      backgroundImage: NetworkImage(imageUrl),
                      onBackgroundImageError: (exception, stackTrace) {
                        // You can handle image loading errors here, maybe show a default avatar
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsiveFontSize(20),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(data.position,
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: responsiveFontSize(14))),
                    Text(data.email,
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: responsiveFontSize(14))),
                    const SizedBox(height: 25),
                    SectionCard(
                      title: "Personal Information",
                      icon: Icons.person,
                      children: [
                        _buildResponsiveGrid(
                          [
                            CustomDropdown(
                              label: "Gender",
                              value: _genderValue,
                              items: const ["Male", "Female", "Other"],
                              onChanged: (newValue) {
                                setState(() {
                                  _genderValue = newValue;
                                });
                              },
                            ),
                            CustomTextField(
                                label: "Date of Birth",
                                controller: TextEditingController(
                                    text: data.dateOfBirth),
                                icon: Icons.calendar_month,
                                editable: false),
                            CustomTextField(
                                label: "Phone", controller: _phoneController),
                            CustomTextField(
                                label: "Alternate Phone",
                                controller: _altPhoneController),
                            CustomDropdown(
                              label: "Marriage Status",
                              value: _relationshipStatusValue,
                              items: const [
                                "Single",
                                "Married",
                                "Divorced",
                                "Widowed"
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  _relationshipStatusValue = newValue;
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: "Address Information",
                      icon: Icons.location_on,
                      children: [
                        _buildResponsiveGrid([
                          CustomTextField(
                              label: "Address",
                              controller: _addressController),
                          CustomTextField(
                              label: "City", controller: _cityController),
                          CustomTextField(
                              label: "State", controller: _stateController),
                          CustomTextField(
                              label: "Pincode", controller: _pincodeController),
                        ])
                      ],
                    ),
                    const SizedBox(height: 20),
                     SectionCard(
                      title: "Banking Information",
                      icon: Icons.account_balance,
                      children: [
                        CustomTextField(label: "Bank Account Number", controller: TextEditingController(text: data.bankAccountNumber ?? 'N/A'), editable: false),
                        CustomTextField(label: "IFSC Code", controller: TextEditingController(text: data.ifscCode ?? 'N/A'), editable: false),
                        CustomTextField(label: "Bank Name", controller: TextEditingController(text: data.bankName ?? 'N/A'), editable: false),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24),
                        CustomTextField(label: "Branch Name", controller: TextEditingController(text: data.branchName ?? 'N/A'), editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: "Emergency Contact",
                      icon: Icons.phone_in_talk,
                      children: [
                        CustomTextField(
                            label: "Contact Name",
                            controller: TextEditingController(
                                text: data.emergencyContactName ?? 'N/A'),
                            editable: false),
                        CustomTextField(
                            label: "Contact Number",
                            controller: TextEditingController(
                                text: data.emergencyContactNumber ?? 'N/A'),
                            editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: "Security Settings",
                      icon: Icons.lock,
                      children: [
                        _buildResponsiveGrid([
                          CustomTextField(
                              label: "New Password",
                              controller: _newPasswordController,
                              isPassword: true),
                          CustomTextField(
                              label: "Confirm Password",
                              controller: _confirmPasswordController,
                              isPassword: true),
                        ])
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: "Account Details",
                      icon: Icons.person_pin,
                      children: [
                        CustomTextField(
                            label: "User Name",
                            controller:
                                TextEditingController(text: data.name),
                            editable: false),
                        CustomTextField(
                            label: "Email Address",
                            controller:
                                TextEditingController(text: data.email),
                            editable: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: "Employment Details",
                      icon: Icons.badge,
                      children: [
                        CustomTextField(
                            label: "Position",
                            controller:
                                TextEditingController(text: data.position),
                            editable: false),
                        CustomTextField(
                            label: "Employment Type",
                            controller: TextEditingController(
                                text: data.employmentType),
                            editable: false),
                        CustomTextField(
                            label: "Joining Date",
                            controller: TextEditingController(
                                text: data.joiningDate ?? 'N/A'),
                            editable: false),
                        CustomTextField(
                            label: "Experience",
                            controller: TextEditingController(
                                text: '${data.experience ?? 0} years'),
                            editable: false),
                        CustomTextField(
                            label: "Status",
                            controller:
                                TextEditingController(text: data.status),
                            editable: false),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E86D4),
                        minimumSize:
                            Size(double.infinity, screenWidth * 0.12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSaving || _isLoggingOut
                          ? null
                          : _saveChanges,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("SAVE CHANGES",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveFontSize(16))),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        minimumSize:
                            Size(double.infinity, screenWidth * 0.12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed:
                          _isSaving || _isLoggingOut ? null : _logout,
                      child: _isLoggingOut
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("Log Out",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveFontSize(16))),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
                child: Text('No profile data found.',
                    style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 0,
              childAspectRatio: 3.5,
            ),
            itemBuilder: (context, index) {
              return children[index];
            },
          );
        } else {
          return Column(
            children: children,
          );
        }
      },
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.children});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) return baseFontSize * 1.2;
      if (screenWidth > 600) return baseFontSize * 1.1;
      return baseFontSize;
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
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
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(18),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) return baseFontSize * 1.2;
      if (screenWidth > 600) return baseFontSize * 1.1;
      return baseFontSize;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white54, fontSize: responsiveFontSize(13))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: editable ? const Color(0xFF0D1B2A) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            enabled: editable,
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(
                color: Colors.white, fontSize: responsiveFontSize(14)),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon:
                  icon != null ? Icon(icon, color: Colors.white54) : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 1200) return baseFontSize * 1.2;
      if (screenWidth > 600) return baseFontSize * 1.1;
      return baseFontSize;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white54, fontSize: responsiveFontSize(13))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: TextStyle(fontSize: responsiveFontSize(14))),
                );
              }).toList(),
              dropdownColor: const Color(0xFF1B263B),
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
