import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/foundation.dart';
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
  Uint8List? _webImage;
  String? _imageName;

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
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageName = image.name;
        });
      } else {
        setState(() {
          _profileImage = File(image.path);
        });
      }
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
      status: statusController.text.toLowerCase(),
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
      webImage: _webImage,
      imageName: _imageName,
    );

    try {
      await ApiService.addEmployee(newEmployee);

      // Clear employee list cache for this institute
      await CacheHelper.clear('employees_list_${widget.instituteId}');

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
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Add Employee',
          style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding.copyWith(bottom: context.scale(80)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ProfileAvatar(
                    radius: context.scale(60),
                    localImage: _profileImage,
                    webImage: _webImage,
                    onCameraTap: _pickImage,
                  ),
                ),
                SizedBox(height: context.lg),
                _buildSection(
                  context: context,
                  title: "Personal Details",
                  children: [
                    _buildTextField(context: context, controller: fullNameController, label: "Full Name", icon: Icons.person_outline_sharp),
                    _buildTextField(context: context, controller: emailController, label: "Email", icon: Icons.email_outlined),
                    _buildDropdown(context: context, title: "Select Role", value: selectedRole, hint: "Assign a Role", items: ["Institute Manager", "Counselors", "Teacher", "Student", "Librarian", "Accountant", "Staff"], onChanged: (value) => setState(() => selectedRole = value)),
                    _buildDropdown(context: context, title: "Select Gender", value: selectedGender, hint: "Select Gender", items: ["Male", "Female", "Other"], onChanged: (value) => setState(() => selectedGender = value ?? "Male")),
                    _buildDatePickerField(context: context, hint: 'Select birth date', title: "Date of Birth", currentValue: selectedBirthDate, onConfirm: (date) => setState(() => selectedBirthDate = date)),
                    _buildDropdown(context: context, title: "Relationship Status", value: selectedRelationshipStatus, hint: "Select Relationship Status", items: ["Single", "Married", "Divorced", "Widowed"], onChanged: (value) => setState(() => selectedRelationshipStatus = value)),
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
                    _buildDropdown(context: context, title: "Employment Type", value: selectedEmploymentType, hint: "Select Employment Type", items: ["Full-time", "Part-time", "Contract", "Internship"], onChanged: (value) => setState(() => selectedEmploymentType = value)),
                    _buildDatePickerField(context: context, hint: 'Select joining date', title: "Joining Date", currentValue: selectedJoiningDate, onConfirm: (date) => setState(() => selectedJoiningDate = date)),
                    _buildTextField(context: context, controller: experienceController, label: "Experience (Years)", icon: Icons.work_history_outlined, isNumeric: true),
                    _buildDropdown(
                      context: context,
                      title: "Status",
                      value: statusController.text.isEmpty ? 'live' : statusController.text,
                      hint: "Select Status",
                      items: ["live", "expired"],
                      onChanged: (value) => setState(() => statusController.text = value ?? "live"),
                    ),
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
                SizedBox(height: context.lg),
                SizedBox(
                  width: double.infinity,
                  height: context.scale(56),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEmployeeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.primary,
                      foregroundColor: context.theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: context.scale(24),
                            width: context.scale(24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(context.theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text('Add Employee', style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.md),
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: context.font(20),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: context.sm),
                Text(title, style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: context.theme.colorScheme.onSurface)),
              ],
            ),
            SizedBox(height: context.md),
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.md,
                    mainAxisSpacing: context.sm,
                    mainAxisExtent: context.scale(85),
                  ),
                  itemBuilder: (context, index) => children[index],
                );
              } else {
                return Column(
                  children: children.map((widget) => Padding(padding: EdgeInsets.only(bottom: context.sm), child: widget)).toList(),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required BuildContext context, required TextEditingController controller, required String label, required IconData icon, bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500)),
        SizedBox(height: context.xs),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: context.font(14)),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: context.scale(20), color: context.theme.colorScheme.primary),
            filled: true,
            fillColor: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.scale(12)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(8)),
              borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(8)),
              borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(8)),
              borderSide: BorderSide(color: context.theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required BuildContext context, required String title, required String? value, String? hint, required List<String> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500)),
        SizedBox(height: context.xs),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(8)),
              borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(8)),
              borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
            ),
          ),
          hint: Text(hint ?? '', style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
          dropdownColor: context.theme.colorScheme.surfaceContainerLow,
          style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: context.font(14)),
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({required BuildContext context, required String title, required String hint, DateTime? currentValue, required Function(DateTime) onConfirm}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500)),
        SizedBox(height: context.xs),
        InkWell(
          onTap: () {
            picker.DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(1950, 1, 1),
                maxTime: DateTime.now(),
                onConfirm: onConfirm, 
                currentTime: currentValue ?? DateTime.now(),
                theme: picker.DatePickerTheme(
                  backgroundColor: context.theme.colorScheme.surface,
                  itemStyle: TextStyle(color: context.theme.colorScheme.onSurface),
                  cancelStyle: TextStyle(color: context.theme.colorScheme.onSurfaceVariant),
                  doneStyle: TextStyle(color: context.theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.scale(12)),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(context.scale(8)),
              border: Border.all(color: context.theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: context.theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(12)),
                Text(
                  currentValue != null ? DateFormat.yMMMd().format(currentValue) : hint,
                  style: TextStyle(
                    color: currentValue != null ? context.theme.colorScheme.onSurface : context.theme.colorScheme.onSurfaceVariant,
                    fontSize: context.font(14),
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
