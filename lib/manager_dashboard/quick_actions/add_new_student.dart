import 'dart:async';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewStudent {
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String profileImage = '';
  String aadhaarNumber = '';
  String aadhaarFile = '';
  String marksheet10 = '';
  String marksheet12 = '';
  String transferCertificate = '';
  String idProof = '';
  String rollNo = '';
  String registrationNo = '';
  String? studentClass;
  String? section;
  DateTime? admissionDate;
  String? lateralAdmission;
  String? admissionCategory;
  String? studentStatus;
  DateTime? dob;
  String? gender;
  String? bloodGroup;
  String nationality = '';
  String phone = '';
  String altPhone = '';
  String email = '';
  String address = '';
  String city = '';
  String district = '';
  String state = '';
  String pincode = '';
  String fatherName = '';
  String fatherOccupation = '';
  String fatherPhone = '';
  String motherName = '';
  String motherOccupation = '';
  String motherPhone = '';
  String guardianName = '';
  String guardianRelation = '';
  String guardianPhone = '';
  String allergies = '';
  String medications = '';

  @override
  String toString() {
    return 'NewStudent{\n'
        '  firstName: $firstName, \n'
        '  lastName: $lastName, \n'
        '  rollNo: $rollNo, \n'
        '  studentClass: $studentClass, \n'
        '  section: $section, \n'
        '  email: $email, \n'
        '  ... (all other fields) ...\n'
        '}';
  }
}

class AcademicData {
  final List<String> classes;
  final List<String> sections;
  final List<String> lateralAdmissionOptions;
  final List<String> admissionCategories;
  final List<String> studentStatuses;

  AcademicData({
    required this.classes,
    required this.sections,
    required this.lateralAdmissionOptions,
    required this.admissionCategories,
    required this.studentStatuses,
  });
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockStudentApiService {
  Future<AcademicData> fetchAcademicData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AcademicData(
      classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'],
      sections: ['A', 'B', 'C'],
      lateralAdmissionOptions: ['No', 'Yes'],
      admissionCategories: ['General', 'OBC', 'SC/ST', 'Other'],
      studentStatuses: ['Active', 'Inactive', 'On Hold'],
    );
  }

  Future<bool> addStudent(NewStudent student) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Submitting to API:");
    debugPrint(student.toString());
    return true;
  }
}

// ───────────────────────────────────────────────────────────
//                      ADD NEW STUDENT PAGE
// ───────────────────────────────────────────────────────────

class AddNewStudentPage extends StatefulWidget {
  const AddNewStudentPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewStudentPageState();
}

class _AddNewStudentPageState extends State<AddNewStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockStudentApiService();
  late Future<AcademicData> _academicDataFuture;
  final _newStudent = NewStudent();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _academicDataFuture = _apiService.fetchAcademicData();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await _apiService.addStudent(_newStudent);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Student added successfully!' : 'Failed to add student.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Student"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<AcademicData>(
        future: _academicDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return _buildActionButtons(theme);
        },
      ),
      body: FutureBuilder<AcademicData>(
        future: _academicDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return LayoutBuilder(builder: (context, constraints) {
              final academicData = snapshot.data!;
              return constraints.maxWidth > 800
                  ? _buildWideLayout(theme, academicData)
                  : _buildNarrowLayout(theme, academicData);
            });
          } else {
            return const Center(child: Text('No academic data available'));
          }
        },
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme, AcademicData academicData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSectionContainer(theme, "Student Details", _buildStudentDetailsFields(theme)),
            const SizedBox(height: 16),
            _buildSectionContainer(theme, "Academic Information", _buildAcademicFields(theme, academicData)),
            const SizedBox(height: 16),
            _buildSectionContainer(theme, "Personal Information", _buildPersonalInfoFields(theme)),
            const SizedBox(height: 16),
             _buildSectionContainer(theme, "Family Details", _buildFamilyDetailsFields(theme)),
            const SizedBox(height: 16),
            _buildSectionContainer(theme, "Basic Health Details", _buildHealthDetailsFields(theme)),
            const SizedBox(height: 80), // For FAB
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(ThemeData theme, AcademicData academicData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildSectionContainer(theme, "Student Details", _buildStudentDetailsFields(theme)),
                  const SizedBox(height: 16),
                  _buildSectionContainer(theme, "Personal Information", _buildPersonalInfoFields(theme)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildSectionContainer(theme, "Academic Information", _buildAcademicFields(theme, academicData)),
                   const SizedBox(height: 16),
                  _buildSectionContainer(theme, "Family Details", _buildFamilyDetailsFields(theme)),
                  const SizedBox(height: 16),
                  _buildSectionContainer(theme, "Basic Health Details", _buildHealthDetailsFields(theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable container for form sections
  Widget _buildSectionContainer(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  // -- Field Groups --
  List<Widget> _buildStudentDetailsFields(ThemeData theme) => [
    _buildTextField(theme, "First Name", (val) => _newStudent.firstName = val, validator: (val) => val!.isEmpty ? 'Required' : null),
    _buildTextField(theme, "Middle Name", (val) => _newStudent.middleName = val, isOptional: true),
    _buildTextField(theme, "Last Name", (val) => _newStudent.lastName = val, validator: (val) => val!.isEmpty ? 'Required' : null),
    _buildFilePicker(theme, "Profile Image", _newStudent.profileImage, () {}),
    _buildTextField(theme, "Aadhaar Number", (val) => _newStudent.aadhaarNumber = val, keyboardType: TextInputType.number),
    _buildFilePicker(theme, "Aadhaar File", _newStudent.aadhaarFile, () {}),
    _buildFilePicker(theme, "10th Marksheet", _newStudent.marksheet10, () {}),
    _buildFilePicker(theme, "12th Marksheet", _newStudent.marksheet12, () {}, isOptional: true),
    _buildFilePicker(theme, "Transfer Certificate", _newStudent.transferCertificate, () {}),
    _buildFilePicker(theme, "ID Proof", _newStudent.idProof, () {}),
    _buildTextField(theme, "Roll No", (val) => _newStudent.rollNo = val, validator: (val) => val!.isEmpty ? 'Required' : null),
    _buildTextField(theme, "Registration No", (val) => _newStudent.registrationNo = val, validator: (val) => val!.isEmpty ? 'Required' : null),
  ];

  List<Widget> _buildAcademicFields(ThemeData theme, AcademicData data) => [
    _buildDropdown(theme, "Class", _newStudent.studentClass, data.classes, (val) => setState(() => _newStudent.studentClass = val)),
    _buildDropdown(theme, "Section", _newStudent.section, data.sections, (val) => setState(() => _newStudent.section = val)),
    _buildDatePicker(theme, "Admission Date", _newStudent.admissionDate, (date) => setState(() => _newStudent.admissionDate = date)),
    _buildDropdown(theme, "Lateral Admission", _newStudent.lateralAdmission, data.lateralAdmissionOptions, (val) => setState(() => _newStudent.lateralAdmission = val)),
    _buildDropdown(theme, "Admission Category", _newStudent.admissionCategory, data.admissionCategories, (val) => setState(() => _newStudent.admissionCategory = val)),
    _buildDropdown(theme, "Student Status", _newStudent.studentStatus, data.studentStatuses, (val) => setState(() => _newStudent.studentStatus = val)),
  ];

  List<Widget> _buildPersonalInfoFields(ThemeData theme) => [
    _buildDatePicker(theme, "Date of Birth", _newStudent.dob, (date) => setState(() => _newStudent.dob = date)),
    _buildDropdown(theme, "Gender", _newStudent.gender, ['Male', 'Female', 'Other'], (val) => setState(() => _newStudent.gender = val)),
    _buildDropdown(theme, "Blood Group", _newStudent.bloodGroup, ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], (val) => setState(() => _newStudent.bloodGroup = val)),
    _buildTextField(theme, "Nationality", (val) => _newStudent.nationality = val),
    _buildTextField(theme, "Phone", (val) => _newStudent.phone = val, keyboardType: TextInputType.phone),
    _buildTextField(theme, "Alternate Phone", (val) => _newStudent.altPhone = val, keyboardType: TextInputType.phone, isOptional: true),
    _buildTextField(theme, "Email", (val) => _newStudent.email = val, keyboardType: TextInputType.emailAddress),
    _buildTextField(theme, "Address", (val) => _newStudent.address = val),
    _buildTextField(theme, "City", (val) => _newStudent.city = val),
    _buildTextField(theme, "District", (val) => _newStudent.district = val),
    _buildTextField(theme, "State", (val) => _newStudent.state = val),
    _buildTextField(theme, "Pincode", (val) => _newStudent.pincode = val, keyboardType: TextInputType.number),
  ];

   List<Widget> _buildFamilyDetailsFields(ThemeData theme) => [
    _buildTextField(theme, "Father's Name", (val) => _newStudent.fatherName = val),
    _buildTextField(theme, "Father's Occupation", (val) => _newStudent.fatherOccupation = val),
    _buildTextField(theme, "Father's Phone", (val) => _newStudent.fatherPhone = val, keyboardType: TextInputType.phone),
    _buildTextField(theme, "Mother's Name", (val) => _newStudent.motherName = val),
    _buildTextField(theme, "Mother's Occupation", (val) => _newStudent.motherOccupation = val),
    _buildTextField(theme, "Mother's Phone", (val) => _newStudent.motherPhone = val, keyboardType: TextInputType.phone),
    _buildTextField(theme, "Guardian's Name", (val) => _newStudent.guardianName = val, isOptional: true),
    _buildTextField(theme, "Guardian's Relation", (val) => _newStudent.guardianRelation = val, isOptional: true),
    _buildTextField(theme, "Guardian's Phone", (val) => _newStudent.guardianPhone = val, keyboardType: TextInputType.phone, isOptional: true),
  ];

  List<Widget> _buildHealthDetailsFields(ThemeData theme) => [
    _buildTextField(theme, "Allergies", (val) => _newStudent.allergies = val, isOptional: true),
    _buildTextField(theme, "Medications", (val) => _newStudent.medications = val, isOptional: true),
  ];


  // -- Reusable Form Field Widgets --

  Widget _buildTextField(ThemeData theme, String label, ValueChanged<String> onChanged, {String? Function(String?)? validator, bool isOptional = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: "Enter $label",
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: isOptional ? null : (validator ?? (val) => val!.isEmpty ? '$label is required' : null),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: "--Select $label--",
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: (val) => val == null ? 'Please select a $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme, String label, DateTime? date, ValueChanged<DateTime> onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          FormField<DateTime>(
            initialValue: date,
            validator: (val) => val == null ? 'Please select a date' : null,
            builder: (field) {
              return InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
                  if (picked != null) onDateSelected(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: field.hasError ? Border.all(color: theme.colorScheme.error) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(date != null ? "${date.toLocal()}".split(' ')[0] : "Select Date", style: theme.textTheme.bodyLarge),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(ThemeData theme, String label, String fileName, VoidCallback onPick, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: fileName.isEmpty ? "No file chosen" : fileName,
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              prefixIcon: ElevatedButton(onPressed: onPick, child: const Text("Choose File")),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
             validator: isOptional ? null : (val) => fileName.isEmpty ? 'Please choose a file' : null,
          ),
        ],
      ),
    );
  }
  
    Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.dividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              icon: _isSubmitting ? Container() : const Icon(Icons.add),
              label: _isSubmitting
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Text("Add Student", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
