import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../manager_profile.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class Manager {
  String fullName = 'Rajeev K.Malhotra';
  String email = 'rajeev.malhotra@example.com';
  String newPassword = '';
  String role = 'General Manager';
  String? gender = 'Male';
  String dateOfBirth = '1985-05-20';
  String? relationshipStatus = 'Married';
  String phoneNumber = '+91 98765 43210';
  String alternateNumber = '';
  String address = '123, ABC Lane, XYZ Colony';
  String city = 'New Delhi';
  String state = 'Delhi';
  String pinCode = '110001';
  String position = 'General Manager';
  String? employmentType = 'Full-time';
  String joiningDate = '2010-08-15';
  String experience = '14'; // in years
  String? status = 'Active';
  String reference = 'N/A';
  String qualification = 'MBA in Hospital Management';
  String matriculationMarks = '85';
  String intermediateMarks = '82';
  String? matriculationMarksheet;
  String? intermediateMarksheet;
  String? resume;
  String bankAccountNumber = '123456789012';
  String ifscCode = 'ABCD0001234';
  String bankName = 'Global Bank';
  String branch = 'Central Delhi';
  String emergencyContactName = 'Sunita Malhotra';
  String emergencyContactNumber = '+91 98765 43211';
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
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockManagerApiService {
  Future<ManagerFormData> fetchManagerData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ManagerFormData(
      manager: Manager(), // Pre-populated data
      genders: ['Male', 'Female', 'Other'],
      relationshipStatuses: ['Single', 'Married', 'Divorced', 'Widowed'],
      employmentTypes: ['Full-time', 'Part-time', 'Contract'],
      statuses: ['Active', 'On-leave', 'Terminated'],
    );
  }

  Future<bool> saveManager(Manager manager) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you'd send this data to your backend
    print('Saving manager data for: ${manager.fullName}');
    return true; // Simulate success
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
  final _apiService = MockManagerApiService();
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

    final success = await _apiService.saveManager(_manager);

    setState(() {
      _isSubmitting = false;
    });

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDeleteDialog(context),
          ),
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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16,16,16,50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProfileBox(manager: _manager),
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
        _buildEditableInfoTile(context, "Pin code", manager.pinCode, (val) => manager.pinCode = val),
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
        _buildEditableInfoTile(context, "Experience (Years)", manager.experience, (val) => manager.experience = val),
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
        _buildDocumentPickerTile(context, "Matriculation Marksheet", manager.matriculationMarksheet, () => setState(() => manager.matriculationMarksheet = 'matric_marksheet.pdf')),
        _buildDocumentPickerTile(context, "Intermediate Marksheet", manager.intermediateMarksheet, () => setState(() => manager.intermediateMarksheet = 'inter_marksheet.pdf')),
        _buildDocumentPickerTile(context, "Resume", manager.resume, () => setState(() => manager.resume = 'resume_${manager.fullName.replaceAll(' ', '_')}.pdf')),
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

class CustomProfileBox extends StatelessWidget {
  final Manager manager;
  const CustomProfileBox({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManagerProfilePage())),
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
                Icon(Icons.person, color: theme.colorScheme.onPrimary, size: 30),
                const SizedBox(width: 8),
                Text("Profile Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.onPrimary))
              ],
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/random_boy.jpg"),
            ),
            const SizedBox(height: 8),
            Text(manager.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.onPrimary)),
            Text(manager.role, style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
            const SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF2A3F5F),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.camera_alt_outlined, size: 30, color: Color(0xFF9FB4CC)),
                  ),
                  const Text("Update Profile Image", style: TextStyle(color: Color(0xFF9FB4CC), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showDeleteDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return const DeleteManagerDialog(
        managerName: "Rajeev K.Malhotra",
      );
    },
  );
}

class DeleteManagerDialog extends StatelessWidget {
  final String managerName;

  const DeleteManagerDialog({
    super.key,
    required this.managerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Manager",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete this manager, $managerName? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Add actual delete logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Delete", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel", style: TextStyle(color: Colors.grey.shade400)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}