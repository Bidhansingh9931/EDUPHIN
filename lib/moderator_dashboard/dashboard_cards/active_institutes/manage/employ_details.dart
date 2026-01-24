import 'dart:async';
import 'package:flutter/material.dart';

import '../../../moderator_dashboard.dart';

// 1. Data Model for detailed employee information
class EmployeeDetails {
  final String id;
  String fullName;
  String email;
  String role;
  String gender;
  String dateOfBirth;
  String relationshipStatus;
  String phoneNumber;
  String alternateNumber;
  String address;
  String city;
  String state;
  String pinCode;
  String position;
  String employmentType;
  final String joiningDate;
  String experience;
  String status;
  String reference;
  String qualification;
  String matriculationMarks;
  String intermediateMarks;
  String bankAccountNumber;
  String ifscCode;
  String bankName;
  String branch;
  String emergencyContactName;
  String emergencyContactNumber;

  EmployeeDetails({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.relationshipStatus,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.position,
    required this.employmentType,
    required this.joiningDate,
    required this.experience,
    required this.status,
    required this.reference,
    required this.qualification,
    required this.matriculationMarks,
    required this.intermediateMarks,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });
}

// 2. Data Provider to fetch and save employee details
class EmployeeDetailsProvider {
  // In the future, replace this with a real API call to fetch data
  Future<EmployeeDetails> fetchEmployeeDetails(String employeeId) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // This is where you would fetch your data from an API based on the employeeId.
    // For now, we are returning mock data.
    return EmployeeDetails(
      id: employeeId,
      fullName: "Dr. Evelyn Reed",
      email: "evelyn.reed@example.com",
      role: "Teacher",
      gender: "Female",
      dateOfBirth: "15-08-1985",
      relationshipStatus: "Single",
      phoneNumber: "+91 1234567890",
      alternateNumber: "+91 0987654321",
      address: "123, Tech Park Road",
      city: "Bengaluru",
      state: "Karnataka",
      pinCode: "560001",
      position: "Senior Teacher",
      employmentType: "Full-Time",
      joiningDate: "01-07-2020",
      experience: "5",
      status: "Active",
      reference: "N/A",
      qualification: "M.Sc. Physics",
      matriculationMarks: "92%",
      intermediateMarks: "88%",
      bankAccountNumber: "123456789012",
      ifscCode: "BANK0001234",
      bankName: "Example Bank",
      branch: "Tech Park Branch",
      emergencyContactName: "John Doe",
      emergencyContactNumber: "+91 0987654321",
    );
  }

  // In the future, replace this with a real API call to save data
  Future<void> saveEmployeeDetails(EmployeeDetails details) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    debugPrint("Saving data for ${details.fullName}...");
    // In a real app, you would make a POST or PUT request here.
  }
}

// 3. Updated page to be dynamic
class EmployeeDetailsPage extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailsPage({super.key, this.employeeId = "emp1"});

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  final EmployeeDetailsProvider _provider = EmployeeDetailsProvider();
  bool _isLoading = true;
  bool _isSaving = false;
  late EmployeeDetails _employeeDetails;

  // Text editing controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _genderController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _positionController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _statusController = TextEditingController();
  final _referenceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _matriculationMarksController = TextEditingController();
  final _intermediateMarksController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _relationshipStatusController.dispose();
    _phoneNumberController.dispose();
    _alternateNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _positionController.dispose();
    _employmentTypeController.dispose();
    _joiningDateController.dispose();
    _experienceController.dispose();
    _statusController.dispose();
    _referenceController.dispose();
    _qualificationController.dispose();
    _matriculationMarksController.dispose();
    _intermediateMarksController.dispose();
    _bankAccountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _provider.fetchEmployeeDetails(widget.employeeId);
      _employeeDetails = data; // Store fetched data

      // Populate controllers with fetched data
      _fullNameController.text = data.fullName;
      _emailController.text = data.email;
      _roleController.text = data.role;
      _genderController.text = data.gender;
      _dateOfBirthController.text = data.dateOfBirth;
      _relationshipStatusController.text = data.relationshipStatus;
      _phoneNumberController.text = data.phoneNumber;
      _alternateNumberController.text = data.alternateNumber;
      _addressController.text = data.address;
      _cityController.text = data.city;
      _stateController.text = data.state;
      _pinCodeController.text = data.pinCode;
      _positionController.text = data.position;
      _employmentTypeController.text = data.employmentType;
      _joiningDateController.text = data.joiningDate;
      _experienceController.text = data.experience;
      _statusController.text = data.status;
      _referenceController.text = data.reference;
      _qualificationController.text = data.qualification;
      _matriculationMarksController.text = data.matriculationMarks;
      _intermediateMarksController.text = data.intermediateMarks;
      _bankAccountNumberController.text = data.bankAccountNumber;
      _ifscCodeController.text = data.ifscCode;
      _bankNameController.text = data.bankName;
      _branchController.text = data.branch;
      _emergencyContactNameController.text = data.emergencyContactName;
      _emergencyContactNumberController.text = data.emergencyContactNumber;

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load employee details: $e")),
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

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    // Update the model object with data from controllers
    final updatedDetails = EmployeeDetails(
      id: _employeeDetails.id,
      fullName: _fullNameController.text,
      email: _emailController.text,
      role: _roleController.text,
      gender: _genderController.text,
      dateOfBirth: _dateOfBirthController.text,
      relationshipStatus: _relationshipStatusController.text,
      phoneNumber: _phoneNumberController.text,
      alternateNumber: _alternateNumberController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      pinCode: _pinCodeController.text,
      position: _positionController.text,
      employmentType: _employmentTypeController.text,
      joiningDate: _joiningDateController.text, // Usually not editable
      experience: _experienceController.text,
      status: _statusController.text,
      reference: _referenceController.text,
      qualification: _qualificationController.text,
      matriculationMarks: _matriculationMarksController.text,
      intermediateMarks: _intermediateMarksController.text,
      bankAccountNumber: _bankAccountNumberController.text,
      ifscCode: _ifscCodeController.text,
      bankName: _bankNameController.text,
      branch: _branchController.text,
      emergencyContactName: _emergencyContactNameController.text,
      emergencyContactNumber: _emergencyContactNumberController.text,
    );

    try {
      await _provider.saveEmployeeDetails(updatedDetails);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Employee Details', style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18))),
            InkWell(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const ModeratorDashboardPage())),
                child: const Icon(
                  Icons.home_sharp,
                  size: 30,
                  color: Colors.white,
                )),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(context),
            const SizedBox(height: 12),
            Text(_fullNameController.text, style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(22), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_emailController.text, style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14))),
            const SizedBox(height: 24),
            _buildSection(
              context: context,
              title: "Personal Details",
              children: [
                _buildTextField(context, "Role", _roleController),
                _buildTextField(context, "Gender", _genderController),
                _buildTextField(context, "Date of Birth", _dateOfBirthController, readOnly: true),
                _buildTextField(context, "Relationship Status", _relationshipStatusController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Contact Details",
              children: [
                _buildTextField(context, "Phone Number", _phoneNumberController),
                _buildTextField(context, "Alternate Number", _alternateNumberController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Address Details",
              children: [
                _buildTextField(context, "Address", _addressController),
                _buildTextField(context, "City", _cityController),
                _buildTextField(context, "State", _stateController),
                _buildTextField(context, "Pin Code", _pinCodeController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Professional Information",
              children: [
                _buildTextField(context, "Position", _positionController),
                _buildTextField(context, "Employment Type", _employmentTypeController),
                _buildTextField(context, "Joining Date", _joiningDateController, readOnly: true),
                _buildTextField(context, "Experience (Years)", _experienceController),
                _buildTextField(context, "Status", _statusController),
                _buildTextField(context, "Reference", _referenceController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Education Details",
              children: [
                _buildTextField(context, "Qualification", _qualificationController),
                _buildTextField(context, "Matriculation Marks (%)", _matriculationMarksController),
                _buildTextField(context, "Intermediate Marks (%)", _intermediateMarksController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Banking Details",
              children: [
                _buildTextField(context, "Bank Account Number", _bankAccountNumberController),
                _buildTextField(context, "IFSC Code", _ifscCodeController),
                _buildTextField(context, "Bank Name", _bankNameController),
                _buildTextField(context, "Branch", _branchController),
              ],
            ),
            _buildSection(
              context: context,
              title: "Emergency Contact",
              children: [
                _buildTextField(context, "Emergency Contact Name", _emergencyContactNameController),
                _buildTextField(context, "Emergency Contact Number", _emergencyContactNumberController),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E86D4),
                  disabledBackgroundColor: const Color(0xFF0E86D4).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text(
                  "Save Changes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(16),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
            backgroundImage: const AssetImage("assets/images/man_image.png"),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: () {},
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

  Widget _buildTextField(BuildContext context, String title, TextEditingController controller, {bool readOnly = false}) {
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFF0D1B2A).withOpacity(0.5) : const Color(0xFF0D1B2A),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0E86D4), width: 1.5)),
          ),
        ),
      ],
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
                  childAspectRatio: 5,
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
}
