import 'dart:async';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'new_employee_model.dart';

class AddEmployeePage extends StatefulWidget {
  final String instituteId;
  const AddEmployeePage({super.key, required this.instituteId});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  bool _isLoading = false;

  // Controllers for text fields
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();
  final positionController = TextEditingController();
  final experienceController = TextEditingController();
  final statusController = TextEditingController();
  final referenceController = TextEditingController();
  final qualificationController = TextEditingController();
  final matriculationController = TextEditingController();
  final intermediateController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactNumberController = TextEditingController();

  // Dropdown and Date values
  String? selectedRole;
  String? selectedGender;
  DateTime? selectedBirthDate;
  String? selectedRelationshipStatus;
  String? selectedEmploymentType;
  DateTime? selectedJoiningDate;
  File? _profileImage;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    alternatePhoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinController.dispose();
    positionController.dispose();
    experienceController.dispose();
    statusController.dispose();
    referenceController.dispose();
    qualificationController.dispose();
    matriculationController.dispose();
    intermediateController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    branchController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _submitEmployeeData() async {
    if (fullNameController.text.isEmpty || emailController.text.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields (Full Name, Email, Role).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newEmployee = NewEmployee(
      instituteId: widget.instituteId,
      fullName: fullNameController.text,
      email: emailController.text,
      role: selectedRole,
      gender: selectedGender,
      dateOfBirth: selectedBirthDate,
      relationshipStatus: selectedRelationshipStatus,
      phoneNumber: phoneController.text,
      alternateNumber: alternatePhoneController.text,
      address: addressController.text,
      city: cityController.text,
      state: stateController.text,
      pinCode: pinController.text,
      position: positionController.text,
      employmentType: selectedEmploymentType,
      joiningDate: selectedJoiningDate,
      experience: experienceController.text,
      status: statusController.text,
      reference: referenceController.text,
      qualification: qualificationController.text,
      matriculationMarks: matriculationController.text,
      intermediateMarks: intermediateController.text,
      bankAccountNumber: accountNumberController.text,
      ifscCode: ifscCodeController.text,
      bankName: bankNameController.text,
      branch: branchController.text,
      emergencyContactName: emergencyContactNameController.text,
      emergencyContactNumber: emergencyContactNumberController.text,
      profileImage: _profileImage,
    );

    try {
      await ApiService.addEmployee(newEmployee);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add employee: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Add Employee',
          style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
        child: Column(
          children: [
            _buildProfileImage(context),
            const SizedBox(height: 24),
            _buildSection(
              context: context,
              title: "Personal Details",
              children: [
                _buildTextField(context: context, controller: fullNameController, label: "Full Name", icon: Icons.person_outline_sharp),
                _buildTextField(context: context, controller: emailController, label: "Email", icon: Icons.email_outlined),
                _buildDropdown(context: context, title: "Select Role", value: selectedRole, hint: "Assign a Role", items: ["Institute Manager", "Teacher", "Student", "Staff", "Accountant"], onChanged: (value) => setState(() => selectedRole = value)),
                _buildDropdown(context: context, title: "Select Gender", value: selectedGender, hint: "Select Gender", items: ["Male", "Female", "Other"], onChanged: (value) => setState(() => selectedGender = value ?? "Male")),
                _buildDatePickerField(context: context, hint: 'Select birth date', title: "Date of Birth", currentValue: selectedBirthDate, onConfirm: (date) => setState(() => selectedBirthDate = date)),
                _buildDropdown(context: context, title: "Relationship Status", value: selectedRelationshipStatus, hint: "Select Relationship Status", items: ["Single", "Married", "Couple"], onChanged: (value) => setState(() => selectedRelationshipStatus = value)),
              ],
            ),
            _buildSection(
              context: context,
              title: "Contact Details",
              children: [
                _buildTextField(context: context, controller: phoneController, label: "Phone Number", icon: Icons.phone_android, isNumeric: true),
                _buildTextField(context: context, controller: alternatePhoneController, label: "Alternate Number", icon: Icons.phone, isNumeric: true),
              ],
            ),
            _buildSection(
              context: context,
              title: "Address Details",
              children: [
                _buildTextField(context: context, controller: addressController, label: "Address", icon: Icons.location_on_outlined),
                _buildTextField(context: context, controller: cityController, label: "City", icon: Icons.location_city),
                _buildTextField(context: context, controller: stateController, label: "State", icon: Icons.location_history),
                _buildTextField(context: context, controller: pinController, label: "Pin code", icon: Icons.pin, isNumeric: true),
              ],
            ),
            _buildSection(
              context: context,
              title: "Professional Information",
              children: [
                _buildTextField(context: context, controller: positionController, label: "Position", icon: Icons.school_outlined),
                _buildDropdown(context: context, title: "Employment Type", value: selectedEmploymentType, hint: "Select Employment Type", items: ["Full-Time", "Part-Time", "Contractual", "Freelance"], onChanged: (value) => setState(() => selectedEmploymentType = value)),
                _buildDatePickerField(context: context, hint: 'Select joining date', title: "Joining Date", currentValue: selectedJoiningDate, onConfirm: (date) => setState(() => selectedJoiningDate = date)),
                _buildTextField(context: context, controller: experienceController, label: "Experience (Years)", icon: Icons.work_history_outlined, isNumeric: true),
                _buildTextField(context: context, controller: statusController, label: "Status", icon: Icons.check_circle_outline),
                _buildTextField(context: context, controller: referenceController, label: "Reference", icon: Icons.group_outlined),
              ],
            ),
            _buildSection(
              context: context,
              title: "Education Details",
              children: [
                _buildTextField(context: context, controller: qualificationController, label: "Qualification", icon: Icons.book_outlined),
                _buildTextField(context: context, controller: matriculationController, label: "Matriculation Marks (%)", icon: Icons.percent_outlined, isNumeric: true),
                _buildTextField(context: context, controller: intermediateController, label: "Intermediate Marks (%)", icon: Icons.percent_outlined, isNumeric: true),
              ],
            ),
            _buildSection(
              context: context,
              title: "Banking Details",
              children: [
                _buildTextField(context: context, controller: accountNumberController, label: "Bank Account Number", icon: Icons.account_balance_wallet_outlined, isNumeric: true),
                _buildTextField(context: context, controller: ifscCodeController, label: "IFSC Code", icon: Icons.qr_code_outlined),
                _buildTextField(context: context, controller: bankNameController, label: "Bank Name", icon: Icons.account_balance_outlined),
                _buildTextField(context: context, controller: branchController, label: "Branch", icon: Icons.location_on_outlined),
              ],
            ),
            _buildSection(
              context: context,
              title: "Emergency Contact",
              children: [
                _buildTextField(context: context, controller: emergencyContactNameController, label: "Contact Name", icon: Icons.person_outline),
                _buildTextField(context: context, controller: emergencyContactNumberController, label: "Contact Number", icon: Icons.phone_outlined, isNumeric: true),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEmployeeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E86D4),
                  disabledBackgroundColor: const Color(0xFF0E86D4).withAlpha(30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text('Add Employee', style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(16), fontWeight: FontWeight.bold)),
              ),            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.15,
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : const AssetImage("assets/images/girl_image.webp") as ImageProvider,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E86D4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> children}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18), fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 4,
                ),
                itemBuilder: (context, index) => children[index],
              );
            } else {
              return Column(
                children: children.map((widget) => Padding(padding: const EdgeInsets.only(bottom: 12), child: widget)).toList(),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({required BuildContext context, required TextEditingController controller, required String label, required IconData icon, bool isNumeric = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(13))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF0D1B2A),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0E86D4), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required BuildContext context, required String title, required String? value, String? hint, required List<String> items, required void Function(String?) onChanged}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(13))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint ?? '', style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14))),
              isExpanded: true,
              dropdownColor: const Color(0xFF1B263B),
              style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({required BuildContext context, required String title, required String hint, DateTime? currentValue, required Function(DateTime) onConfirm}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(13))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            picker.DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(1950, 1, 1),
                maxTime: DateTime.now(),
                onConfirm: onConfirm, 
                currentTime: currentValue ?? DateTime.now());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.white54),
                const SizedBox(width: 12),
                Text(
                  currentValue != null ? DateFormat.yMMMd().format(currentValue) : hint,
                  style: TextStyle(
                    color: currentValue != null ? Colors.white : Colors.white54,
                    fontSize: responsiveFontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
