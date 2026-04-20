import 'dart:async';
import 'dart:typed_data';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/models/new_student.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class AddNewStudentPage extends StatefulWidget {
  final int classId;
  final int sectionId;

  const AddNewStudentPage({
    super.key,
    required this.classId,
    required this.sectionId,
  });

  @override
  State<AddNewStudentPage> createState() => _AddNewStudentPageState();
}

class _AddNewStudentPageState extends State<AddNewStudentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for all required fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _regNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _imageFileController = TextEditingController();
  final _aadhaarController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  Uint8List? _imageBytes;
  String? _imageName;

  AppFile? _aadhaarFile;
  AppFile? _marksheet10;
  AppFile? _marksheet12;
  AppFile? _tcFile;
  AppFile? _idProofFile;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _rollNoController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _imageFileController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
        _imageFileController.text = pickedFile.name;
      });
    }
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = AppFile(
        name: result.files.first.name,
        path: kIsWeb ? null : result.files.first.path,
        bytes: result.files.first.bytes,
      );
      setState(() {
        switch (type) {
          case 'aadhaar':
            _aadhaarFile = file;
            break;
          case '10th':
            _marksheet10 = file;
            break;
          case '12th':
            _marksheet12 = file;
            break;
          case 'tc':
            _tcFile = file;
            break;
          case 'id':
            _idProofFile = file;
            break;
        }
      });
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
     if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an image.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = NewStudent()
        ..firstName = _firstNameController.text
        ..middleName = _middleNameController.text
        ..lastName = _lastNameController.text
        ..phone = _phoneController.text
        ..address = _addressController.text
        ..rollNo = _rollNoController.text
        ..registrationNo = _regNoController.text
        ..aadhaarNumber = _aadhaarController.text
        ..email = _emailController.text
        ..password = _passwordController.text
        ..classId = widget.classId
        ..sectionId = widget.sectionId
        ..dob = _selectedDate
        ..gender = _selectedGender
        ..profileImage = AppFile(
          name: _imageName ?? 'profile.jpg',
          bytes: _imageBytes,
        )
        ..aadhaarFile = _aadhaarFile
        ..marksheet10 = _marksheet10
        ..marksheet12 = _marksheet12
        ..transferCertificate = _tcFile
        ..idProof = _idProofFile;

      await ApiService.addStudent(student);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an Email Address';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Student"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildTextField(_firstNameController, "First Name"),
                  _buildTextField(_middleNameController, "Middle Name (Optional)", isOptional: true),
                  _buildTextField(_lastNameController, "Last Name"),
                  _buildTextField(_phoneController, "Phone Number", keyboardType: TextInputType.phone),
                  _buildTextField(_rollNoController, "Roll Number", keyboardType: TextInputType.number),
                  _buildTextField(_regNoController, "Registration Number", keyboardType: TextInputType.number),
                  _buildTextField(_aadhaarController, "Aadhaar Number", keyboardType: TextInputType.number, validator: (value) {
                    if (value != null && value.isNotEmpty && value.length != 12) {
                      return 'Aadhaar must be 12 digits';
                    }
                    return null;
                  }),
                  _buildTextField(_emailController, "Email Address", keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                  _buildTextField(_passwordController, "Password", obscureText: true, validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  }),
                  _buildTextField(_addressController, "Address (Optional)", isOptional: true, maxLines: 3),
                  _buildDateField(context, "Date of Birth", _dobController),
                  _buildGenderDropdown(),
                  const SizedBox(height: 24),
                  Text("Documents", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildFilePickerItem("Aadhaar Card", _aadhaarFile, () => _pickDocument('aadhaar')),
                  _buildFilePickerItem("10th Marksheet", _marksheet10, () => _pickDocument('10th')),
                  _buildFilePickerItem("12th Marksheet", _marksheet12, () => _pickDocument('12th')),
                  _buildFilePickerItem("Transfer Certificate", _tcFile, () => _pickDocument('tc')),
                  _buildFilePickerItem("ID Proof", _idProofFile, () => _pickDocument('id')),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addStudent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : const Text("Add Student"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator, bool isOptional = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: isOptional ? null : (validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        hint: const Text('Select Gender'),
        decoration: InputDecoration(
          labelText: 'Gender',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: ['Male', 'Female', 'Other'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a gender' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
  final theme = Theme.of(context);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: TextFormField(
          controller: _imageFileController,
          readOnly: true,
          onTap: _pickImage,
          decoration: InputDecoration(
            labelText: 'Student Image',
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.attach_file),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an image';
            }
            return null;
          },
        ),
      ),
      const SizedBox(width: 10),
      Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                ),
              )
            : Icon(Icons.person, size: 30, color: theme.hintColor),
      ),
    ],
  );
}

  Widget _buildFilePickerItem(String label, AppFile? file, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      file?.name ?? "No file selected",
                      style: TextStyle(
                        fontSize: 14,
                        color: file != null ? theme.colorScheme.onSurface : theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(file != null ? Icons.check_circle : Icons.add_circle_outline, 
                   color: file != null ? Colors.green : theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
