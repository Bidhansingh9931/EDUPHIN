import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eduphin/models/academic_data.dart';
import 'package:eduphin/models/class.dart';
import 'package:eduphin/models/new_student.dart';
import 'package:eduphin/models/section.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

// ───────────────────────────────────────────────────────────
//                         UI WIDGET
// ───────────────────────────────────────────────────────────

class AddNewStudentPage extends StatefulWidget {
  const AddNewStudentPage({super.key});

  @override
  State<AddNewStudentPage> createState() => _AddNewStudentPageState();
}

class _AddNewStudentPageState extends State<AddNewStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late Future<AcademicData> _academicDataFuture;

  final _newStudent = NewStudent();
  bool _isSubmitting = false;

  // State for dynamic dropdowns
  List<Class> _classes = [];
  List<Section> _sectionsForSelectedClass = [];

  @override
  void initState() {
    super.initState();
    _academicDataFuture = _fetchAcademicData();
  }

  Future<AcademicData> _fetchAcademicData() async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in again.");
    }
    final url = Uri.parse('${ApiService.baseUrl}/manager/classes');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == true) {
          List<dynamic> classData = responseBody['data'];
          List<Class> classes = classData.map((data) => Class.fromJson(data)).toList();
          return AcademicData(classes: classes);
        } else {
          throw Exception('Failed to load academic data: ${responseBody['message']}');
        }
      } else {
        throw Exception('Failed to load academic data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on SocketException {
      throw Exception('Could not connect to the server. Check your network connection.');
    } catch (e) {
      throw Exception('An error occurred while fetching academic data: ${e.toString()}');
    }
  }


  Future<void> _pickFile(void Function(String path) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        onFilePicked(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final responseData = await _addStudent(_newStudent);
      if (!mounted) return;
      final message = responseData['message'] ?? 'Student added successfully!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<Map<String, dynamic>> _addStudent(NewStudent student) async {
    final url = Uri.parse('${ApiService.baseUrl}/manager/students');
    final token = await ApiService.getToken();
    if (token == null) throw Exception("Authentication token not found.");

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'first_name': student.firstName,
        'student_roll_no': student.rollNo,
        'registration_no': student.registrationNo,
        'email': student.email,
        'password': student.password,
        'class_id': student.classId.toString(),
        'section_id': student.sectionId.toString(),
        'dob': DateFormat('yyyy-MM-dd').format(student.dob!),
        'gender': student.gender!,
        'middle_name': student.middleName,
        'last_name': student.lastName,
        'phone': student.phone,
        'alternate_phone': student.altPhone,
        'address': student.address,
        'city': student.city,
        'district': student.district,
        'state': student.state,
        'pincode': student.pincode,
        'blood_group': student.bloodGroup ?? '',
        'nationality': student.nationality,
        'admission_date': student.admissionDate != null ? DateFormat('yyyy-MM-dd').format(student.admissionDate!) : '',
        'lateral_admission': student.lateralAdmission ?? '',
        'admission_category': student.admissionCategory ?? '',
        'student_status': student.studentStatus ?? '',
        'aadhaar_no': student.aadhaarNumber,
        'father_name': student.fatherName,
        'father_occupation': student.fatherOccupation,
        'father_phone': student.fatherPhone,
        'mother_name': student.motherName,
        'mother_occupation': student.motherOccupation,
        'mother_phone': student.motherPhone,
        'guardian_name': student.guardianName,
        'guardian_relation': student.guardianRelation,
        'guardian_phone': student.guardianPhone,
        'allergies': student.allergies,
        'medications': student.medications,
      });

      // Add files if path is not empty
      if (student.profileImage.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('profile_image', student.profileImage));
      if (student.aadhaarFile.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('aadhar_file', student.aadhaarFile));
      if (student.marksheet10.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('doc_10th_marksheet', student.marksheet10));
      if (student.marksheet12.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('doc_12th_marksheet', student.marksheet12));
      if (student.transferCertificate.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('doc_transfer_certificate', student.transferCertificate));
      if (student.idProof.isNotEmpty) request.files.add(await http.MultipartFile.fromPath('doc_id_proof', student.idProof));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && responseBody['status'] == true) {
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to add student. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on SocketException {
      throw Exception('Could not connect to the server. Check your network connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Add New Student"), centerTitle: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(theme),
      body: FutureBuilder<AcademicData>(
        future: _academicDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}"));
          } else if (snapshot.hasData) {
            _classes = snapshot.data!.classes;
            return _buildForm(theme, snapshot.data!);
          } else {
            return const Center(child: Text("No academic data available."));
          }
        },
      ),
    );
  }

  Widget _buildForm(ThemeData theme, AcademicData academicData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Form(
        key: _formKey,
        child: Column( // Reverted to single column layout
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(ThemeData theme, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  // -- Field Groups --
  List<Widget> _buildStudentDetailsFields(ThemeData theme) => [
        _buildTextField(theme, "First Name", (val) => _newStudent.firstName = val),
        _buildTextField(theme, "Middle Name", (val) => _newStudent.middleName = val, isOptional: true),
        _buildTextField(theme, "Last Name", (val) => _newStudent.lastName = val),
        _buildFilePicker(theme, "Profile Image", _newStudent.profileImage, (path) => _newStudent.profileImage = path),
        _buildTextField(theme, "Aadhaar Number", (val) => _newStudent.aadhaarNumber = val, keyboardType: TextInputType.number),
        _buildFilePicker(theme, "Aadhaar File", _newStudent.aadhaarFile, (path) => _newStudent.aadhaarFile = path),
        _buildFilePicker(theme, "10th Marksheet", _newStudent.marksheet10, (path) => _newStudent.marksheet10 = path),
        _buildFilePicker(theme, "12th Marksheet", _newStudent.marksheet12, (path) => _newStudent.marksheet12 = path, isOptional: true),
        _buildFilePicker(theme, "Transfer Certificate", _newStudent.transferCertificate, (path) => _newStudent.transferCertificate = path),
        _buildFilePicker(theme, "ID Proof", _newStudent.idProof, (path) => _newStudent.idProof = path),
        _buildTextField(theme, "Roll No", (val) => _newStudent.rollNo = val),
        _buildTextField(theme, "Registration No", (val) => _newStudent.registrationNo = val),
      ];

  List<Widget> _buildAcademicFields(ThemeData theme, AcademicData data) => [
        _buildClassDropdown(theme, "Class", _newStudent.classId, _classes, (val) {
          setState(() {
            _newStudent.classId = val;
            _newStudent.sectionId = null; // Reset section
            if (val != null) {
              _sectionsForSelectedClass = _classes.firstWhere((c) => c.id == val).sections;
            } else {
              _sectionsForSelectedClass = [];
            }
          });
        }),
        _buildSectionDropdown(theme, "Section", _newStudent.sectionId, _sectionsForSelectedClass, (val) => setState(() => _newStudent.sectionId = val)),
        _buildDatePicker(theme, "Admission Date", _newStudent.admissionDate, (date) => setState(() => _newStudent.admissionDate = date)),
        _buildDropdown<String>(theme, "Lateral Admission", _newStudent.lateralAdmission, data.lateralAdmissionOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), (val) => setState(() => _newStudent.lateralAdmission = val)),
        _buildDropdown<String>(theme, "Admission Category", _newStudent.admissionCategory, data.admissionCategories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), (val) => setState(() => _newStudent.admissionCategory = val)),
        _buildDropdown<String>(theme, "Student Status", _newStudent.studentStatus, data.studentStatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), (val) => setState(() => _newStudent.studentStatus = val)),
      ];

  List<Widget> _buildPersonalInfoFields(ThemeData theme) => [
        _buildDatePicker(theme, "Date of Birth", _newStudent.dob, (date) => setState(() => _newStudent.dob = date)),
        _buildDropdown<String>(theme, "Gender", _newStudent.gender, ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), (val) => setState(() => _newStudent.gender = val)),
        _buildDropdown<String>(theme, "Blood Group", _newStudent.bloodGroup, ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), (val) => setState(() => _newStudent.bloodGroup = val)),
        _buildTextField(theme, "Nationality", (val) => _newStudent.nationality = val),
        _buildTextField(theme, "Phone", (val) => _newStudent.phone = val, keyboardType: TextInputType.phone),
        _buildTextField(theme, "Alternate Phone", (val) => _newStudent.altPhone = val, keyboardType: TextInputType.phone, isOptional: true),
        _buildTextField(theme, "Email", (val) => _newStudent.email = val, keyboardType: TextInputType.emailAddress, validator: (val) {
          if (val == null || val.isEmpty) return 'Email is required';
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
          return null;
        }),
        _buildTextField(theme, "Password", (val) => _newStudent.password = val, isPassword: true, validator: (val) => (val?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null),
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

  Widget _buildTextField(ThemeData theme, String label, ValueChanged<String> onChanged, {String? Function(String?)? validator, bool isOptional = false, bool isPassword = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
              onChanged: onChanged,
              maxLines: maxLines,
              keyboardType: keyboardType,
              obscureText: isPassword,
              decoration: InputDecoration(hintText: "Enter $label", filled: true, fillColor: theme.scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              validator: isOptional ? null : (validator ?? (val) => val!.isEmpty ? '$label is required' : null)),
        ]));
  }

  Widget _buildDropdown<T>(ThemeData theme, String label, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
              initialValue: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(hintText: "--Select $label--", filled: true, fillColor: theme.scaffoldBackgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              validator: (val) => val == null ? 'Please select a $label' : null),
        ]));
  }
  
  Widget _buildClassDropdown(ThemeData theme, String label, int? value, List<Class> items, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged);
  }

  Widget _buildSectionDropdown(ThemeData theme, String label, int? value, List<Section> items, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.sectionName))).toList(), onChanged);
  }

  Widget _buildDatePicker(ThemeData theme, String label, DateTime? date, ValueChanged<DateTime> onDateSelected) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10), border: field.hasError ? Border.all(color: theme.colorScheme.error) : null),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select Date", style: theme.textTheme.bodyLarge),
                          const Icon(Icons.calendar_month),
                        ])));
              }),
        ]));
  }

  Widget _buildFilePicker(ThemeData theme, String label, String filePath, ValueChanged<String> onFilePicked, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            key: Key(filePath), // Update key to rebuild on change
            initialValue: filePath.isEmpty ? "No file chosen" : path.basename(filePath),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              suffixIcon: IconButton(icon: const Icon(Icons.upload_file), onPressed: () => _pickFile(onFilePicked)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: isOptional ? null : (val) => filePath.isEmpty ? 'Please choose a file' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(children: [
        Expanded(
            child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
          child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
          icon: _isSubmitting ? Container() : const Icon(Icons.add),
          label: _isSubmitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white))) : Text("Add Student", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        )),
      ]),
    );
  }
}
