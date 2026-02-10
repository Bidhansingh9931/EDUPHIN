import 'package:flutter/material.dart';

import 'employee_details.dart';
import 'employee_details_provider.dart';

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
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Personal Details',
                    children: [
                      _buildTextField(controller: _fullNameController, label: 'Full Name'),
                      _buildTextField(controller: _emailController, label: 'Email'),
                      _buildTextField(controller: _roleController, label: 'Role'),
                      _buildTextField(controller: _genderController, label: 'Gender'),
                      _buildTextField(controller: _dateOfBirthController, label: 'Date of Birth'),
                      _buildTextField(controller: _relationshipStatusController, label: 'Relationship Status'),
                    ],
                  ),
                  _buildSection(
                    title: 'Contact Information',
                    children: [
                      _buildTextField(controller: _phoneNumberController, label: 'Phone Number'),
                      _buildTextField(controller: _alternateNumberController, label: 'Alternate Number'),
                      _buildTextField(controller: _addressController, label: 'Address'),
                      _buildTextField(controller: _cityController, label: 'City'),
                      _buildTextField(controller: _stateController, label: 'State'),
                      _buildTextField(controller: _pinCodeController, label: 'Pincode'),
                    ],
                  ),
                  _buildSection(
                    title: 'Employment Details',
                    children: [
                      _buildTextField(controller: _positionController, label: 'Position'),
                      _buildTextField(controller: _employmentTypeController, label: 'Employment Type'),
                      _buildTextField(controller: _joiningDateController, label: 'Joining Date', readOnly: true),
                      _buildTextField(controller: _experienceController, label: 'Experience (Years)'),
                      _buildTextField(controller: _statusController, label: 'Status'),
                      _buildTextField(controller: _referenceController, label: 'Reference'),
                    ],
                  ),
                  _buildSection(
                    title: 'Educational Qualification',
                    children: [
                      _buildTextField(controller: _qualificationController, label: 'Qualification'),
                      _buildTextField(controller: _matriculationMarksController, label: 'Matriculation Marks'),
                      _buildTextField(controller: _intermediateMarksController, label: 'Intermediate Marks'),
                    ],
                  ),
                  _buildSection(
                    title: 'Bank Details',
                    children: [
                      _buildTextField(controller: _bankAccountNumberController, label: 'Bank Account Number'),
                      _buildTextField(controller: _ifscCodeController, label: 'IFSC Code'),
                      _buildTextField(controller: _bankNameController, label: 'Bank Name'),
                      _buildTextField(controller: _branchController, label: 'Branch'),
                    ],
                  ),
                  _buildSection(
                    title: 'Emergency Contact',
                    children: [
                      _buildTextField(controller: _emergencyContactNameController, label: 'Emergency Contact Name'),
                      _buildTextField(controller: _emergencyContactNumberController, label: 'Emergency Contact Number'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1B263B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 20,
            thickness: 1,
          ),
          ...children,
        ],
      ),
    );
  }
}
