import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:intl/intl.dart';
import '../../../../login_logout/ui_helper.dart';
import '../../../moderator_dashboard.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  String selectedGender = "Male";
  String? selectedRole;
  String? selectedEmploymentType;
  String? selectedRelationshipStatus;
  DateTime? selectedDate;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final alternatePhoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();
  final positionController = TextEditingController();
  final experienceController = TextEditingController();
  final statusController = TextEditingController();
  final referenceController = TextEditingController();
  final qualificationController = TextEditingController();
  final matriculationController = TextEditingController();
  final intermediateController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyContactNumberController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Employee',
            ),
            InkWell(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModeratorDashboardPage())),
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
            children: [
              _buildProfileImage(context),
              const SizedBox(height: 10),
              UiHelper.customTextField(context, fullNameController, "Full Name",
                  Icons.person_outline_sharp, false),
              UiHelper.customTextField(context, emailController, "Email",
                  Icons.email_outlined, false),
              TextButton(
                  onPressed: () {},
                  child: const Text("Change Password")),
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
              const SizedBox(height: 20),
              _buildUpdateAccountButtonSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              "assets/images/girl_image.webp",
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Details",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDropdown(
            context: context,
            title: "Select Role",
            value: selectedRole,
            hint: "Assign a Role",
            items: ["Teacher", "Student", "Staff", "Accountant"],
            onChanged: (value) {
              setState(() {
                selectedRole = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            context: context,
            title: "Select Gender",
            value: selectedGender,
            items: ["Male", "Female", "Other"],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedGender = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text("Date of Birth",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDatePickerField(context),
          const SizedBox(height: 16),
          _buildDropdown(
            context: context,
            title: "Relationship Status",
            value: selectedRelationshipStatus,
            hint: "Select Relationship Status",
            items: ["Single", "Married", "Couple"],
            onChanged: (value) {
              setState(() {
                selectedRelationshipStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Contact Details",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Phone Number",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, phoneController, "+91 1234567890",
              Icons.phone_android, false),
          Text("Alternate Number",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, alternatePhoneController,
              "Alternate Number", Icons.phone, false),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Address Details",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Address",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, addressController, "123, Tech Park Road",
              Icons.location_on_outlined, false),
          Text("City",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, cityController, "Bengaluru", Icons.location_city, false),
          Text("State",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, stateController, "Karnataka", Icons.location_history, false),
          Text("Pin code",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, pinController, "560001", Icons.pin, false),
        ],
      ),
    );
  }

  Widget _buildProfessionalInformationSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Professional Information",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text("Position",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, positionController, "Senior Teacher",
              Icons.school_outlined, false),
          const SizedBox(height: 16),
          _buildDropdown(
            context: context,
            title: "Employment Type",
            value: selectedEmploymentType,
            hint: "Select Employment Type",
            items: ["Full-Time", "Part-Time", "Contractual", "Freelance"],
            onChanged: (value) {
              setState(() {
                selectedEmploymentType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Text("Joining Date",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDatePickerField(context),
          const SizedBox(height: 16),
          Text("Experience (Years)",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, experienceController, "e.g., 5", Icons.work_history, false),
          const SizedBox(height: 16),
          Text("Status",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, statusController, "e.g., Active", Icons.toggle_on_outlined, false),
          const SizedBox(height: 16),
          Text("Reference (Optional)",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(
              context, referenceController, "Add a reference", Icons.room_preferences, false),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        picker.DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(1950, 1, 1),
          maxTime: DateTime.now(),
          onConfirm: (date) {
            setState(() {
              selectedDate = date;
            });
          },
          currentTime: selectedDate ?? DateTime.now(),
          locale: picker.LocaleType.en,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? 'Select joining date'
                  : DateFormat('yyyy-MM-dd').format(selectedDate!),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: selectedDate == null ? theme.hintColor : null,
              ),
            ),
            Icon(Icons.calendar_today, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Education & Documents",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Qualification",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, qualificationController, "M.Sc. Physics",
              Icons.school_sharp, false),
          Text("Matriculation Marks (%)",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, matriculationController,
              "92", Icons.percent_sharp, false),
          Text("Intermediate Marks (%)",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, intermediateController,
              "88", Icons.percent_sharp, false),
          const SizedBox(height: 8),
          UiHelper.customButton(context, () {}, "Upload Matriculation Marksheet"),
          const SizedBox(height: 8),
          UiHelper.customButton(context, (){}, "Upload Intermediate Marksheet"),
          const SizedBox(height: 8),
          UiHelper.customButton(context, (){}, "Upload Resume"),

        ],
      ),
    );
  }
  Widget _buildBankingDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Banking Details",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Bank Account Number",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, accountNumberController, "123456789012",
              Icons.account_balance_wallet_outlined,false),
          Text("IFSC Code",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, ifscCodeController,
              "BANK0001234", Icons.code, false),
          Text("Bank Name",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, bankNameController,
              "Example Bank", Icons.account_balance, false),
          Text("Branch",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, branchController,
              "Tech Park Branch", Icons.account_balance_outlined, false),
        ],
      ),
    );
  }
  Widget _buildEmergencyContactDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Emergency Contact",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Contact Name",
              style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, emergencyContactNameController, "John Doe",
              Icons.person_outline_sharp, false),
          Text("Contact Number",
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          UiHelper.customTextField(context, emergencyContactNumberController,
              "+91 0987654321", Icons.phone, false),
        ],
      ),
    );
  }

  Widget _buildUpdateAccountButtonSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(onPressed: (){}, child: Text("cancel",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),))),
          Container(
              height: 50,
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(onPressed: (){}, child: Text("Add Employee",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)))),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String title,
    required String? value,
    String? hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: hint != null ? Text(hint, style: TextStyle(color: theme.hintColor)) : null,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
              style: theme.textTheme.bodyLarge,
              dropdownColor: theme.cardColor,
            ),
          ),
        ),
      ],
    );
  }
}
