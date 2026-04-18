import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eduphin/models/academic_data.dart';
import 'package:eduphin/models/class.dart';
import 'package:eduphin/models/new_student.dart';
import 'package:eduphin/models/section.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  List<Class> _classes = [];
  List<Section> _sectionsForSelectedClass = [];

  @override
  void initState() {
    super.initState();
    _academicDataFuture = _fetchAcademicData();
  }

  Future<AcademicData> _fetchAcademicData() async {
    try {
      final response = await ApiService.get('manager/classes');
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
        final responseBody = jsonDecode(response.body);
        throw Exception('Failed to load academic data: ${responseBody['message'] ?? 'Server error with status code ${response.statusCode}'}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching academic data: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> _pickFile(void Function(AppFile file) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // Crucial for Web to get bytes
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        onFilePicked(AppFile(
          name: file.name,
          path: kIsWeb ? null : file.path,
          bytes: file.bytes,
        ));
      });
    }
  }

  Future<void> _submitForm() async {
    final theme = Theme.of(context);
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill all required fields.'), backgroundColor: theme.colorScheme.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.addStudent(_newStudent);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Student added successfully!'), backgroundColor: theme.colorScheme.primary));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: theme.colorScheme.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Removed _addFileToRequest and _addStudent as they are moved to ApiService

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
            return Center(
                child: Text(
                    "Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}"));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionContainer(
                theme, "Student Details", _buildStudentDetailsFields(theme)),
            const SizedBox(height: 16),
            _buildSectionContainer(theme, "Academic Information",
                _buildAcademicFields(theme, academicData)),
            const SizedBox(height: 16),
            _buildSectionContainer(
                theme, "Personal Information", _buildPersonalInfoFields(theme)),
            const SizedBox(height: 16),
            _buildSectionContainer(
                theme, "Family Details", _buildFamilyDetailsFields(theme)),
            const SizedBox(height: 16),
            _buildSectionContainer(
                theme, "Basic Health Details", _buildHealthDetailsFields(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
      ThemeData theme, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleLarge),
          Divider(height: 24, color: theme.dividerColor),
          ...children,
        ]),
      ),
    );
  }

  List<Widget> _buildStudentDetailsFields(ThemeData theme) => [
        _buildTextField(theme, "First Name", (val) => _newStudent.firstName = val),
        _buildTextField(theme, "Middle Name", (val) => _newStudent.middleName = val,
            isOptional: true),
        _buildTextField(theme, "Last Name", (val) => _newStudent.lastName = val),
        _buildFilePicker(theme, "Profile Image", _newStudent.profileImage,
            (file) => setState(() => _newStudent.profileImage = file)),
        _buildTextField(
            theme, "Aadhaar Number", (val) => _newStudent.aadhaarNumber = val,
            keyboardType: TextInputType.number),
        _buildFilePicker(theme, "Aadhaar File", _newStudent.aadhaarFile,
            (file) => setState(() => _newStudent.aadhaarFile = file)),
        _buildFilePicker(theme, "10th Marksheet", _newStudent.marksheet10,
            (file) => setState(() => _newStudent.marksheet10 = file)),
        _buildFilePicker(
            theme, "12th Marksheet", _newStudent.marksheet12, (file) => setState(() => _newStudent.marksheet12 = file),
            isOptional: true),
        _buildFilePicker(
            theme,
            "Transfer Certificate",
            _newStudent.transferCertificate,
            (file) => setState(() => _newStudent.transferCertificate = file)),
        _buildFilePicker(theme, "ID Proof", _newStudent.idProof,
            (file) => setState(() => _newStudent.idProof = file)),
        _buildTextField(theme, "Roll No", (val) => _newStudent.rollNo = val),
        _buildTextField(
            theme, "Registration No", (val) => _newStudent.registrationNo = val),
      ];

  List<Widget> _buildAcademicFields(ThemeData theme, AcademicData data) => [
        _buildClassDropdown(theme, "Class", _newStudent.classId, _classes, (val) {
          setState(() {
            _newStudent.classId = val;
            _newStudent.sectionId = null;
            if (val != null) {
              _sectionsForSelectedClass =
                  _classes.firstWhere((c) => c.id == val).sections;
            } else {
              _sectionsForSelectedClass = [];
            }
          });
        }),
        _buildSectionDropdown(
            theme,
            "Section",
            _newStudent.sectionId,
            _sectionsForSelectedClass,
            (val) => setState(() => _newStudent.sectionId = val)),
        _buildDatePicker(theme, "Admission Date", _newStudent.admissionDate,
            (date) => setState(() => _newStudent.admissionDate = date), isOptional: true),
        _buildDropdown<String>(
            theme,
            "Lateral Admission",
            _newStudent.lateralAdmission,
            data.lateralAdmissionOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            (val) => setState(() => _newStudent.lateralAdmission = val)),
        _buildDropdown<String>(
            theme,
            "Admission Category",
            _newStudent.admissionCategory,
            data.admissionCategories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            (val) => setState(() => _newStudent.admissionCategory = val)),
        _buildDropdown<String>(
            theme,
            "Student Status",
            _newStudent.studentStatus,
            data.studentStatuses
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            (val) => setState(() => _newStudent.studentStatus = val)),
      ];

  List<Widget> _buildPersonalInfoFields(ThemeData theme) => [
        _buildDatePicker(theme, "Date of Birth", _newStudent.dob,
            (date) => setState(() => _newStudent.dob = date)),
        _buildDropdown<String>(
            theme,
            "Gender",
            _newStudent.gender,
            ['Male', 'Female', 'Other']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            (val) => setState(() => _newStudent.gender = val)),
        _buildDropdown<String>(
            theme,
            "Blood Group",
            _newStudent.bloodGroup,
            [
              'A+',
              'A-',
              'B+',
              'B-',
              'AB+',
              'AB-',
              'O+',
              'O-'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            (val) => setState(() => _newStudent.bloodGroup = val)),
        _buildTextField(
            theme, "Nationality", (val) => _newStudent.nationality = val),
        _buildTextField(theme, "Phone", (val) => _newStudent.phone = val,
            keyboardType: TextInputType.phone),
        _buildTextField(
            theme, "Alternate Phone", (val) => _newStudent.altPhone = val,
            keyboardType: TextInputType.phone, isOptional: true),
        _buildTextField(theme, "Email", (val) => _newStudent.email = val,
            keyboardType: TextInputType.emailAddress, validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
            return 'Enter a valid email';
          }
          return null;
        }),
        _buildTextField(
            theme, "Password", (val) => _newStudent.password = val,
            isPassword: true,
            validator: (val) => (val?.length ?? 0) < 6
                ? 'Password must be at least 6 characters'
                : null),
        _buildTextField(theme, "Address", (val) => _newStudent.address = val),
        _buildTextField(theme, "City", (val) => _newStudent.city = val),
        _buildTextField(theme, "District", (val) => _newStudent.district = val),
        _buildTextField(theme, "State", (val) => _newStudent.state = val),
        _buildTextField(theme, "Pincode", (val) => _newStudent.pincode = val,
            keyboardType: TextInputType.number),
      ];

  List<Widget> _buildFamilyDetailsFields(ThemeData theme) => [
        _buildTextField(
            theme, "Father's Name", (val) => _newStudent.fatherName = val),
        _buildTextField(theme, "Father's Occupation",
            (val) => _newStudent.fatherOccupation = val),
        _buildTextField(
            theme, "Father's Phone", (val) => _newStudent.fatherPhone = val,
            keyboardType: TextInputType.phone),
        _buildTextField(
            theme, "Mother's Name", (val) => _newStudent.motherName = val),
        _buildTextField(theme, "Mother's Occupation",
            (val) => _newStudent.motherOccupation = val),
        _buildTextField(
            theme, "Mother's Phone", (val) => _newStudent.motherPhone = val,
            keyboardType: TextInputType.phone),
        _buildTextField(
            theme, "Guardian's Name", (val) => _newStudent.guardianName = val,
            isOptional: true),
        _buildTextField(
            theme, "Guardian's Relation", (val) => _newStudent.guardianRelation = val,
            isOptional: true),
        _buildTextField(
            theme, "Guardian's Phone", (val) => _newStudent.guardianPhone = val,
            keyboardType: TextInputType.phone, isOptional: true),
      ];

  List<Widget> _buildHealthDetailsFields(ThemeData theme) => [
        _buildTextField(theme, "Allergies", (val) => _newStudent.allergies = val,
            isOptional: true),
        _buildTextField(theme, "Medications", (val) => _newStudent.medications = val,
            isOptional: true),
      ];

  Widget _buildTextField(ThemeData theme, String label, ValueChanged<String> onChanged,
      {String? Function(String?)? validator,
      bool isOptional = false,
      bool isPassword = false,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
              onChanged: onChanged,
              maxLines: maxLines,
              keyboardType: keyboardType,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: "Enter $label",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
              validator: isOptional
                  ? null
                  : (validator ?? (val) => val!.isEmpty ? '$label is required' : null)),
        ]));
  }

  Widget _buildDropdown<T>(ThemeData theme, String label, T? value,
      List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                  hintText: "--Select $label--",
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.dividerColor),
                  )),
              validator: (val) => val == null ? 'Please select a $label' : null),
        ]));
  }

  Widget _buildClassDropdown(ThemeData theme, String label, int? value,
      List<Class> items, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(
        theme,
        label,
        value,
        items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
        onChanged);
  }

  Widget _buildSectionDropdown(ThemeData theme, String label, int? value,
      List<Section> items, ValueChanged<int?> onChanged) {
    return _buildDropdown<int>(
        theme,
        label,
        value,
        items
            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
            .toList(),
        onChanged);
  }

  Widget _buildDatePicker(ThemeData theme, String label, DateTime? date,
      ValueChanged<DateTime?> onDateSelected, {bool isOptional = false}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          FormField<DateTime>(
              initialValue: date,
              validator: isOptional ? null : (val) => val == null ? 'Please select a date' : null,
              builder: (field) {
                return InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now());
                      if (picked != null) {
                        field.didChange(picked);
                        onDateSelected(picked);
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                            color: theme.inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: field.hasError ? theme.colorScheme.error : theme.dividerColor)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  date != null
                                      ? DateFormat('yyyy-MM-dd').format(date)
                                      : "Select Date",
                                  style: theme.textTheme.bodyLarge),
                              Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                            ])));
              }),
        ]));
  }

  Widget _buildFilePicker(ThemeData theme, String label, AppFile? file,
      ValueChanged<AppFile> onFilePicked,
      {bool isOptional = false}) {
    final controller = TextEditingController(text: file?.name ?? "No file chosen");
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              suffixIcon: IconButton(
                  icon: Icon(Icons.upload_file, color: theme.colorScheme.primary),
                  onPressed: () => _pickFile(onFilePicked)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
            ),
            validator:
                isOptional ? null : (val) => file == null ? 'Please choose a file' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > 300;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isWide
            ? Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0))),
                    child: Text("Cancel",
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onSurface)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0))),
                  icon: _isSubmitting ? Container() : const Icon(Icons.add),
                  label: _isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: theme.colorScheme.onPrimary,
                          ))
                      : Text("Add Student",
                          style: theme.textTheme.labelLarge
                              ?.copyWith(color: theme.colorScheme.onPrimary)),
                )),
              ])
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0))),
                    icon: _isSubmitting ? Container() : const Icon(Icons.add),
                    label: _isSubmitting
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: theme.colorScheme.onPrimary,
                            ))
                        : Text("Add Student",
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.onPrimary)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0))),
                    child: Text("Cancel",
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.onSurface)),
                  ),
                ],
              ),
      );
    });
  }
}
