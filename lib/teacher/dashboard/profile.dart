import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<TeacherProfile> _profileFuture;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = ApiService.getTeacherProfile();
    _profileFuture.then((profile) {
      if (mounted) {
        setState(() {
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _genderController.text = profile.gender ?? '';
          _dobController.text = profile.dateOfBirth ?? '';
          _phoneController.text = profile.phone ?? '';
          _altPhoneController.text = profile.alternatePhone ?? '';
          _relationshipStatusController.text = profile.relationshipStatus ?? '';
          _addressController.text = profile.address ?? '';
          _cityController.text = profile.city ?? '';
          _stateController.text = profile.state ?? '';
          _pincodeController.text = profile.pincode ?? '';
          _accountNumberController.text = profile.bankAccountNumber ?? '';
          _ifscController.text = profile.ifscCode ?? '';
          _bankNameController.text = profile.bankName ?? '';
          _branchController.text = profile.branch ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _relationshipStatusController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<TeacherProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profile = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),
                  _buildProfileSection(
                    title: "Personal Information",
                    status: "Editable",
                    children: [
                      _rowLabel("GENDER *"),
                      buildDropdown(context, ['Male', 'Female', 'Other'], _genderController.text, (v) => setState(() => _genderController.text = v!)),
                      _rowLabel("Date of Birth *"),
                      buildDateField(context, _dobController, "12-08-1985"),
                      _rowLabel("Phone *"),
                      buildTextField(context, _phoneController, "Enter Phone"),
                      _rowLabel("Alternate Phone"),
                      buildTextField(context, _altPhoneController, "Enter Alt Phone"),
                      _rowLabel("Relationship Status"),
                      buildTextField(context, _relationshipStatusController, "Married"),
                      _rowLabel("Update Photo"),
                      _buildFilePicker("Choose File", "No File Chosen"),
                    ],
                  ),
                  _buildProfileSection(
                    title: "Address Information",
                    status: "Update",
                    children: [
                      _rowLabel("Address *"),
                      buildTextField(context, _addressController, "Enter Address"),
                      _rowLabel("City *"),
                      buildTextField(context, _cityController, "Lucknow"),
                      _rowLabel("State *"),
                      buildTextField(context, _stateController, "Uttar Pradesh"),
                      _rowLabel("Pincode *"),
                      buildTextField(context, _pincodeController, "226017"),
                    ],
                  ),
                  _buildProfileSection(
                    title: "Banking Information",
                    status: "Editable",
                    children: [
                      _rowLabel("Bank Account Number"),
                      buildTextField(context, _accountNumberController, "Enter Account Number"),
                      _rowLabel("IFSC Code"),
                      buildTextField(context, _ifscController, "Enter IFSC"),
                      _rowLabel("Bank Name"),
                      buildTextField(context, _bankNameController, "Enter Bank Name"),
                      _rowLabel("Branch Name"),
                      buildTextField(context, _branchController, "Enter Branch"),
                    ],
                  ),
                  _buildProfileSection(
                    title: "Security Settings",
                    status: "Editable",
                    children: [
                      _rowLabel("New Password"),
                      buildTextField(context, _passwordController, "Enter new password", isPassword: true),
                    ],
                  ),
                  _buildProfileSection(
                    title: "Employment Details",
                    status: "Read only",
                    isReadOnly: true,
                    children: [
                      _readOnlyRow("POSITION", profile.position),
                      _readOnlyRow("EMPLOYMENT TYPE", profile.employmentType),
                      _readOnlyRow("JOINING DATE", profile.joiningDate),
                      _readOnlyRow("EXPERIENCE", profile.experience),
                      _readOnlyRow("STATUS", "LIVE", isBadge: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildActionButton(context, "SAVE CHANGES", () {}),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(TeacherProfile profile) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 12),
        Text(profile.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(profile.position ?? "Teacher", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        Text(profile.email, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }

  Widget _buildProfileSection({required String title, required String status, required List<Widget> children, bool isReadOnly = false}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isReadOnly ? Icons.work_outline : Icons.person_outline, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReadOnly ? Colors.grey.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isReadOnly ? Colors.grey : theme.colorScheme.primary)),
                )
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _rowLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8),
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _readOnlyRow(String label, String? value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(value ?? '', style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          else
            buildTextField(context, TextEditingController(text: value), "", prefixIcon: null), // Simulated read-only field style
        ],
      ),
    );
  }

  Widget _buildFilePicker(String btnText, String fileName) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: const BorderRadius.horizontal(left: Radius.circular(7))),
            child: Text(btnText, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(fileName, style: const TextStyle(fontSize: 12, color: Colors.grey)))),
        ],
      ),
    );
  }
}
