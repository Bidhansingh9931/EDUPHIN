import 'dart:io';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _profileImage;
  Uint8List? _webImage;
  String? _imageName;

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
      _employeeDetails = data ?? EmployeeDetails(); // If data is null, create an empty EmployeeDetails object

      // Populate controllers with fetched data
      _fullNameController.text = _employeeDetails.fullName ?? '';
      _emailController.text = _employeeDetails.email ?? '';
      _roleController.text = _employeeDetails.role ?? '';
      _genderController.text = _employeeDetails.gender ?? '';
      _dateOfBirthController.text = _employeeDetails.dateOfBirth ?? '';
      _relationshipStatusController.text = _employeeDetails.relationshipStatus ?? '';
      _phoneNumberController.text = _employeeDetails.phoneNumber ?? '';
      _alternateNumberController.text = _employeeDetails.alternateNumber ?? '';
      _addressController.text = _employeeDetails.address ?? '';
      _cityController.text = _employeeDetails.city ?? '';
      _stateController.text = _employeeDetails.state ?? '';
      _pinCodeController.text = _employeeDetails.pinCode ?? '';
      _positionController.text = _employeeDetails.position ?? '';
      _employmentTypeController.text = _employeeDetails.employmentType ?? '';
      _joiningDateController.text = _employeeDetails.joiningDate ?? '';
      _experienceController.text = _employeeDetails.experience ?? '';
      _statusController.text = _employeeDetails.status ?? '';
      _referenceController.text = _employeeDetails.reference ?? '';
      _qualificationController.text = _employeeDetails.qualification ?? '';
      _matriculationMarksController.text = _employeeDetails.matriculationMarks ?? '';
      _intermediateMarksController.text = _employeeDetails.intermediateMarks ?? '';
      _bankAccountNumberController.text = _employeeDetails.bankAccountNumber ?? '';
      _ifscCodeController.text = _employeeDetails.ifscCode ?? '';
      _bankNameController.text = _employeeDetails.bankName ?? '';
      _branchController.text = _employeeDetails.branch ?? '';
      _emergencyContactNameController.text = _employeeDetails.emergencyContactName ?? '';
      _emergencyContactNumberController.text = _employeeDetails.emergencyContactNumber ?? '';

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
      photo: _employeeDetails.photo,
      profileImage: _profileImage,
      webImage: _webImage,
      imageName: _imageName,
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


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Employee Details',
          style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.theme.colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding.copyWith(bottom: context.scale(80)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: context.lg),
                        child: ProfileAvatar(
                          imageUrl: _employeeDetails.photo,
                          radius: context.scale(50),
                          localImage: _profileImage,
                          webImage: _webImage,
                          onCameraTap: _pickImage,
                        ),
                      ),
                      _buildSection(
                        context: context,
                        title: 'Personal Details',
                        children: [
                          _buildTextField(context: context, controller: _fullNameController, label: 'Full Name'),
                          _buildTextField(context: context, controller: _emailController, label: 'Email'),
                          _buildDropdownField(
                            context: context,
                            controller: _roleController,
                            label: 'Role',
                            items: ['Institute Manager', 'Counselors', 'Teacher', 'Student', 'Librarian', 'Accountant', 'Staff'],
                          ),
                          _buildDropdownField(
                            context: context,
                            controller: _genderController,
                            label: 'Gender',
                            items: ['Male', 'Female', 'Other'],
                          ),
                          _buildTextField(
                            context: context,
                            controller: _dateOfBirthController,
                            label: 'Date of Birth',
                            readOnly: true,
                            onTap: () => _selectDate(context, _dateOfBirthController),
                          ),
                          _buildDropdownField(
                            context: context,
                            controller: _relationshipStatusController,
                            label: 'Relationship Status',
                            items: ['Single', 'Married', 'Divorced', 'Widowed'],
                          ),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Contact Information',
                        children: [
                          _buildTextField(context: context, controller: _phoneNumberController, label: 'Phone Number'),
                          _buildTextField(context: context, controller: _alternateNumberController, label: 'Alternate Number'),
                          _buildTextField(context: context, controller: _addressController, label: 'Address'),
                          _buildTextField(context: context, controller: _cityController, label: 'City'),
                          _buildTextField(context: context, controller: _stateController, label: 'State'),
                          _buildTextField(context: context, controller: _pinCodeController, label: 'Pincode'),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Employment Details',
                        children: [
                          _buildTextField(context: context, controller: _positionController, label: 'Position'),
                          _buildDropdownField(
                            context: context,
                            controller: _employmentTypeController,
                            label: 'Employment Type',
                            items: ['Full-time', 'Part-time', 'Contract', 'Internship'],
                          ),
                          _buildTextField(
                            context: context,
                            controller: _joiningDateController,
                            label: 'Joining Date',
                            readOnly: true,
                            onTap: () => _selectDate(context, _joiningDateController),
                          ),
                          _buildTextField(context: context, controller: _experienceController, label: 'Experience (Years)'),
                          _buildDropdownField(
                            context: context,
                            controller: _statusController,
                            label: 'Status',
                            items: ['live', 'expired'],
                          ),
                          _buildTextField(context: context, controller: _referenceController, label: 'Reference'),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Educational Qualification',
                        children: [
                          _buildTextField(context: context, controller: _qualificationController, label: 'Qualification'),
                          _buildTextField(context: context, controller: _matriculationMarksController, label: 'Matriculation Marks'),
                          _buildTextField(context: context, controller: _intermediateMarksController, label: 'Intermediate Marks'),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Bank Details',
                        children: [
                          _buildTextField(context: context, controller: _bankAccountNumberController, label: 'Bank Account Number'),
                          _buildTextField(context: context, controller: _ifscCodeController, label: 'IFSC Code'),
                          _buildTextField(context: context, controller: _bankNameController, label: 'Bank Name'),
                          _buildTextField(context: context, controller: _branchController, label: 'Branch'),
                        ],
                      ),
                      _buildSection(
                        context: context,
                        title: 'Emergency Contact',
                        children: [
                          _buildTextField(context: context, controller: _emergencyContactNameController, label: 'Emergency Contact Name'),
                          _buildTextField(context: context, controller: _emergencyContactNumberController, label: 'Emergency Contact Number'),
                        ],
                      ),
                      SizedBox(height: context.lg),
                      SizedBox(
                        width: double.infinity,
                        height: context.scale(56),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.theme.colorScheme.primary,
                            foregroundColor: context.theme.colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  height: context.scale(24),
                                  width: context.scale(24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(context.theme.colorScheme.onPrimary),
                                  ),
                                )
                              : Text('Save Changes', style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500)),
          SizedBox(height: context.xs),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(fontSize: context.font(14)),
            decoration: InputDecoration(
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
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required List<String> items,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.w500)),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            initialValue: items.contains(controller.text) ? controller.text : null,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: TextStyle(fontSize: context.font(14))),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                controller.text = newValue ?? '';
              });
            },
            decoration: InputDecoration(
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
                    mainAxisSpacing: context.xs,
                    mainAxisExtent: context.scale(85),
                  ),
                  itemBuilder: (context, index) => children[index],
                );
              } else {
                return Column(
                  children: children.map((widget) => widget).toList(),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

}
