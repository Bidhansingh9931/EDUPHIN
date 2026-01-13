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

  // In a real app, you'd likely use a JSON serialization library like json_serializable
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
    // Simulate fetching data for dropdowns from an API
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
    // Simulate sending data to an API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Submitting to API:");
    debugPrint(student.toString());
    // Simulate a successful API call
    return true;
  }
}

// ───────────────────────────────────────────────────────────
//                      ADD NEW STUDENT PAGE
// ───────────────────────────────────────────────────────────

class AddNewStudent extends StatefulWidget {
  const AddNewStudent({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockStudentApiService();
  late Future<AcademicData> _academicDataFuture;

  // Model to hold all form data
  final _newStudent = NewStudent();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _academicDataFuture = _apiService.fetchAcademicData();
  }

  Future<void> _submitForm() async {
    // In a real app, add form validation
    // if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.addStudent(_newStudent);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Student added successfully!' : 'Failed to add student.'),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FloatingActionButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: theme.colorScheme.onSurface),
                const SizedBox(width: 2),
                Text("Add Student", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Student', style: TextStyle(color: theme.colorScheme.onPrimary)),
            Text(
              "Fill out the form to add a new student to the institute.",
              style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: 12),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: FutureBuilder<AcademicData>(
        future: _academicDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final academicData = snapshot.data!;
            // Set default values from fetched data
            _newStudent.studentClass ??= academicData.classes.first;
            _newStudent.section ??= academicData.sections.first;
            _newStudent.lateralAdmission ??= academicData.lateralAdmissionOptions.first;
            _newStudent.admissionCategory ??= academicData.admissionCategories.first;
            _newStudent.studentStatus ??= academicData.studentStatuses.first;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 110, left: 16, right: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomStudentDetailsBox(student: _newStudent),
                      const SizedBox(height: 16),
                      CustomAcademicInformationBox(student: _newStudent, academicData: academicData, onUpdate: () => setState(() {})),
                      const SizedBox(height: 16),
                      CustomPersonalInformationBox(student: _newStudent, onUpdate: () => setState(() {})),
                      const SizedBox(height: 16),
                      CustomFamilyDetailsBox(student: _newStudent),
                      const SizedBox(height: 16),
                      CustomBasicHealthDetailsBox(student: _newStudent),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No academic data available'));
          }
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//                       REUSABLE WIDGETS
// ───────────────────────────────────────────────────────────

// -------- REUSABLE TEXT FIELD --------
class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: theme.hintColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
      ],
    );
  }
}

// -------- REUSABLE FILE PICKER FIELD --------
class CustomFilePickerField extends StatelessWidget {
  final String label;
  final String chosenFile;
  final VoidCallback onChooseFile;

  const CustomFilePickerField({
    super.key,
    required this.label,
    required this.chosenFile,
    required this.onChooseFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: chosenFile.isEmpty ? "No file chosen" : chosenFile,
            hintStyle: TextStyle(color: chosenFile.isEmpty ? theme.hintColor : Colors.white),
            prefixIcon: InkWell(
              onTap: onChooseFile,
              child: Container(
                width: 90,
                height: 55,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                  color: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    "Choose File",
                    style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
      ],
    );
  }
}


// -------- REUSABLE DROPDOWN --------
class DropDownBox extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}

// -------- FORM SECTIONS --------

class CustomStudentDetailsBox extends StatelessWidget {
  final NewStudent student;
  const CustomStudentDetailsBox({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 30, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text("Student Details", style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextFormField(label: "First Name", hintText: "Enter First Name", initialValue: student.firstName, onChanged: (val) => student.firstName = val),
            const SizedBox(height: 16),
            CustomTextFormField(label: "Middle Name", hintText: "Enter Middle Name", initialValue: student.middleName, onChanged: (val) => student.middleName = val),
            const SizedBox(height: 16),
            CustomTextFormField(label: "Last Name", hintText: "Enter Last Name", initialValue: student.lastName, onChanged: (val) => student.lastName = val),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "Profile Image", chosenFile: student.profileImage, onChooseFile: () {}), // Add file picking logic here
            const SizedBox(height: 16),
            CustomTextFormField(label: "Aadhaar Number", hintText: "Enter Aadhaar Number", initialValue: student.aadhaarNumber, onChanged: (val) => student.aadhaarNumber = val, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "Aadhaar File", chosenFile: student.aadhaarFile, onChooseFile: () {}),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "10th Marksheet", chosenFile: student.marksheet10, onChooseFile: () {}),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "12th Marksheet", chosenFile: student.marksheet12, onChooseFile: () {}),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "Transfer Certificate", chosenFile: student.transferCertificate, onChooseFile: () {}),
            const SizedBox(height: 16),
            CustomFilePickerField(label: "ID Proof", chosenFile: student.idProof, onChooseFile: () {}),
            const SizedBox(height: 16),
            CustomTextFormField(label: "Student Roll No", hintText: "Enter roll number", initialValue: student.rollNo, onChanged: (val) => student.rollNo = val),
            const SizedBox(height: 16),
            CustomTextFormField(label: "Registration No", hintText: "Enter registration number", initialValue: student.registrationNo, onChanged: (val) => student.registrationNo = val),
          ],
        ));
  }
}

class CustomAcademicInformationBox extends StatelessWidget {
  final NewStudent student;
  final AcademicData academicData;
  final VoidCallback onUpdate;

  const CustomAcademicInformationBox({super.key, required this.student, required this.academicData, required this.onUpdate});

  Future<void> _pickDate(BuildContext context, {required bool isAdmissionDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
        if (isAdmissionDate) {
          student.admissionDate = picked;
        } 
        onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Academic Information", style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text("Class", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.studentClass, items: academicData.classes, onChanged: (val) { student.studentClass = val; onUpdate(); }),
          const SizedBox(height: 16),
          Text("Section", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.section, items: academicData.sections, onChanged: (val) { student.section = val; onUpdate(); }),
          const SizedBox(height: 16),
          Text("Admission Date", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            onTap: () => _pickDate(context, isAdmissionDate: true),
            decoration: InputDecoration(
              hintText: student.admissionDate == null ? 'Select Date' : "${student.admissionDate!.toLocal()}".split(' ')[0],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              suffixIcon: const Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 16),
          Text("Lateral Admission", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.lateralAdmission, items: academicData.lateralAdmissionOptions, onChanged: (val) { student.lateralAdmission = val; onUpdate(); }),
          const SizedBox(height: 16),
          Text("Admission Category", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.admissionCategory, items: academicData.admissionCategories, onChanged: (val) { student.admissionCategory = val; onUpdate(); }),
          const SizedBox(height: 16),
          Text("Student Status", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.studentStatus, items: academicData.studentStatuses, onChanged: (val) { student.studentStatus = val; onUpdate(); }),
        ],
      ),
    );
  }
}

class CustomPersonalInformationBox extends StatelessWidget {
   final NewStudent student;
   final VoidCallback onUpdate;

  const CustomPersonalInformationBox({super.key, required this.student, required this.onUpdate});

  Future<void> _pickDate(BuildContext context, {required bool isAdmissionDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
        if (!isAdmissionDate) {
          student.dob = picked;
        }
        onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Personal Information", style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text("Date of Birth", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
           TextFormField(
            readOnly: true,
            onTap: () => _pickDate(context, isAdmissionDate: false),
            decoration: InputDecoration(
              hintText: student.dob == null ? 'Select Date' : "${student.dob!.toLocal()}".split(' ')[0],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              suffixIcon: const Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 16),
          Text("Gender", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.gender, items: const ['Male', 'Female', 'Other'], onChanged: (val) { student.gender = val; onUpdate(); }, hintText: 'Select Gender'),
           const SizedBox(height: 16),
          Text("Blood Group", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropDownBox(value: student.bloodGroup, items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], onChanged: (val) { student.bloodGroup = val; onUpdate(); }, hintText: 'Select Blood Group'),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Nationality", hintText: "Enter Nationality", initialValue: student.nationality, onChanged: (val) => student.nationality = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Phone Number", hintText: "Enter Phone Number", initialValue: student.phone, onChanged: (val) => student.phone = val, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Alternate Phone Number", hintText: "Enter Alternate Phone Number", initialValue: student.altPhone, onChanged: (val) => student.altPhone = val, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Email Id", hintText: "Enter Email Id", initialValue: student.email, onChanged: (val) => student.email = val, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Address", hintText: "Enter Address", initialValue: student.address, onChanged: (val) => student.address = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "City", hintText: "Enter City", initialValue: student.city, onChanged: (val) => student.city = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "District", hintText: "Enter District", initialValue: student.district, onChanged: (val) => student.district = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "State", hintText: "Enter State", initialValue: student.state, onChanged: (val) => student.state = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Pincode", hintText: "Enter Pincode", initialValue: student.pincode, onChanged: (val) => student.pincode = val, keyboardType: TextInputType.number),
        ],
      ),
    );
  }
}

class CustomFamilyDetailsBox extends StatelessWidget {
  final NewStudent student;
  const CustomFamilyDetailsBox({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.family_restroom, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Family Details", style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Father's Name", hintText: "Enter Father's Name", initialValue: student.fatherName, onChanged: (val) => student.fatherName = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Father's Occupation", hintText: "Enter Father's Occupation", initialValue: student.fatherOccupation, onChanged: (val) => student.fatherOccupation = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Father's Phone No", hintText: "Enter Father's Phone No", initialValue: student.fatherPhone, onChanged: (val) => student.fatherPhone = val, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Mother's Name", hintText: "Enter Mother's Name", initialValue: student.motherName, onChanged: (val) => student.motherName = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Mother's Occupation", hintText: "Enter Mother's Occupation", initialValue: student.motherOccupation, onChanged: (val) => student.motherOccupation = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Mother's Phone No", hintText: "Enter Mother's Phone No", initialValue: student.motherPhone, onChanged: (val) => student.motherPhone = val, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Guardian's Name", hintText: "Enter Guardian's Name", initialValue: student.guardianName, onChanged: (val) => student.guardianName = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Guardian's Relation", hintText: "Enter Guardian's Relation", initialValue: student.guardianRelation, onChanged: (val) => student.guardianRelation = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Guardian's Phone No", hintText: "Enter Guardian's Phone No", initialValue: student.guardianPhone, onChanged: (val) => student.guardianPhone = val, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }
}

class CustomBasicHealthDetailsBox extends StatelessWidget {
  final NewStudent student;
  const CustomBasicHealthDetailsBox({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.healing, size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text("Basic Health Details", style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Allergies", hintText: "Any Allergies", initialValue: student.allergies, onChanged: (val) => student.allergies = val),
          const SizedBox(height: 16),
          CustomTextFormField(label: "Medications", hintText: "Any Current Medications", initialValue: student.medications, onChanged: (val) => student.medications = val),
        ],
      ),
    );
  }
}
