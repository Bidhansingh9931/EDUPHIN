import 'dart:ui';

import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/manager_dashboard/manager_profile.dart';
import 'package:flutter/material.dart';

class AddAccountantPage extends StatefulWidget {
  const AddAccountantPage({super.key});

  @override
  State<AddAccountantPage> createState() => _AddAccountantPageState();
}

class _AddAccountantPageState extends State<AddAccountantPage> {
  bool _isLoading = false;
  final TextEditingController _fullNameController =
      TextEditingController(text: "Rajveer K.Malhotra");
  final TextEditingController _emailController =
      TextEditingController(text: "raj@iias.com");
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _roleController =
      TextEditingController(text: "Accountant");
  final TextEditingController _genderController = TextEditingController(text: "Male");
  final TextEditingController _dateOfBirthController =
      TextEditingController(text: "01-07-2020");
  final TextEditingController _relationshipStatusController =
      TextEditingController(text: "Single");
  final TextEditingController _phoneNumberController =
      TextEditingController(text: "+91 1234567890");
  final TextEditingController _alternateNumberController =
      TextEditingController(text: "+91 0987654321");
  final TextEditingController _addressController =
      TextEditingController(text: "123, Tech Park Road");
  final TextEditingController _cityController =
      TextEditingController(text: "Bengaluru");
  final TextEditingController _stateController =
      TextEditingController(text: "Karnataka");
  final TextEditingController _pinCodeController = TextEditingController(text: "560001");
  final TextEditingController _positionController =
      TextEditingController(text: "Senior Accountant");
  final TextEditingController _employmentTypeController =
      TextEditingController(text: "Full-Time");
  final TextEditingController _joiningDateController =
      TextEditingController(text: "01-07-2020");
  final TextEditingController _experienceController = TextEditingController(text: "5");
  final TextEditingController _statusController = TextEditingController(text: "Active");
  final TextEditingController _referenceController = TextEditingController(text: "N/A");
  final TextEditingController _qualificationController =
      TextEditingController(text: "B.Com");
  final TextEditingController _matriculationMarksController =
      TextEditingController(text: "92%");
  final TextEditingController _intermediateMarksController =
      TextEditingController(text: "88%");
  final TextEditingController _bankAccountNumberController =
      TextEditingController(text: "123456789012");
  final TextEditingController _ifscCodeController =
      TextEditingController(text: "BANK0001234");
  final TextEditingController _bankNameController =
      TextEditingController(text: "Example Bank");
  final TextEditingController _branchController =
      TextEditingController(text: "Tech Park Branch");
  final TextEditingController _emergencyContactNameController =
      TextEditingController(text: "John Doe");
  final TextEditingController _emergencyContactNumberController =
      TextEditingController(text: "+91 0987654321");

  void _addAccountant() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to add accountant data.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    // Here you can collect data from controllers and send to your API
    final accountantData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'role': _roleController.text,
      'gender': _genderController.text,
      'dateOfBirth': _dateOfBirthController.text,
      'relationshipStatus': _relationshipStatusController.text,
      'phoneNumber': _phoneNumberController.text,
      'alternateNumber': _alternateNumberController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pinCode': _pinCodeController.text,
      'position': _positionController.text,
      'employmentType': _employmentTypeController.text,
      'joiningDate': _joiningDateController.text,
      'experience': _experienceController.text,
      'status': _statusController.text,
      'reference': _referenceController.text,
      'qualification': _qualificationController.text,
      'matriculationMarks': _matriculationMarksController.text,
      'intermediateMarks': _intermediateMarksController.text,
      'bankAccountNumber': _bankAccountNumberController.text,
      'ifscCode': _ifscCodeController.text,
      'bankName': _bankNameController.text,
      'branch': _branchController.text,
      'emergencyContactName': _emergencyContactNameController.text,
      'emergencyContactNumber': _emergencyContactNumberController.text,
    };

    // For demonstration, we'll just print the data.
    print('Adding accountant with data: $accountantData');

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accountant added successfully!')),
      );
      // You might want to navigate away or clear the controllers after success.
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addAccountant',
            onPressed: _isLoading ? null : _addAccountant,
            label: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text("Add Accountant"),
            icon: const Icon(Icons.add),
          ),
          FloatingActionButton.extended(
            heroTag: 'deleteAccountant',
            onPressed: () => showDeleteDialog(context),
            backgroundColor: Colors.redAccent,
            label: const Text("Delete"),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Accountant',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildProfileImage(context),
              const CustomProfileBox(),
              const SizedBox(height: 20),
              _buildEditableInfoTile(context, "Full Name", _fullNameController),
              _buildEditableInfoTile(context, "Email", _emailController),
              _buildEditableInfoTile(context, "New Password", _newPasswordController),
              Text("Leave blank to keep existing's password", style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),
              _buildSection(context, "Personal Details", [
                _buildEditableInfoTile(context, "Role", _roleController),
                _buildEditableInfoTile(context, "Gender", _genderController),
                _buildEditableInfoTile(context, "Date of Birth", _dateOfBirthController),
                _buildEditableInfoTile(context, "Relationship Status", _relationshipStatusController),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Contact Details", [
                _buildEditableInfoTile(context, "Phone Number", _phoneNumberController),
                _buildEditableInfoTile(context, "Alternate Number", _alternateNumberController),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Address Details", [
                 _buildEditableInfoTile(context, "Address", _addressController),
                _buildEditableInfoTile(context, "City", _cityController),
                _buildEditableInfoTile(context, "State", _stateController),
                _buildEditableInfoTile(context, "Pin code", _pinCodeController),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Professional Information", [
                _buildEditableInfoTile(context, "Position", _positionController),
                _buildEditableInfoTile(context, "Employment Type", _employmentTypeController),
                _buildEditableInfoTile(context, "Joining Date", _joiningDateController),
                _buildEditableInfoTile(context, "Experience (Years)", _experienceController),
                _buildEditableInfoTile(context, "Status", _statusController),
                _buildEditableInfoTile(context, "Reference", _referenceController),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Education & Documents", [
                _buildEditableInfoTile(context, "Qualification", _qualificationController),
                _buildEditableInfoTile(context, "Matriculation Marks (%)", _matriculationMarksController),
                _buildEditableInfoTile(context, "Intermediate Marks (%)", _intermediateMarksController),
                _buildEditableInfoTile(context, "Matriculation Marksheet", TextEditingController(text: "View Document"), readOnly: true),
                _buildEditableInfoTile(context, "Intermediate Marksheet", TextEditingController(text: "View Document"), readOnly: true),
                _buildEditableInfoTile(context, "Resume", TextEditingController(text: "View Document"), readOnly: true),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Banking Details", [
                _buildEditableInfoTile(context, "Bank Account Number", _bankAccountNumberController),
                _buildEditableInfoTile(context, "IFSC Code", _ifscCodeController),
                _buildEditableInfoTile(context, "Bank Name", _bankNameController),
                _buildEditableInfoTile(context, "Branch", _branchController),
              ]),
              const SizedBox(height: 20),
              _buildSection(context, "Emergency Contact", [
                _buildEditableInfoTile(context, "Contact Name", _emergencyContactNameController),
                _buildEditableInfoTile(context, "Contact Number", _emergencyContactNumberController),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          if (isLargeScreen) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: children
                  .map((child) => SizedBox(
                        width: constraints.maxWidth / 2 - 8,
                        child: child,
                      ))
                  .toList(),
            );
          } else {
            return Column(
              children: children,
            );
          }
        })
      ],
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
          fillColor:
              readOnly ? theme.dividerColor.withOpacity(0.1) : theme.cardColor,
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
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ManagerProfilePage())),
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
                Text("Profile Overview",
                    style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary))
              ],
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/random_boy.jpg"),
            ),
            const SizedBox(height: 8),
            Text("Rajeev K.Malhotra",
                style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary)),
            Text("Accountant",
                style: textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
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
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                      color: Color(0xFF9FB4CC),
                    ),
                  ),
                  Text(
                    "Update Profile Image",
                    style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF9FB4CC), fontWeight: FontWeight.bold),
                  ),
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
      return const DeleteAccountantDialog(
        accountantName: "Rajeev K.Malhotra",
      );
    },
  );
}

class DeleteAccountantDialog extends StatelessWidget {
  final String accountantName;

  const DeleteAccountantDialog({
    super.key,
    required this.accountantName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // 🔹 Center Card
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
                  Text(
                    "Delete Accountant",
                    style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete this Accountant '''$accountantName'''? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  // 🔴 Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5392A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // 🔥 delete logic here
                      },
                      child: Text(
                        "Yes, Delete",
                        style: textTheme.titleMedium,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
