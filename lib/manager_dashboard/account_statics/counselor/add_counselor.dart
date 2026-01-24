import 'dart:ui';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/manager_dashboard/manager_profile.dart';
import 'package:flutter/material.dart';

class AddCounselorPage extends StatefulWidget {
  const AddCounselorPage({super.key});

  @override
  State<AddCounselorPage> createState() => _AddCounselorPageState();
}

class _AddCounselorPageState extends State<AddCounselorPage> {
  // Your controllers are preserved with their initial data.
  final TextEditingController _fullNameController =
      TextEditingController(text: "Rajveer K.Malhotra");
  final TextEditingController _emailController =
      TextEditingController(text: "raj@iias.com");
  final TextEditingController _newPasswordController =
      TextEditingController(text: "");
  final TextEditingController _roleController =
      TextEditingController(text: "Teacher");
  final TextEditingController _genderController =
      TextEditingController(text: "Male");
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
  final TextEditingController _pinCodeController =
      TextEditingController(text: "560001");
  final TextEditingController _positionController =
      TextEditingController(text: "Senior Teacher");
  final TextEditingController _employmentTypeController =
      TextEditingController(text: "Full-Time");
  final TextEditingController _joiningDateController =
      TextEditingController(text: "01-07-2020");
  final TextEditingController _experienceController =
      TextEditingController(text: "5");
  final TextEditingController _statusController =
      TextEditingController(text: "Active");
  final TextEditingController _referenceController =
      TextEditingController(text: "N/A");
  final TextEditingController _qualificationController =
      TextEditingController(text: "M.Sc. Physics");
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

  @override
  void initState() {
    super.initState();
    // This function is ready for your API call to fetch data.
    _fetchCounselorData();
  }

  // TODO: Implement your API call here to fetch data.
  void _fetchCounselorData() {
    // When you have an API, you can fetch data and update the controllers here.
    // For example:
    // final counselorData = await myApi.getCounselor();
    // setState(() {
    //   _fullNameController.text = counselorData['fullName'];
    //   _emailController.text = counselorData['email'];
    //   // ... and so on for all other controllers.
    // });
  }

  // TODO: Implement your API call here to update the profile.
  void _updateProfile() {
    // When you have an API, you can send the updated data from the controllers.
    // For example:
    // final success = await myApi.updateCounselor({
    //   'fullName': _fullNameController.text,
    //   'email': _emailController.text,
    //   // ... and so on for all other fields.
    // });
    // if (success) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Profile updated successfully!')),
    //   );
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update button pressed! Add your API call.')),
    );
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
            heroTag: 'updateProfile',
            onPressed: _updateProfile,
            label: const Text("Update Profile"),
            icon: const Icon(Icons.save),
          ),
          FloatingActionButton.extended(
            heroTag: 'deleteCounselor',
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
            Text('Edit Counselor Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),),
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
              // The CustomProfileBox is now dynamic.
              CustomProfileBox(
                fullName: _fullNameController.text,
                position: _positionController.text,
              ),
              const SizedBox(height: 20),
              _buildEditableInfoTile(context, "Full Name", _fullNameController),
              _buildEditableInfoTile(context, "Email", _emailController),
              _buildEditableInfoTile(
                  context, "New Password", _newPasswordController),
              const Text("Leave blank to keep existing's password"),
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;
          if (isLargeScreen) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: children.map((child) => 
                SizedBox(
                  width: constraints.maxWidth / 2 - 8, // Adjust for spacing
                  child: child,
                )).toList(),
            );
          } else {
            return Column(children: children,);
          }
        })
      ],
    );
  }


  Widget _buildEditableInfoTile(
      BuildContext context, String title, TextEditingController controller,
      {bool readOnly = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: title,
          labelStyle:
              theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: readOnly
              ? theme.dividerColor.withOpacity(0.1)
              : theme.cardColor, 
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
  final String fullName;
  final String position;

  const CustomProfileBox(
      {super.key, required this.fullName, required this.position});

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
            Text(fullName,
                style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary)),
            Text(position,
                style: textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(180))),
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
                    style: textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF9FB4CC),
                        fontWeight: FontWeight.bold),
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
      return const DeleteCounselorDialog(
        counselorName: "Rajveer K.Malhotra",
      );
    },
  );
}

class DeleteCounselorDialog extends StatelessWidget {
  final String counselorName;

  const DeleteCounselorDialog({
    super.key,
    required this.counselorName,
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
                    "Delete Counselor",
                    style: textTheme.titleLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete this Counselor '''$counselorName'''? This action cannot be undone.",
                    textAlign: TextAlign.center,
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
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
