import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddModeratorScreen extends StatefulWidget {
  final Map<String, dynamic>? moderator;
  const AddModeratorScreen({super.key, this.moderator});

  @override
  State<AddModeratorScreen> createState() => _AddModeratorScreenState();
}

class _AddModeratorScreenState extends State<AddModeratorScreen> {
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
  final _qualificationController = TextEditingController();
  final _xMarksController = TextEditingController();
  final _xiiMarksController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _joiningDateController = TextEditingController();

  String _gender = "Male";
  String _employmentType = "full-time";
  String _status = "live";

  File? _photo;
  File? _aadharPhoto;
  File? _xMarksheet;
  File? _xiiMarksheet;
  File? _resume;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.moderator != null) {
      final mod = widget.moderator!;
      _nameController.text = mod['name'] ?? '';
      _emailController.text = mod['email'] ?? '';
      _positionController.text = mod['position'] ?? '';
      _dobController.text = mod['date_of_birth'] ?? '';
      _phoneController.text = mod['phone'] ?? '';
      _altPhoneController.text = mod['alternate_phone'] ?? '';
      _addressController.text = mod['address'] ?? '';
      _cityController.text = mod['city'] ?? '';
      _stateController.text = mod['state'] ?? '';
      _pincodeController.text = mod['pincode'] ?? '';
      _experienceController.text = mod['experience']?.toString() ?? '';
      _salaryController.text = mod['salary']?.toString() ?? '';
      _referenceController.text = mod['reference'] ?? '';
      _qualificationController.text = mod['qualification'] ?? '';
      _xMarksController.text = mod['x_marks']?.toString() ?? '';
      _xiiMarksController.text = mod['xii_marks']?.toString() ?? '';
      _aadharNumberController.text = mod['aadhar_number'] ?? '';
      _bankAccountController.text = mod['bank_account_number'] ?? '';
      _ifscController.text = mod['ifsc_code'] ?? '';
      _bankNameController.text = mod['bank_name'] ?? '';
      _branchNameController.text = mod['branch_name'] ?? '';
      _emergencyNameController.text = mod['emergency_contact_name'] ?? '';
      _emergencyPhoneController.text = mod['emergency_contact_number'] ?? '';
      _joiningDateController.text = mod['joining_date'] ?? '';
      _gender = mod['gender'] ?? "Male";
      _employmentType = mod['employment_type'] ?? "full-time";
      _status = mod['status'] ?? "live";
    }
  }

  Future<void> _pickFile(String type) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'photo') _photo = File(pickedFile.path);
        if (type == 'aadhar') _aadharPhoto = File(pickedFile.path);
        if (type == 'x') _xMarksheet = File(pickedFile.path);
        if (type == 'xii') _xiiMarksheet = File(pickedFile.path);
        if (type == 'resume') _resume = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final fields = {
        'name': _nameController.text,
        'email': _emailController.text,
        if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
        'position': _positionController.text,
        'employment_type': _employmentType,
        'gender': _gender,
        'date_of_birth': _dobController.text,
        'aadhar_number': _aadharNumberController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
        'bank_account_number': _bankAccountController.text,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchNameController.text,
        'salary': _salaryController.text,
        'experience': _experienceController.text,
        'status': _status,
        'reference': _referenceController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_number': _emergencyPhoneController.text,
        'qualification': _qualificationController.text,
        'x_marks': _xMarksController.text,
        'xii_marks': _xiiMarksController.text,
        'joining_date': _joiningDateController.text,
        'institute_id': '1', 
        'role_id': '2', 
      };

      final files = {
        if (_photo != null) 'photo': _photo!,
        if (_aadharPhoto != null) 'aadhar_photo': _aadharPhoto!,
        if (_xMarksheet != null) 'x_marksheet_photo': _xMarksheet!,
        if (_xiiMarksheet != null) 'xii_marksheet_photo': _xiiMarksheet!,
        if (_resume != null) 'resume': _resume!,
      };

      if (widget.moderator != null) {
        await ApiService.updateModerate(widget.moderator!['id'].toString(), fields, files: files);
      } else {
        await ApiService.storeModerate(fields, files: files);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Moderator ${widget.moderator != null ? 'updated' : 'created'} successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moderator != null ? "Edit Moderator" : "Register Moderator"),
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
                          title: "Account Information",
                          subtitle: "Login credentials for the platform.",
                          children: [
                            _buildTextField(context, "Name *", "Full Name", Icons.person_outline, _nameController),
                            _buildTextField(context, "Email *", "Email Address", Icons.email_outlined, _emailController),
                            _buildTextField(context, "Password *", "Enter Password", Icons.lock_outline, _passwordController, isPassword: true, required: widget.moderator == null),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Personal Information",
                          subtitle: "Basic demographic details.",
                          children: [
                            _buildResponsiveRow(context, [
                              _buildDropdown(context, "Gender *", _gender, ["Male", "Female", "Other"], (v) => setState(() => _gender = v!)),
                              _buildTextField(context, "Date of Birth *", "YYYY-MM-DD", Icons.calendar_today, _dobController),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Phone *", "Phone Number", Icons.phone_android, _phoneController),
                              _buildTextField(context, "Alternate Phone", "Phone Number", Icons.phone, _altPhoneController),
                            ]),
                            _buildFilePicker(context, "Moderator Photo", _photo, () => _pickFile('photo')),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Employment Info",
                          subtitle: "Position and status details.",
                          children: [
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Position *", "Position", Icons.work_outline, _positionController),
                              _buildDropdown(context, "Employment Type *", _employmentType, ["full-time", "part-time", "internship", "other"], (v) => setState(() => _employmentType = v!)),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Joining Date *", "YYYY-MM-DD", Icons.calendar_today, _joiningDateController),
                              _buildTextField(context, "Experience *", "Years", Icons.history_edu, _experienceController),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Salary", "Amount", Icons.payments_outlined, _salaryController),
                              _buildDropdown(context, "Status *", _status, ["live", "expired"], (v) => setState(() => _status = v!)),
                            ]),
                          ],
                        ),
                        _buildSection(
                          context,
                          title: "Banking & Documents",
                          subtitle: "Official identification and bank details.",
                          children: [
                            _buildTextField(context, "Aadhar Number *", "Number", Icons.fingerprint, _aadharNumberController),
                            _buildFilePicker(context, "Aadhar Photo *", _aadharPhoto, () => _pickFile('aadhar')),
                            _buildResponsiveRow(context, [
                              _buildTextField(context, "Account Number *", "Number", Icons.account_balance_outlined, _bankAccountController),
                              _buildTextField(context, "IFSC Code", "IFSC", Icons.code, _ifscController),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("CANCEL"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _save,
                                child: const Text("SAVE DETAILS"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String subtitle, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, IconData icon, TextEditingController controller, {int maxLines = 1, bool isPassword = false, bool required = true}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: isPassword,
            validator: required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.list, size: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, String label, File? file, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    ),
                    alignment: Alignment.center,
                    child: Text("Choose File", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(file == null ? "No File Chosen" : "File Selected", style: TextStyle(color: theme.hintColor, fontSize: 13)))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
