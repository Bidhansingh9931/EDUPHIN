import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class Manager {
  String fullName = '';
  String email = '';
  String newPassword = '';
  String role = 'General Manager';
  String? gender;
  String dateOfBirth = '';
  String? relationshipStatus;
  String phoneNumber = '';
  String alternateNumber = '';
  String address = '';
  String city = '';
  String state = '';
  String pinCode = '';
  String position = '';
  String? employmentType;
  String joiningDate = '';
  String experience = ''; // in years
  String? status;
  String reference = '';
  String qualification = '';
  String matriculationMarks = '';
  String intermediateMarks = '';
  String? matriculationMarksheet;
  String? intermediateMarksheet;
  String? resume;
  String bankAccountNumber = '';
  String ifscCode = '';
  String bankName = '';
  String branch = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  String aadharNumber = ''; // Added for API
}

class ManagerFormData {
  final List<String> genders;
  final List<String> relationshipStatuses;
  final List<String> employmentTypes;
  final List<String> statuses;
  final Manager manager;

  ManagerFormData({
    required this.genders,
    required this.relationshipStatuses,
    required this.employmentTypes,
    required this.statuses,
    required this.manager,
  });
}

// ───────────────────────────────────────────────────────────
//                         API SERVICE
// ───────────────────────────────────────────────────────────

class ManagerApiService {
  Future<ManagerFormData> fetchManagerData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ManagerFormData(
      manager: Manager(), // Clean manager object
      genders: ['Male', 'Female', 'Other'],
      relationshipStatuses: ['Single', 'Married', 'Divorced', 'Widowed'],
      employmentTypes: ['full-time', 'part-time', 'internship', 'contract-based', 'other'],
      statuses: ['live', 'expired'],
    );
  }

  Future<bool> saveManager(Manager manager) async {
    final body = {
      'name': manager.fullName,
      'email': manager.email,
      'password': manager.newPassword,
      'role_id': '4', // Assuming '4' is for Manager
      'institute_id': '1', // This should be dynamically set
      'employment_type': manager.employmentType,
      'gender': manager.gender,
      'date_of_birth': manager.dateOfBirth,
      'aadhar_number': manager.aadharNumber,
      'address': manager.address,
      'city': manager.city,
      'state': manager.state,
      'pincode': manager.pinCode,
      'phone': manager.phoneNumber,
      'alternate_phone': manager.alternateNumber,
      'bank_account_number': manager.bankAccountNumber,
      'status': manager.status,
    };

    final response = await ApiService.post('manager/users', body);
    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData['status'] == true;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to save manager.');
    }
  }
}


// ───────────────────────────────────────────────────────────
//                       ADD MANAGER PAGE
// ───────────────────────────────────────────────────────────

class AddManagerPage extends StatefulWidget {
  const AddManagerPage({super.key});

  @override
  State<AddManagerPage> createState() => _AddManagerPageState();
}

class _AddManagerPageState extends State<AddManagerPage> {
  final _apiService = ManagerApiService();
  late Future<ManagerFormData> _formDataFuture;
  late Manager _manager;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formDataFuture = _apiService.fetchManagerData();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _apiService.saveManager(_manager);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Manager saved successfully!' : 'Failed to save manager.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Manager"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Save"),
            ),
          ),
        ],
      ),
      body: FutureBuilder<ManagerFormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final formData = snapshot.data!;
            _manager = formData.manager;
            return LayoutBuilder(
              builder: (context, constraints) {
                // Use a wider breakpoint for a 2-column layout to avoid cramping
                final isWide = constraints.maxWidth > 800;

                if (isWide) {
                  // Wide layout: Two scrollable columns
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _AddManagerProfileBox(),
                                const SizedBox(height: 20),
                                _buildEditableInfoTile(context, "Full Name", _manager.fullName, (val) => _manager.fullName = val),
                                _buildEditableInfoTile(context, "Email", _manager.email, (val) => _manager.email = val),
                                _buildEditableInfoTile(context, "New Password", _manager.newPassword, (val) => _manager.newPassword = val, isPassword: true),
                                Text("Leave blank to keep existing's password", style: theme.textTheme.bodySmall),
                                const SizedBox(height: 20),
                                _buildPersonalDetailsSection(context, _manager, formData),
                                const SizedBox(height: 20),
                                _buildContactDetailsSection(context, _manager),
                                const SizedBox(height: 20),
                                _buildAddressDetailsSection(context, _manager),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfessionalInformationSection(context, _manager, formData),
                                const SizedBox(height: 20),
                                _buildEducationDetailsSection(context, _manager),
                                const SizedBox(height: 20),
                                _buildBankingDetailsSection(context, _manager),
                                const SizedBox(height: 20),
                                _buildEmergencyContactDetailsSection(context, _manager),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Narrow layout: A single scrollable column
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _AddManagerProfileBox(),
                          const SizedBox(height: 20),
                          _buildEditableInfoTile(context, "Full Name", _manager.fullName, (val) => _manager.fullName = val),
                          _buildEditableInfoTile(context, "Email", _manager.email, (val) => _manager.email = val),
                          _buildEditableInfoTile(context, "New Password", _manager.newPassword, (val) => _manager.newPassword = val, isPassword: true),
                          Text("Leave blank to keep existing's password", style: theme.textTheme.bodySmall),
                          const SizedBox(height: 20),
                          _buildPersonalDetailsSection(context, _manager, formData),
                          const SizedBox(height: 20),
                          _buildContactDetailsSection(context, _manager),
                          const SizedBox(height: 20),
                          _buildAddressDetailsSection(context, _manager),
                          const SizedBox(height: 20),
                          _buildProfessionalInformationSection(context, _manager, formData),
                          const SizedBox(height: 20),
                          _buildEducationDetailsSection(context, _manager),
                          const SizedBox(height: 20),
                          _buildBankingDetailsSection(context, _manager),
                          const SizedBox(height: 20),
                          _buildEmergencyContactDetailsSection(context, _manager),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEditableInfoTile(BuildContext context, String title, String initialValue, ValueChanged<String> onChanged, {bool isPassword = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: isPassword,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
  
  Widget _buildDropdownInfoTile(BuildContext context, String title, String? value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor, width: 1.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(BuildContext context, String title, String value, ValueChanged<String> onDateChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(value) ?? DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (pickedDate != null) {
            onDateChanged(pickedDate.toIso8601String().split('T').first);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: title,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor, width: 1.0)),
          ),
          child: Text(value, style: theme.textTheme.bodyLarge),
        ),
      ),
    );
  }
  
  Widget _buildDocumentPickerTile(BuildContext context, String title, String? filePath, VoidCallback onPickFile) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onPickFile,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: title,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  filePath ?? 'No document selected',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(color: filePath == null ? theme.hintColor : null),
                ),
              ),
              IconButton(icon: Icon(Icons.upload_file, color: theme.primaryColor), onPressed: onPickFile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsSection(BuildContext context, Manager manager, ManagerFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Personal Details"),
        _buildEditableInfoTile(context, "Aadhaar Number", manager.aadharNumber, (val) => manager.aadharNumber = val),
        _buildEditableInfoTile(context, "Role", manager.role, (val) => manager.role = val),
        _buildDropdownInfoTile(context, "Gender", manager.gender, formData.genders, (val) => setState(() => manager.gender = val)),
        _buildDatePickerTile(context, "Date of Birth", manager.dateOfBirth, (val) => setState(() => manager.dateOfBirth = val)),
        _buildDropdownInfoTile(context, "Relationship Status", manager.relationshipStatus, formData.relationshipStatuses, (val) => setState(() => manager.relationshipStatus = val)),
      ],
    );
  }

  Widget _buildContactDetailsSection(BuildContext context, Manager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Contact Details"),
        _buildEditableInfoTile(context, "Phone Number", manager.phoneNumber, (val) => manager.phoneNumber = val),
        _buildEditableInfoTile(context, "Alternate Number", manager.alternateNumber, (val) => manager.alternateNumber = val),
      ],
    );
  }

  Widget _buildAddressDetailsSection(BuildContext context, Manager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Address Details"),
        _buildEditableInfoTile(context, "Address", manager.address, (val) => manager.address = val),
        _buildEditableInfoTile(context, "City", manager.city, (val) => manager.city = val),
        _buildEditableInfoTile(context, "State", manager.state, (val) => manager.state = val),
        _buildEditableInfoTile(context, "Pin Code", manager.pinCode, (val) => manager.pinCode = val),
      ],
    );
  }

  Widget _buildProfessionalInformationSection(BuildContext context, Manager manager, ManagerFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Professional Information"),
        _buildEditableInfoTile(context, "Position", manager.position, (val) => manager.position = val),
        _buildDropdownInfoTile(context, "Employment Type", manager.employmentType, formData.employmentTypes, (val) => setState(() => manager.employmentType = val)),
        _buildDatePickerTile(context, "Joining Date", manager.joiningDate, (val) => setState(() => manager.joiningDate = val)),
        _buildEditableInfoTile(context, "Experience (in years)", manager.experience, (val) => manager.experience = val),
        _buildDropdownInfoTile(context, "Status", manager.status, formData.statuses, (val) => setState(() => manager.status = val)),
        _buildEditableInfoTile(context, "Reference", manager.reference, (val) => manager.reference = val),
      ],
    );
  }

  Widget _buildEducationDetailsSection(BuildContext context, Manager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Education & Documents"),
        _buildEditableInfoTile(context, "Qualification", manager.qualification, (val) => manager.qualification = val),
        _buildEditableInfoTile(context, "Matriculation Marks (%)", manager.matriculationMarks, (val) => manager.matriculationMarks = val),
        _buildEditableInfoTile(context, "Intermediate Marks (%)", manager.intermediateMarks, (val) => manager.intermediateMarks = val),
        _buildDocumentPickerTile(context, "Matriculation Marksheet", manager.matriculationMarksheet, () {}),
        _buildDocumentPickerTile(context, "Intermediate Marksheet", manager.intermediateMarksheet, () {}),
        _buildDocumentPickerTile(context, "Resume", manager.resume, () {}),
      ],
    );
  }

  Widget _buildBankingDetailsSection(BuildContext context, Manager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Banking Details"),
        _buildEditableInfoTile(context, "Bank Account Number", manager.bankAccountNumber, (val) => manager.bankAccountNumber = val),
        _buildEditableInfoTile(context, "IFSC Code", manager.ifscCode, (val) => manager.ifscCode = val),
        _buildEditableInfoTile(context, "Bank Name", manager.bankName, (val) => manager.bankName = val),
        _buildEditableInfoTile(context, "Branch", manager.branch, (val) => manager.branch = val),
      ],
    );
  }

  Widget _buildEmergencyContactDetailsSection(BuildContext context, Manager manager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Emergency Contact"),
        _buildEditableInfoTile(context, "Contact Name", manager.emergencyContactName, (val) => manager.emergencyContactName = val),
        _buildEditableInfoTile(context, "Contact Number", manager.emergencyContactNumber, (val) => manager.emergencyContactNumber = val),
      ],
    );
  }
}

class _AddManagerProfileBox extends StatelessWidget {
  const _AddManagerProfileBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
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
              Icon(Icons.person_add, color: theme.colorScheme.onPrimary, size: 30),
              const SizedBox(width: 8),
              Text("New Manager Profile",
                  style: textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.add_a_photo, size: 40),
          ),
          const SizedBox(height: 8),
          Text("Add Profile Photo",
              style: textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
