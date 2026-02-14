import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../manager_dashboard.dart';

class AddAccountantPage extends StatefulWidget {
  const AddAccountantPage({super.key});

  @override
  State<AddAccountantPage> createState() => _AddAccountantPageState();
}

class _AddAccountantPageState extends State<AddAccountantPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for text fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _aadharController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _positionController = TextEditingController();
  final _experienceController = TextEditingController();
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

  // State for dropdowns and date pickers
  String? _gender;
  DateTime? _dateOfBirth;
  String? _relationshipStatus;
  String? _employmentType;
  DateTime? _joiningDate;
  String? _status;
  File? _profileImage;

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _fullNameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _aadharController.dispose();
    _phoneNumberController.dispose();
    _alternateNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _positionController.dispose();
    _experienceController.dispose();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addAccountant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountantData = {
        'name': _fullNameController.text,
        'email': _emailController.text,
        'password': _newPasswordController.text,
        'role_id': '7', // Accountant Role ID
        'institute_id': '1', // This should be dynamic based on the logged-in user
        'gender': _gender,
        'date_of_birth': _dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!) : null,
        'marital_status': _relationshipStatus,
        'aadhar_number': _aadharController.text,
        'phone': _phoneNumberController.text,
        'alternate_phone': _alternateNumberController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pinCodeController.text,
        'position': _positionController.text,
        'employment_type': _employmentType,
        'joining_date': _joiningDate != null ? DateFormat('yyyy-MM-dd').format(_joiningDate!) : null,
        'experience': _experienceController.text,
        'status': _status,
        'reference': _referenceController.text,
        'qualification': _qualificationController.text,
        'matric_marks': _matriculationMarksController.text,
        'inter_marks': _intermediateMarksController.text,
        'bank_account_number': _bankAccountNumberController.text,
        'ifsc_code': _ifscCodeController.text,
        'bank_name': _bankNameController.text,
        'branch': _branchController.text,
        'emergency_contact_name': _emergencyContactNameController.text,
        'emergency_contact_phone': _emergencyContactNumberController.text,
      };

      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        // NOTE: The API endpoint for 'manager/users' must support base64 image uploads.
        // The key 'photo' might need to be adjusted based on your API's requirements.
        accountantData['photo'] = base64Encode(bytes);
      }

      final response = await ApiService.post('manager/users', accountantData);

      if (!mounted) return;
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Accountant added successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add accountant');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
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
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            heroTag: 'addAccountantBtn',
            onPressed: _isLoading ? null : _addAccountant,
            label: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    "Add Accountant",
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
            icon: _isLoading ? null : Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Accountant'),
            InkWell(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManagerDashboardPage())),
                child: const Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenSize.width * 0.04, screenSize.width * 0.04, screenSize.width * 0.04, screenSize.height * 0.15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWideLayout();
              } else {
                return _buildNarrowLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout() {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddAccountantProfileBox(
            image: _profileImage,
            onPickImage: _pickImage,
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(
            context: context,
            title: "Account Details",
            children: [
              _buildEditableInfoTile(context, "Full Name", _fullNameController),
              _buildEditableInfoTile(context, "Email", _emailController, keyboardType: TextInputType.emailAddress),
              _buildEditableInfoTile(context, "New Password", _newPasswordController, isPassword: true),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Personal Details", children: _buildPersonalDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Contact Details", children: _buildContactDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Address Details", children: _buildAddressDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Professional Information", children: _buildProfessionalInformationSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Education & Documents", children: _buildEducationDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Banking Details", children: _buildBankingDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(context: context, title: "Emergency Contact Details", children: _buildEmergencyContactDetailsSection()),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    final screenSize = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(right: screenSize.width * 0.01),
              child: _buildLeftColumn(),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.01),
              child: _buildRightColumn(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftColumn() {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddAccountantProfileBox(
          image: _profileImage,
          onPickImage: _pickImage,
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(
          context: context,
          title: "Account Details",
          children: [
            _buildEditableInfoTile(context, "Full Name", _fullNameController),
            _buildEditableInfoTile(context, "Email", _emailController, keyboardType: TextInputType.emailAddress),
            _buildEditableInfoTile(context, "New Password", _newPasswordController, isPassword: true),
          ],
        ),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Personal Details", children: _buildPersonalDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Contact Details", children: _buildContactDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Address Details", children: _buildAddressDetailsSection()),
      ],
    );
  }

  Widget _buildRightColumn() {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(context: context, title: "Professional Information", children: _buildProfessionalInformationSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Education & Documents", children: _buildEducationDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Banking Details", children: _buildBankingDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(context: context, title: "Emergency Contact Details", children: _buildEmergencyContactDetailsSection()),
      ],
    );
  }

  Widget _buildEditableInfoTile(BuildContext context, String title, TextEditingController controller, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyLarge,
        decoration: _inputDecoration(theme, title),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$title cannot be empty';
          }
          return null;
        },
      ),
    );
  }
  
  Widget _buildDropdownField<T>(BuildContext context, String title, T? value, List<T> items, ValueChanged<T?> onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString().split('.').last))).toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(theme, title),
        validator: (value) => value == null ? 'Please select a $title' : null,
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String title, DateTime? selectedDate, ValueChanged<DateTime?> onDateChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(selectedDate),
        ),
        decoration: _inputDecoration(theme, title).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onDateChanged(picked);
          }
        },
        validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    final isDarkMode = theme.brightness == Brightness.dark;
     return InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
        );
  }

  Widget _buildSectionCard({required BuildContext context, required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  // --- SECTION BUILDERS ---

  List<Widget> _buildPersonalDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Aadhaar Number", _aadharController),
      _buildDropdownField(context, "Gender", _gender, ['Male', 'Female', 'Other'], (val) => setState(() => _gender = val)),
      _buildDatePickerField(context, "Date of Birth", _dateOfBirth, (val) => setState(() => _dateOfBirth = val)),
      _buildDropdownField(context, "Relationship Status", _relationshipStatus, ['Single', 'Married'], (val) => setState(() => _relationshipStatus = val)),
    ];
  }

  List<Widget> _buildContactDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Phone Number", _phoneNumberController, keyboardType: TextInputType.phone),
      _buildEditableInfoTile(context, "Alternate Number", _alternateNumberController, keyboardType: TextInputType.phone),
    ];
  }

  List<Widget> _buildAddressDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Address", _addressController),
      _buildEditableInfoTile(context, "City", _cityController),
      _buildEditableInfoTile(context, "State", _stateController),
      _buildEditableInfoTile(context, "Pin code", _pinCodeController, keyboardType: TextInputType.number),
    ];
  }

  List<Widget> _buildProfessionalInformationSection() {
    return [
      _buildEditableInfoTile(context, "Position", _positionController),
      _buildDropdownField(context, "Employment Type", _employmentType, ['full-time', 'part-time', 'internship', 'contract-based', 'other'], (val) => setState(() => _employmentType = val)),
      _buildDatePickerField(context, "Joining Date", _joiningDate, (val) => setState(() => _joiningDate = val)),
      _buildEditableInfoTile(context, "Experience (Years)", _experienceController, keyboardType: TextInputType.number),
      _buildDropdownField(context, "Status", _status, ['live', 'expired'], (val) => setState(() => _status = val)),
      _buildEditableInfoTile(context, "Reference", _referenceController),
    ];
  }

  List<Widget> _buildEducationDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Qualification", _qualificationController),
      _buildEditableInfoTile(context, "Matriculation Marks (%)", _matriculationMarksController, keyboardType: TextInputType.number),
      _buildEditableInfoTile(context, "Intermediate Marks (%)", _intermediateMarksController, keyboardType: TextInputType.number),
    ];
  }

  List<Widget> _buildBankingDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Bank Account Number", _bankAccountNumberController, keyboardType: TextInputType.number),
      _buildEditableInfoTile(context, "IFSC Code", _ifscCodeController),
      _buildEditableInfoTile(context, "Bank Name", _bankNameController),
      _buildEditableInfoTile(context, "Branch", _branchController),
    ];
  }

  List<Widget> _buildEmergencyContactDetailsSection() {
    return [
      _buildEditableInfoTile(context, "Emergency Contact Name", _emergencyContactNameController),
      _buildEditableInfoTile(context, "Emergency Contact Number", _emergencyContactNumberController, keyboardType: TextInputType.phone),
    ];
  }
}

class _AddAccountantProfileBox extends StatelessWidget {
  final File? image;
  final VoidCallback onPickImage;

  const _AddAccountantProfileBox({
    this.image,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: screenSize.width * 0.15,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: image != null ? FileImage(image!) : null,
            child: image == null
                ? Icon(
                    Icons.person_add_alt_1_rounded,
                    size: screenSize.width * 0.15,
                    color: theme.colorScheme.onSurface.withAlpha(128),
                  )
                : null,
          ),
          SizedBox(height: screenSize.height * 0.01),
          TextButton.icon(
            onPressed: onPickImage,
            icon: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
            label: Text("Upload Photo", style: TextStyle(color: theme.colorScheme.primary)),
          )
        ],
      ),
    );
  }
}
