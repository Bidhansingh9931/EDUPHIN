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
  final TextEditingController _fullNameController = TextEditingController(text: "Rajveer K.Malhotra");
  final TextEditingController _emailController = TextEditingController(text: "raj@iias.com");
  final TextEditingController _newPasswordController = TextEditingController(text: "");
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: FloatingActionButton(onPressed: (){},child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add,color: theme.colorScheme.onSurface,),
                  const SizedBox(width: 2,),
                  Text("Add Student",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                ],
              ),),
            ),
            Spacer(),
            SizedBox(
                width: 150,
                height: 50,
                child: FloatingActionButton(onPressed: ()=>showDeleteDialog(context),
                  backgroundColor: Colors.redAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete,color: theme.colorScheme.onSurface,),
                      const SizedBox(width: 2,),
                      Text("Delete",style: TextStyle(color: theme.colorScheme.onSurface,fontSize: 20),),
                    ],
                  ),)),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Edit Manager Profile'),
            InkWell(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const ManagerDashboardPage())),
                child: Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildProfileImage(context),
              CustomProfileBox(),
              const SizedBox(height: 20),
              _buildEditableInfoTile(context, "Full Name", _fullNameController),
              _buildEditableInfoTile(context, "Email", _emailController),
              _buildEditableInfoTile(context, "New Password", _newPasswordController),
              Text("Leave blank to keep existing's password"),
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
            ],
          ),
        ),
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

class CustomProfileBox extends StatelessWidget {
  const CustomProfileBox({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ManagerProfilePage())),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.onPrimary))
              ],
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/random_boy.jpg"),
            ),
            const SizedBox(height: 8),
            Text("Rajeev K.Malhotra",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.onPrimary)),
            Text("General Manager", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
            const SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF2A3F5F),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.camera_alt_outlined,size: 30,color: Color(0xFF9FB4CC),),
                  ),
                  Text("Update Profile Image",style: TextStyle(color: Color(0xFF9FB4CC),fontSize: 16,fontWeight: FontWeight.bold),),
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
    barrierColor: Color.fromRGBO(0, 0, 0, 0.6),
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
                  const Text(
                    "Delete Counselor",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Are you sure you want to delete this Accountant "
                        "$accountantName? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
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
                      child: const Text(
                        "Yes, Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚪ Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF374151),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
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