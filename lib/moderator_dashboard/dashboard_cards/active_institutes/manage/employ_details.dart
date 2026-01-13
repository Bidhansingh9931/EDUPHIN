import 'package:flutter/material.dart';

import '../../../moderator_dashboard.dart';

class EmployeeDetailsPage extends StatefulWidget {const EmployeeDetailsPage({super.key});

@override
State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  final TextEditingController _fullNameController = TextEditingController(text: "Dr. Evelyn Reed");
  final TextEditingController _emailController = TextEditingController(text: "evelyn.reed@example.com");
  final TextEditingController _roleController = TextEditingController(text: "Teacher");
  final TextEditingController _genderController = TextEditingController(text: "Male");
  final TextEditingController _dateOfBirthController = TextEditingController(text: "01-07-2020");
  final TextEditingController _relationshipStatusController = TextEditingController(text: "Single");
  final TextEditingController _phoneNumberController = TextEditingController(text: "+91 1234567890");
  final TextEditingController _alternateNumberController = TextEditingController(text: "+91 0987654321");
  final TextEditingController _addressController = TextEditingController(text: "123, Tech Park Road");
  final TextEditingController _cityController = TextEditingController(text: "Bengaluru");
  final TextEditingController _stateController = TextEditingController(text: "Karnataka");
  final TextEditingController _pinCodeController = TextEditingController(text: "560001");
  final TextEditingController _positionController = TextEditingController(text: "Senior Teacher");
  final TextEditingController _employmentTypeController = TextEditingController(text: "Full-Time");
  final TextEditingController _joiningDateController = TextEditingController(text: "01-07-2020");
  final TextEditingController _experienceController = TextEditingController(text: "5");
  final TextEditingController _statusController = TextEditingController(text: "Active");
  final TextEditingController _referenceController = TextEditingController(text: "N/A");
  final TextEditingController _qualificationController = TextEditingController(text: "M.Sc. Physics");
  final TextEditingController _matriculationMarksController = TextEditingController(text: "92%");
  final TextEditingController _intermediateMarksController = TextEditingController(text: "88%");
  final TextEditingController _bankAccountNumberController = TextEditingController(text: "123456789012");
  final TextEditingController _ifscCodeController = TextEditingController(text: "BANK0001234");
  final TextEditingController _bankNameController = TextEditingController(text: "Example Bank");
  final TextEditingController _branchController = TextEditingController(text: "Tech Park Branch");
  final TextEditingController _emergencyContactNameController = TextEditingController(text: "John Doe");
  final TextEditingController _emergencyContactNumberController = TextEditingController(text: "+91 0987654321");


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Employee Details'),
            InkWell(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const ModeratorDashboardPage())),
                child: Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(context),
              const SizedBox(height: 20),
              _buildEditableInfoTile(context, "Full Name", _fullNameController),
              _buildEditableInfoTile(context, "Email", _emailController),
              const SizedBox(height: 20),
              _buildPersonalDetailsSection(context),
              const SizedBox(height: 20),
              _buildContactDetailsSection(context),
              const SizedBox(height: 20),
              _buildAddressDetailsSection(context),
              const SizedBox(height: 20),
              _buildProfessionalInformationSection(context),
              const SizedBox(height: 20),
              _buildEducationDetailsSection(context),
              const SizedBox(height: 20),
              _buildBankingDetailsSection(context),
              const SizedBox(height: 20),
              _buildEmergencyContactDetailsSection(context),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save changes functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Save Changes",
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              "assets/images/man_image.png",
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: theme.cardColor,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Handle image change
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoTile(BuildContext context, String title, TextEditingController controller, {bool readOnly = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: readOnly ? theme.dividerColor.withValues() : theme.cardColor,
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

  Widget _buildPersonalDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Personal Details", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Role", _roleController),
        _buildEditableInfoTile(context, "Gender", _genderController),
        _buildEditableInfoTile(context, "Date of Birth", _dateOfBirthController),
        _buildEditableInfoTile(context, "Relationship Status", _relationshipStatusController),
      ],
    );
  }

  Widget _buildContactDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact Details", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Phone Number", _phoneNumberController),
        _buildEditableInfoTile(context, "Alternate Number", _alternateNumberController),
      ],
    );
  }

  Widget _buildAddressDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Address Details", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Address", _addressController),
        _buildEditableInfoTile(context, "City", _cityController),
        _buildEditableInfoTile(context, "State", _stateController),
        _buildEditableInfoTile(context, "Pin code", _pinCodeController),
      ],
    );
  }

  Widget _buildProfessionalInformationSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Professional Information", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Position", _positionController),
        _buildEditableInfoTile(context, "Employment Type", _employmentTypeController),
        _buildEditableInfoTile(context, "Joining Date", _joiningDateController),
        _buildEditableInfoTile(context, "Experience (Years)", _experienceController),
        _buildEditableInfoTile(context, "Status", _statusController),
        _buildEditableInfoTile(context, "Reference", _referenceController),
      ],
    );
  }

  Widget _buildEducationDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Education & Documents", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Qualification", _qualificationController),
        _buildEditableInfoTile(context, "Matriculation Marks (%)", _matriculationMarksController),
        _buildEditableInfoTile(context, "Intermediate Marks (%)", _intermediateMarksController),
        _buildEditableInfoTile(context, "Matriculation Marksheet", TextEditingController(text: "View Document"), readOnly: true),
        _buildEditableInfoTile(context, "Intermediate Marksheet", TextEditingController(text: "View Document"), readOnly: true),
        _buildEditableInfoTile(context, "Resume", TextEditingController(text: "View Document"), readOnly: true),
      ],
    );
  }

  Widget _buildBankingDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Banking Details", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Bank Account Number", _bankAccountNumberController),
        _buildEditableInfoTile(context, "IFSC Code", _ifscCodeController),
        _buildEditableInfoTile(context, "Bank Name", _bankNameController),
        _buildEditableInfoTile(context, "Branch", _branchController),
      ],
    );
  }

  Widget _buildEmergencyContactDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Emergency Contact", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildEditableInfoTile(context, "Contact Name", _emergencyContactNameController),
        _buildEditableInfoTile(context, "Contact Number", _emergencyContactNumberController),
      ],
    );
  }
}
