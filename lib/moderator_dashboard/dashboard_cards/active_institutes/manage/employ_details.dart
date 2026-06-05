import 'package:eduphin/services/error_handler.dart';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
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
  late Future<EmployeeDetails?> _detailsFuture;
  EmployeeDetails? _cachedDetails;
  bool _isSaving = false;

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
    _detailsFuture = _provider.fetchEmployeeDetails(widget.employeeId);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedDetails = await _provider.getCachedEmployeeDetails(widget.employeeId);
    if (_cachedDetails != null) {
      _populateControllers(_cachedDetails!);
    }
    _fetchDetails();
  }

  void _fetchDetails({bool bypassCache = false}) {
    debugPrint('DEBUG: Fetching details for employeeId: ${widget.employeeId}');
    setState(() {
      _detailsFuture = _provider.fetchEmployeeDetails(widget.employeeId, bypassCache: bypassCache);
      _detailsFuture.then((data) {
        if (mounted && data != null) {
          debugPrint('DEBUG: Received data for: ${data.fullName} (ID: ${data.id})');
          _populateControllers(data);
        }
      }).catchError((e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      });
    });
  }

  void _populateControllers(EmployeeDetails data) {
    _fullNameController.text = data.fullName ?? '';
    _emailController.text = data.email ?? '';
    _roleController.text = data.role ?? '';
    _genderController.text = data.gender ?? '';
    _dateOfBirthController.text = data.dateOfBirth ?? '';
    _relationshipStatusController.text = data.relationshipStatus ?? '';
    _phoneNumberController.text = data.phoneNumber ?? '';
    _alternateNumberController.text = data.alternateNumber ?? '';
    _addressController.text = data.address ?? '';
    _cityController.text = data.city ?? '';
    _stateController.text = data.state ?? '';
    _pinCodeController.text = data.pinCode ?? '';
    _positionController.text = data.position ?? '';
    _employmentTypeController.text = data.employmentType ?? '';
    _joiningDateController.text = data.joiningDate ?? '';
    _experienceController.text = data.experience ?? '';
    _statusController.text = data.status ?? '';
    _referenceController.text = data.reference ?? '';
    _qualificationController.text = data.qualification ?? '';
    _matriculationMarksController.text = data.matriculationMarks ?? '';
    _intermediateMarksController.text = data.intermediateMarks ?? '';
    _bankAccountNumberController.text = data.bankAccountNumber ?? '';
    _ifscCodeController.text = data.ifscCode ?? '';
    _bankNameController.text = data.bankName ?? '';
    _branchController.text = data.branch ?? '';
    _emergencyContactNameController.text = data.emergencyContactName ?? '';
    _emergencyContactNumberController.text = data.emergencyContactNumber ?? '';
  }

  Future<void> _refreshDetails() async {
    _fetchDetails(bypassCache: true);
    await _detailsFuture;
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
    final details = await _detailsFuture;
    if (details == null) return;

    setState(() {
      _isSaving = true;
    });

    // Update the model object with data from controllers
    final updatedDetails = EmployeeDetails(
      id: details.id,
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
      photo: details.photo,
      profileImage: _profileImage,
      webImage: _webImage,
      imageName: _imageName,
      instituteId: details.instituteId,
    );

    try {
      await _provider.saveEmployeeDetails(updatedDetails);

      // Clear the employee list cache to ensure the list view reflects changes
      final details = await _detailsFuture;
      if (details != null && details.instituteId != null) {
        await CacheHelper.clear('employees_list_${details.instituteId}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDetails(bypassCache: true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
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
        actions: [
          IconButton(
            onPressed: _refreshDetails,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<EmployeeDetails?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<EmployeeDetails?>(
            snapshot: snapshot,
            cachedData: _cachedDetails,
            skeleton: const DetailSkeleton(),
            onRefresh: _refreshDetails,
            builder: (details) {
              if (details == null) {
                return const Center(child: Text("Employee details not found"));
              }
              return RefreshIndicator(
                onRefresh: _refreshDetails,
                child: SingleChildScrollView(
                  padding: context.pagePadding.copyWith(bottom: context.scale(80)),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: context.lg),
                            child: ProfileAvatar(
                              imageUrl: details.photo,
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
                                items: ['Moderator', 'Institute Manager', 'Counselors', 'Teachers', 'Students', 'Librarian', 'Accountants', 'Staff'],
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
            },
          );
        },
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
            value: items.contains(controller.text) ? controller.text : null,
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
