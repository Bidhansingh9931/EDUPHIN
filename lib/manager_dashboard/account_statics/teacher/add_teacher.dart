import 'dart:convert';
import 'dart:typed_data';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/models/new_employee.dart';
import 'package:eduphin/models/new_student.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
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

  // State variables
  String? _gender;
  DateTime? _dateOfBirth;
  String? _relationshipStatus;
  String? _employmentType;
  DateTime? _joiningDate;
  String? _status;
  
  AppFile? _profileImage;
  AppFile? _matriculationMarksheet;
  AppFile? _intermediateMarksheet;
  AppFile? _resume;

  @override
  void dispose() {
    // Dispose all controllers
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
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImage = AppFile(
          name: pickedFile.name,
          bytes: bytes,
          path: kIsWeb ? null : pickedFile.path,
        );
      });
    }
  }

  Future<void> _pickFile(Function(AppFile) onFilePicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        final file = result.files.single;
        setState(() {
          onFilePicked(AppFile(
            name: file.name,
            bytes: file.bytes,
            path: kIsWeb ? null : file.path,
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _addTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = NewEmployee()
        ..name = _fullNameController.text
        ..email = _emailController.text
        ..password = _newPasswordController.text
        ..roleId = '5' // Teacher
        ..gender = _gender
        ..dob = _dateOfBirth
        ..relationshipStatus = _relationshipStatus
        ..aadharNumber = _aadharController.text
        ..phone = _phoneNumberController.text
        ..alternatePhone = _alternateNumberController.text
        ..address = _addressController.text
        ..city = _cityController.text
        ..state = _stateController.text
        ..pincode = _pinCodeController.text
        ..position = _positionController.text
        ..employmentType = _employmentType
        ..joiningDate = _joiningDate
        ..experience = _experienceController.text
        ..status = _status
        ..reference = _referenceController.text
        ..qualification = _qualificationController.text
        ..matricMarks = _matriculationMarksController.text
        ..interMarks = _intermediateMarksController.text
        ..bankAccountNumber = _bankAccountNumberController.text
        ..ifscCode = _ifscCodeController.text
        ..bankName = _bankNameController.text
        ..branch = _branchController.text
        ..emergencyContactName = _emergencyContactNameController.text
        ..emergencyContactNumber = _emergencyContactNumberController.text
        ..photo = _profileImage
        ..matriculationMarksheet = _matriculationMarksheet
        ..intermediateMarksheet = _intermediateMarksheet
        ..resume = _resume;

      await ApiService.addEmployeeUser(employee);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher added successfully!')),
      );
      Navigator.pop(context, true);
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
            heroTag: 'addTeacherBtn',
            onPressed: _isLoading ? null : _addTeacher,
            label: _isLoading
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : Text("Add Teacher", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            icon: _isLoading ? null : Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Teacher'),
            InkWell(
                onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const ManagerDashboardPage())),
                child: const Icon(Icons.home_sharp, size: 30)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenSize.width * 0.04, screenSize.width * 0.04, screenSize.width * 0.04, screenSize.height * 0.15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth > 800 ? _buildWideLayout() : _buildNarrowLayout();
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
          _AddTeacherProfileBox(image: _profileImage, onPickImage: _pickImage),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Account Details", children: _buildAccountDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Personal Details", children: _buildPersonalDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Contact Details", children: _buildContactDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Address Details", children: _buildAddressDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Professional Information", children: _buildProfessionalInformationSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Education & Documents", children: _buildEducationDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Banking Details", children: _buildBankingDetailsSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildSectionCard(title: "Emergency Contact Details", children: _buildEmergencyContactDetailsSection()),
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
        _AddTeacherProfileBox(image: _profileImage, onPickImage: _pickImage),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Account Details", children: _buildAccountDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Personal Details", children: _buildPersonalDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Contact Details", children: _buildContactDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Address Details", children: _buildAddressDetailsSection()),
      ],
    );
  }

  Widget _buildRightColumn() {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(title: "Professional Information", children: _buildProfessionalInformationSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Education & Documents", children: _buildEducationDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Banking Details", children: _buildBankingDetailsSection()),
        SizedBox(height: screenSize.height * 0.02),
        _buildSectionCard(title: "Emergency Contact Details", children: _buildEmergencyContactDetailsSection()),
      ],
    );
  }

  Widget _buildEditableInfoTile(String title, TextEditingController controller, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
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
  
  Widget _buildDropdownField<T>(String title, T? value, List<T> items, ValueChanged<T?> onChanged) {
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

  Widget _buildDatePickerField(String title, DateTime? selectedDate, ValueChanged<DateTime?> onDateChanged) {
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

  Widget _buildFilePickerTile(String title, AppFile? file, VoidCallback onPickFile) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: file?.name ?? 'No file selected'),
        decoration: _inputDecoration(theme, title).copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: onPickFile,
          ),
        ),
        onTap: onPickFile,
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
        );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleLarge), const Divider(height: 24), ...children]),
    );
  }

  // --- SECTION BUILDERS ---

   List<Widget> _buildAccountDetailsSection() {
    return [
      _buildEditableInfoTile("Full Name", _fullNameController),
      _buildEditableInfoTile("Email", _emailController, keyboardType: TextInputType.emailAddress),
      _buildEditableInfoTile("New Password", _newPasswordController, isPassword: true),
    ];
  }

  List<Widget> _buildPersonalDetailsSection() {
    return [
      _buildEditableInfoTile("Aadhaar Number", _aadharController),
      _buildDropdownField("Gender", _gender, ['Male', 'Female', 'Other'], (val) => setState(() => _gender = val)),
      _buildDatePickerField("Date of Birth", _dateOfBirth, (val) => setState(() => _dateOfBirth = val)),
      _buildDropdownField("Relationship Status", _relationshipStatus, ['Single', 'Married'], (val) => setState(() => _relationshipStatus = val)),
    ];
  }

  List<Widget> _buildContactDetailsSection() {
    return [
      _buildEditableInfoTile("Phone Number", _phoneNumberController, keyboardType: TextInputType.phone),
      _buildEditableInfoTile("Alternate Number", _alternateNumberController, keyboardType: TextInputType.phone),
    ];
  }

  List<Widget> _buildAddressDetailsSection() {
    return [
      _buildEditableInfoTile("Address", _addressController),
      _buildEditableInfoTile("City", _cityController),
      _buildEditableInfoTile("State", _stateController),
      _buildEditableInfoTile("Pin code", _pinCodeController, keyboardType: TextInputType.number),
    ];
  }

  List<Widget> _buildProfessionalInformationSection() {
    return [
      _buildEditableInfoTile("Position", _positionController),
      _buildDropdownField("Employment Type", _employmentType, ['full-time', 'part-time', 'internship', 'contract-based', 'other'], (val) => setState(() => _employmentType = val)),
      _buildDatePickerField("Joining Date", _joiningDate, (val) => setState(() => _joiningDate = val)),
      _buildEditableInfoTile("Experience (Years)", _experienceController, keyboardType: TextInputType.number),
      _buildDropdownField("Status", _status, ['live', 'expired'], (val) => setState(() => _status = val)),
      _buildEditableInfoTile("Reference", _referenceController),
    ];
  }

  List<Widget> _buildEducationDetailsSection() {
    return [
      _buildEditableInfoTile("Qualification", _qualificationController),
      _buildEditableInfoTile("Matriculation Marks (%)", _matriculationMarksController, keyboardType: TextInputType.number),
      _buildEditableInfoTile("Intermediate Marks (%)", _intermediateMarksController, keyboardType: TextInputType.number),
      _buildFilePickerTile("Matriculation Marksheet", _matriculationMarksheet, () => _pickFile((file) => _matriculationMarksheet = file)),
      _buildFilePickerTile("Intermediate Marksheet", _intermediateMarksheet, () => _pickFile((file) => _intermediateMarksheet = file)),
      _buildFilePickerTile("Resume", _resume, () => _pickFile((file) => _resume = file)),
    ];
  }

  List<Widget> _buildBankingDetailsSection() {
    return [
      _buildEditableInfoTile("Bank Account Number", _bankAccountNumberController, keyboardType: TextInputType.number),
      _buildEditableInfoTile("IFSC Code", _ifscCodeController),
      _buildEditableInfoTile("Bank Name", _bankNameController),
      _buildEditableInfoTile("Branch", _branchController),
    ];
  }

  List<Widget> _buildEmergencyContactDetailsSection() {
    return [
      _buildEditableInfoTile("Emergency Contact Name", _emergencyContactNameController),
      _buildEditableInfoTile("Emergency Contact Number", _emergencyContactNumberController, keyboardType: TextInputType.phone),
    ];
  }
}

class _AddTeacherProfileBox extends StatelessWidget {
  final AppFile? image;
  final VoidCallback onPickImage;

  const _AddTeacherProfileBox({this.image, required this.onPickImage});

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
            backgroundImage: (image != null && image!.bytes != null) ? MemoryImage(image!.bytes!) : null,
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
