import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddLibrarianPage extends StatefulWidget {
  const AddLibrarianPage({super.key});

  @override
  State<AddLibrarianPage> createState() => _AddLibrarianPageState();
}

class _AddLibrarianPageState extends State<AddLibrarianPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aadharController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _positionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _referenceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _matricMarksController = TextEditingController();
  final _interMarksController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  String? _maritalStatus;
  String? _employmentType;
  DateTime? _joiningDate;
  String? _status;
  File? _profileImage;

  @override
  void dispose() {
    final controllers = [
      _fullNameController, _emailController, _passwordController, _aadharController,
      _phoneController, _altPhoneController, _addressController, _cityController,
      _stateController, _pinCodeController, _positionController, _experienceController,
      _referenceController, _qualificationController, _matricMarksController,
      _interMarksController, _bankAccController, _ifscController, _bankNameController,
      _branchController, _emergencyNameController, _emergencyPhoneController
    ];
    for (var c in controllers) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _profileImage = File(pickedFile.path));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role_id': '6', // Librarian
        'gender': _gender,
        'date_of_birth': _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : null,
        'marital_status': _maritalStatus,
        'aadhar_number': _aadharController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
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
        'matric_marks': _matricMarksController.text,
        'inter_marks': _interMarksController.text,
        'bank_account_number': _bankAccController.text,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch': _branchController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_phone': _emergencyPhoneController.text,
      };

      if (_profileImage != null) data['photo'] = base64Encode(await _profileImage!.readAsBytes());

      final response = await ApiService.post('manager/users', data);
      final resBody = jsonDecode(response.body);

      if (response.statusCode == 200 && resBody['status'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Librarian added!')));
        Navigator.pop(context, true);
      } else {
        throw Exception(resBody['message'] ?? 'Failed to add librarian');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Librarian")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildFormGrid(),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Librarian"),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null ? const Icon(Icons.add_a_photo, size: 30) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text("Upload Profile Photo", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFormGrid() {
    final crossAxisCount = context.responsive(1, tablet: 2);
    return Column(
      children: [
        _SectionHeader(title: "Account Information"),
        _ResponsiveGrid(
          crossAxisCount: crossAxisCount,
          children: [
            _buildTextField("Full Name", _fullNameController, Icons.person),
            _buildTextField("Email Address", _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
            _buildTextField("Password", _passwordController, Icons.lock, isPassword: true),
            _buildTextField("Aadhar Number", _aadharController, Icons.badge),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: "Personal Details"),
        _ResponsiveGrid(
          crossAxisCount: crossAxisCount,
          children: [
            _buildDropdown("Gender", _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v)),
            _buildDatePicker("Date of Birth", _dob, (d) => setState(() => _dob = d)),
            _buildDropdown("Marital Status", _maritalStatus, ['Single', 'Married'], (v) => setState(() => _maritalStatus = v)),
            _buildTextField("Phone Number", _phoneController, Icons.phone, keyboardType: TextInputType.phone),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: "Professional Details"),
        _ResponsiveGrid(
          crossAxisCount: crossAxisCount,
          children: [
            _buildTextField("Position", _positionController, Icons.work),
            _buildDropdown("Employment Type", _employmentType, ['Full-time', 'Part-time', 'Contract'], (v) => setState(() => _employmentType = v)),
            _buildDatePicker("Joining Date", _joiningDate, (d) => setState(() => _joiningDate = d)),
            _buildTextField("Experience (Years)", _experienceController, Icons.history, keyboardType: TextInputType.number),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 20)),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Required" : null,
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, ValueChanged<DateTime?> onChanged) {
    return TextFormField(
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onChanged(date);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 20),
        hintText: selectedDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(selectedDate),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        const Divider(),
      ]),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;
  const _ResponsiveGrid({required this.crossAxisCount, required this.children});
  @override
  Widget build(BuildContext context) {
    if (crossAxisCount == 1) return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
    return Wrap(
      spacing: 16, runSpacing: 16,
      children: children.map((c) => SizedBox(width: (MediaQuery.of(context).size.width - context.spacing * 2 - 16) / crossAxisCount, child: c)).toList(),
    );
  }
}
