import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/student/student_profile_model.dart';
import 'package:eduphin/student/faculty_remark.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool isLoading = true;
  bool isUpdating = false;
  String? errorMessage;
  StudentProfileData? profileData;
  int selectedTabIndex = 0;

  // Controllers for update fields
  final Map<String, TextEditingController> _controllers = {};
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final data = await ApiService.getStudentProfile();
      if (mounted) {
        setState(() {
          profileData = data;
          _initializeControllers(data);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _initializeControllers(StudentProfileData data) {
    final s = data.student;
    final f = data.family;
    final h = data.health;

    // Personal
    _controllers['place_of_birth'] = TextEditingController(text: s?.placeOfBirth);
    _controllers['gender'] = TextEditingController(text: s?.gender);
    _controllers['mobile'] = TextEditingController(text: s?.mobile);
    _controllers['blood_group'] = TextEditingController(text: s?.bloodGroup);
    _controllers['nationality'] = TextEditingController(text: s?.nationality);
    _controllers['religion'] = TextEditingController(text: s?.religion);
    _controllers['caste'] = TextEditingController(text: s?.caste);
    _controllers['domicile_state'] = TextEditingController(text: s?.domicileState);
    _controllers['age'] = TextEditingController(text: s?.age?.toString());
    _controllers['dob'] = TextEditingController(text: s?.dob);

    // Address
    _controllers['address_line1'] = TextEditingController(text: s?.addressLine1);
    _controllers['city'] = TextEditingController(text: s?.city);
    _controllers['state'] = TextEditingController(text: s?.state);
    _controllers['pincode'] = TextEditingController(text: s?.pincode);

    // Family
    _controllers['father_mobile'] = TextEditingController(text: f?.fatherMobile);
    _controllers['mother_mobile'] = TextEditingController(text: f?.motherMobile);

    // Health
    _controllers['height'] = TextEditingController(text: h?.height?.toString());
    _controllers['weight'] = TextEditingController(text: h?.weight?.toString());
  }

  Future<void> _updateProfile() async {
    setState(() => isUpdating = true);
    try {
      final Map<String, String> data = {};
      _controllers.forEach((key, controller) {
        data[key] = controller.text;
      });

      await ApiService.updateStudentProfile(data, profileImage: _selectedImage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _fetchProfileData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    _fetchProfileData();
                  },
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        ),
      );
    }

    final student = profileData?.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Column(
          children: [
            // PROFILE CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.primary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (student?.profileImage != null
                                    ? NetworkImage("${ApiService.baseUrl}/storage/${student!.profileImage}")
                                    : null) as ImageProvider?,
                            child: _selectedImage == null && student?.profileImage == null
                                ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${student?.firstName ?? ""} ${student?.lastName ?? ""}",
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Roll No: ${student?.studentRollNo ?? "N/A"}",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                    Text(
                      "Reg. No: ${student?.registrationNo ?? "N/A"}",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RemarksPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        minimumSize: const Size(200, 45),
                      ),
                      child: const Text("CHECK REMARKS"),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TABS
            Row(
              children: [
                tabButton("PERSONAL", 0),
                tabButton("ADDRESS", 1),
                tabButton("FAMILY", 2),
                tabButton("HEALTH", 3),
              ],
            ),

            const SizedBox(height: 24),

            // Content based on tab
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getTabTitle(),
            const SizedBox(height: 24),
            ..._getTabInfoFields(),
            const Divider(height: 48),
            Text(
              "Update Information",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ..._getTabUpdateFields(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isUpdating ? null : _updateProfile,
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("UPDATE PROFILE"),
            )
          ],
        ),
      ),
    );
  }

  Widget _getTabTitle() {
    final theme = Theme.of(context);
    String title = "";
    switch (selectedTabIndex) {
      case 0: title = "Student Information"; break;
      case 1: title = "Address Details"; break;
      case 2: title = "Family Details"; break;
      case 3: title = "Health Details"; break;
    }
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  List<Widget> _getTabInfoFields() {
    final s = profileData?.student;
    final f = profileData?.family;
    final h = profileData?.health;

    switch (selectedTabIndex) {
      case 0:
        return [
          infoText("Full Name", "${s?.firstName ?? ""} ${s?.lastName ?? ""}"),
          infoText("Registration Number", s?.registrationNo ?? "N/A"),
          infoText("Student Roll Number", s?.studentRollNo ?? "N/A"),
          infoText("Academic Session", s?.academicSession ?? "N/A"),
          infoText("Date of Admission", s?.dateOfAdmission ?? "N/A"),
          infoText("Academic Year", s?.academicYear ?? "N/A"),
          infoText("Admission Category", s?.admissionCategory ?? "N/A"),
          infoText("Mentor Name", s?.mentorName ?? "N/A"),
        ];
      case 1:
        return [
          infoText("Address Line 1", s?.addressLine1 ?? "N/A"),
          infoText("City", s?.city ?? "N/A"),
          infoText("State", s?.state ?? "N/A"),
          infoText("Pincode", s?.pincode ?? "N/A"),
        ];
      case 2:
        return [
          infoText("Father's Name", f?.fatherName ?? "N/A"),
          infoText("Mother's Name", f?.motherName ?? "N/A"),
        ];
      case 3:
        return [
          infoText("Height", h?.height != null ? "${h!.height} cm" : "N/A"),
          infoText("Weight", h?.weight != null ? "${h!.weight} kg" : "N/A"),
          infoText("Blood Group", h?.bloodGroup ?? "N/A"),
        ];
      default: return [];
    }
  }

  List<Widget> _getTabUpdateFields() {
    switch (selectedTabIndex) {
      case 0:
        return [
          buildField("Place of Birth", _controllers['place_of_birth']!),
          buildField("Gender *", _controllers['gender']!),
          buildField("Mobile", _controllers['mobile']!),
          buildField("Date of Birth", _controllers['dob']!),
          buildField("Blood Group", _controllers['blood_group']!),
          buildField("Nationality", _controllers['nationality']!),
          buildField("Religion", _controllers['religion']!),
          buildField("Caste", _controllers['caste']!),
          buildField("Domicile State", _controllers['domicile_state']!),
          buildField("Age", _controllers['age']!),
        ];
      case 1:
        return [
          buildField("Address Line 1", _controllers['address_line1']!),
          buildField("City", _controllers['city']!),
          buildField("State", _controllers['state']!),
          buildField("Pincode", _controllers['pincode']!),
        ];
      case 2:
        return [
          buildField("Father's Mobile", _controllers['father_mobile']!),
          buildField("Mother's Mobile", _controllers['mother_mobile']!),
        ];
      case 3:
        return [
          buildField("Height", _controllers['height']!),
          buildField("Weight", _controllers['weight']!),
        ];
      default: return [];
    }
  }

  // ================= TAB BUTTON =================

  Widget tabButton(String title, int index) {
    final theme = Theme.of(context);
    bool isSelected = selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  // ================= INFO TEXT =================

  Widget infoText(String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          )
        ],
      ),
    );
  }

  // ================= INPUT FIELD =================

  Widget buildField(String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        ],
      ),
    );
  }
}
