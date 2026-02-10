import 'dart:convert';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/manager_dashboard/manager_profile.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddLibrarianPage extends StatefulWidget {
  const AddLibrarianPage({super.key});

  @override
  State<AddLibrarianPage> createState() => _AddLibrarianPageState();
}

class _AddLibrarianPageState extends State<AddLibrarianPage> {
  bool _isLoading = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _roleController =
      TextEditingController(text: "Librarian");
  String? _selectedGender;
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedRelationshipStatus;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _alternateNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  String? _selectedEmploymentType;
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  String? _selectedStatus;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _matriculationMarksController =
      TextEditingController();
  final TextEditingController _intermediateMarksController =
      TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactNumberController =
      TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  PlatformFile? _matriculationMarksheet;
  PlatformFile? _intermediateMarksheet;
  PlatformFile? _resume;

  Future<void> _pickFile(Function(PlatformFile) onFilePicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          onFilePicked(result.files.single);
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectJoiningDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addLibrarian() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'name': _fullNameController.text,
        'email': _emailController.text,
        'password': _newPasswordController.text,
        'role_id': '6', // Assuming 6 is for Librarian
        'institute_id': '1', // This should be dynamic based on the logged-in user
        'gender': _selectedGender ?? '',
        'dob': _dateOfBirthController.text,
        'marital_status': _selectedRelationshipStatus ?? '',
        'phone': _phoneNumberController.text,
        'alternate_phone': _alternateNumberController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pinCodeController.text,
        'position': _positionController.text,
        'employment_type': _selectedEmploymentType ?? '',
        'joining_date': _joiningDateController.text,
        'experience': _experienceController.text,
        'status': _selectedStatus ?? '',
        'reference': _referenceController.text,
        'qualification': _qualificationController.text,
        'matric_marks': _matriculationMarksController.text,
        'inter_marks': _intermediateMarksController.text,
        'account_no': _bankAccountNumberController.text,
        'ifsc_code': _ifscCodeController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchController.text,
        'emergency_contact_name': _emergencyContactNameController.text,
        'emergency_contact_phone': _emergencyContactNumberController.text,
        'aadhaar_no': _aadhaarController.text,
      };

      // To handle file uploads, you need to send a multipart request.
      // Your ApiService.post method sends JSON and cannot include files.
      // You'll need to update your ApiService to build and send a multipart request.

      final response = await ApiService.post('manager/users', body);

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  responseData['message'] ?? 'Librarian added successfully!')),
        );
        Navigator.pop(context, true); // Pop with success
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to add librarian.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
    final textTheme = theme.textTheme;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: FloatingActionButton(
                onPressed: _isLoading ? null : _addLibrarian,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onSurface),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Add Librarian",
                            style: textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FloatingActionButton(
                onPressed: () => showDeleteDialog(context),
                backgroundColor: Colors.redAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Delete",
                      style: textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Add Librarian', style: textTheme.titleLarge),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomProfileBox(),
                const SizedBox(height: 20),
                _buildEditableInfoTile(
                    context, "Full Name", _fullNameController),
                _buildEditableInfoTile(context, "Email", _emailController),
                _buildEditableInfoTile(
                    context, "New Password", _newPasswordController),
                const Text("Leave blank to keep existing's password"),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildSection(
                      context,
                      isWide,
                      "Personal Details",
                      [
                        _buildEditableInfoTile(context, "Role", _roleController,
                            readOnly: true),
                        _buildDropdownInfoTile(
                          context,
                          "Gender",
                          _selectedGender,
                          ['Male', 'Female', 'Other'],
                          (newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                        ),
                        _buildEditableInfoTile(
                          context,
                          "Date of Birth",
                          _dateOfBirthController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        _buildDropdownInfoTile(
                          context,
                          "Relationship Status",
                          _selectedRelationshipStatus,
                          ['Single', 'Married', 'Divorced', 'Widowed'],
                          (newValue) {
                            setState(() {
                              _selectedRelationshipStatus = newValue;
                            });
                          },
                        ),
                        _buildEditableInfoTile(
                            context, "Aadhaar Number", _aadhaarController),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Contact Details",
                      [
                        _buildEditableInfoTile(
                            context, "Phone Number", _phoneNumberController),
                        _buildEditableInfoTile(context, "Alternate Number",
                            _alternateNumberController),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Address Details",
                      [
                        _buildEditableInfoTile(
                            context, "Address", _addressController),
                        _buildEditableInfoTile(
                            context, "City", _cityController),
                        _buildEditableInfoTile(
                            context, "State", _stateController),
                        _buildEditableInfoTile(
                            context, "Pin code", _pinCodeController),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Professional Information",
                      [
                        _buildEditableInfoTile(
                            context, "Position", _positionController),
                        _buildDropdownInfoTile(
                          context,
                          "Employment Type",
                          _selectedEmploymentType,
                          ['Full-time', 'Part-time', 'Contract'],
                          (newValue) {
                            setState(() {
                              _selectedEmploymentType = newValue;
                            });
                          },
                        ),
                        _buildEditableInfoTile(
                          context,
                          "Joining Date",
                          _joiningDateController,
                          readOnly: true,
                          onTap: () => _selectJoiningDate(context),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        _buildEditableInfoTile(context, "Experience (Years)",
                            _experienceController),
                        _buildDropdownInfoTile(
                          context,
                          "Status",
                          _selectedStatus,
                          ['Active', 'Inactive', 'On Leave'],
                          (newValue) {
                            setState(() {
                              _selectedStatus = newValue;
                            });
                          },
                        ),
                        _buildEditableInfoTile(
                            context, "Reference", _referenceController),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Education & Documents",
                      [
                        _buildEditableInfoTile(
                            context, "Qualification", _qualificationController),
                        _buildEditableInfoTile(
                            context,
                            "Matriculation Marks (%)",
                            _matriculationMarksController),
                        _buildEditableInfoTile(context,
                            "Intermediate Marks (%)", _intermediateMarksController),
                        _buildFilePickerTile(
                          context,
                          "Matriculation Marksheet",
                          _matriculationMarksheet,
                          () => _pickFile((file) => _matriculationMarksheet = file),
                        ),
                        _buildFilePickerTile(
                          context,
                          "Intermediate Marksheet",
                          _intermediateMarksheet,
                          () => _pickFile((file) => _intermediateMarksheet = file),
                        ),
                        _buildFilePickerTile(
                          context,
                          "Resume",
                          _resume,
                          () => _pickFile((file) => _resume = file),
                        ),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Banking Details",
                      [
                        _buildEditableInfoTile(context, "Bank Account Number",
                            _bankAccountNumberController),
                        _buildEditableInfoTile(
                            context, "IFSC Code", _ifscCodeController),
                        _buildEditableInfoTile(
                            context, "Bank Name", _bankNameController),
                        _buildEditableInfoTile(
                            context, "Branch", _branchController),
                      ],
                    ),
                    _buildSection(
                      context,
                      isWide,
                      "Emergency Contact",
                      [
                        _buildEditableInfoTile(context, "Contact Name",
                            _emergencyContactNameController),
                        _buildEditableInfoTile(context, "Contact Number",
                            _emergencyContactNumberController),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDropdownInfoTile(
    BuildContext context,
    String title,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: title,
          labelStyle:
              theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerTile(
      BuildContext context, String title, PlatformFile? file, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: title,
            labelStyle:
                theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  file?.name ?? 'Select Document',
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.attach_file),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, bool isWide, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final containerWidth =
        isWide ? (MediaQuery.of(context).size.width / 2) - 26 : double.infinity;

    return SizedBox(
      width: containerWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableInfoTile(
    BuildContext context,
    String title,
    TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, Widget? suffixIcon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          labelText: title,
          labelStyle:
              theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor:
              readOnly ? theme.dividerColor.withAlpha(35) : theme.cardColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class CustomProfileBox extends StatelessWidget {
  const CustomProfileBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ManagerProfilePage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person,
                    color: theme.colorScheme.onPrimary, size: 30),
                const SizedBox(width: 8),
                Text("Profile Overview",
                    style: textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/random_boy.jpg"),
            ),
            const SizedBox(height: 8),
            Text(
              "Rajeev K.Malhotra",
              style: textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onPrimary),
            ),
            Text("Librarian",
                style: textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onPrimary)),
          ],
        ),
      ),
    );
  }
}

// Dummy function to avoid error, you should have your own implementation
void showDeleteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              // Perform the delete action here
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
