import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class EditModeratorScreen extends StatefulWidget {
  final dynamic moderator;
  const EditModeratorScreen({super.key, required this.moderator});

  @override
  State<EditModeratorScreen> createState() => _EditModeratorScreenState();
}

class _EditModeratorScreenState extends State<EditModeratorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _positionController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _salaryController = TextEditingController();
  final _referenceController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _xMarksController = TextEditingController();
  final _xiiMarksController = TextEditingController();

  String _gender = "Male";
  String _employmentType = "full-time";
  String _status = "live";
  String? _relationshipStatus = "Single";

  File? _photo;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.moderator;
    _nameController.text = m['name'] ?? '';
    _emailController.text = m['email'] ?? '';
    _positionController.text = m['position'] ?? '';
    _dobController.text = m['date_of_birth'] ?? '';
    _phoneController.text = m['phone'] ?? '';
    _altPhoneController.text = m['alternate_phone'] ?? '';
    _addressController.text = m['address'] ?? '';
    _cityController.text = m['city'] ?? '';
    _stateController.text = m['state'] ?? '';
    _pincodeController.text = m['pincode']?.toString() ?? '';
    _experienceController.text = m['experience']?.toString() ?? '';
    _salaryController.text = m['salary']?.toString() ?? '';
    _referenceController.text = m['reference'] ?? '';
    _aadharNumberController.text = m['aadhar_number'] ?? '';
    _bankAccountController.text = m['bank_account_number'] ?? '';
    _ifscController.text = m['ifsc_code'] ?? '';
    _bankNameController.text = m['bank_name'] ?? '';
    _branchNameController.text = m['branch_name'] ?? '';
    _emergencyNameController.text = m['emergency_contact_name'] ?? '';
    _emergencyPhoneController.text = m['emergency_contact_number'] ?? '';
    _qualificationController.text = m['qualification'] ?? '';
    _xMarksController.text = m['x_marks']?.toString() ?? '';
    _xiiMarksController.text = m['xii_marks']?.toString() ?? '';

    _gender = m['gender'] ?? "Male";
    _employmentType = m['employment_type'] ?? "full-time";
    _status = m['status'] ?? "live";
    _relationshipStatus = m['relationship_status'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _photo = File(pickedFile.path));
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final Map<String, String> fields = {
        'name': _nameController.text,
        'email': _emailController.text,
        if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
        'position': _positionController.text,
        'gender': _gender,
        'employment_type': _employmentType,
        'date_of_birth': _dobController.text,
        'aadhar_number': _aadharNumberController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
        'bank_account_number': _bankAccountController.text,
        'status': _status,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchNameController.text,
        'salary': _salaryController.text,
        'experience': _experienceController.text,
        'reference': _referenceController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_number': _emergencyPhoneController.text,
        'qualification': _qualificationController.text,
        'x_marks': _xMarksController.text,
        'xii_marks': _xiiMarksController.text,
        if (_relationshipStatus != null) 'relationship_status': _relationshipStatus!,
      };

      Map<String, File>? files;
      if (_photo != null) files = {'photo': _photo!};

      await ApiService.updateModerate(widget.moderator['id'].toString(), fields, files: files);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Moderator updated successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Moderator", style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSection(
                          context,
                          title: "Account Info",
                          children: [
                            _buildTextField(context, "Name *", _nameController, Icons.person_outline),
                            _buildTextField(context, "Email *", _emailController, Icons.email_outlined),
                            _buildTextField(context, "New Password", _passwordController, Icons.lock_outline, isPassword: true, required: false),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Personal Info",
                          children: [
                            _buildResponsiveRow(context, [
                              _buildDropdown(context, "Gender *", _gender, ["Male", "Female", "Other"], (v) => setState(() => _gender = v!)),
                              _buildTextField(context, "DOB (YYYY-MM-DD) *", _dobController, Icons.calendar_today),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Phone *", _phoneController, Icons.phone_android),
                              _buildTextField(context, "Aadhar Number *", _aadharNumberController, Icons.fingerprint),
                            ]),
                            _buildFilePicker(context, "New Photo"),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Address",
                          children: [
                            _buildTextField(context, "Address *", _addressController, Icons.location_on_outlined, maxLines: 2),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "City *", _cityController, Icons.location_city),
                              _buildTextField(context, "State *", _stateController, Icons.map_outlined),
                            ]),
                            _buildTextField(context, "Pincode *", _pincodeController, Icons.pin_drop_outlined),
                          ],
                        ),
                        SizedBox(height: context.scale(32)),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                                ),
                                child: Text("CANCEL", style: TextStyle(fontSize: context.font(14))),
                              ),
                            ),
                            SizedBox(width: context.scale(16)),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _update,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                                ),
                                child: Text("UPDATE DETAILS", style: TextStyle(fontSize: context.font(14))),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.scale(40)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      margin: EdgeInsets.only(bottom: context.scale(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.scale(16)),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(context.scale(16)), topRight: Radius.circular(context.scale(16))),
            ),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(16))),
          ),
          Padding(padding: EdgeInsets.all(context.scale(16)), child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: context.scale(12)), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool isPassword = false, bool required = true}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: isPassword,
            style: TextStyle(fontSize: context.font(14)),
            validator: required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: context.scale(18)),
              contentPadding: EdgeInsets.all(context.scale(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            style: TextStyle(fontSize: context.font(14), color: theme.textTheme.bodyMedium?.color),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: TextStyle(fontSize: context.font(12))))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.list, size: context.scale(18)),
              contentPadding: EdgeInsets.all(context.scale(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, String label) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
          SizedBox(height: context.scale(8)),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(context.scale(12)),
            child: Container(
              height: context.scale(56),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(context.scale(12)), bottomLeft: Radius.circular(context.scale(12))),
                    ),
                    alignment: Alignment.center,
                    child: Text("Choose Photo", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(13))),
                  ),
                  Expanded(child: Padding(padding: EdgeInsets.only(left: context.scale(12)), child: Text(_photo == null ? "No file chosen" : "Photo Selected", style: TextStyle(color: theme.hintColor, fontSize: context.font(13))))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
