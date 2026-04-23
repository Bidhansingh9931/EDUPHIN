import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/student/student_profile_model.dart';
import 'package:eduphin/student/faculty_remark.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eduphin/services/caching_service.dart';

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

  final Map<String, TextEditingController> _controllers = {};
  File? _selectedImage;
  Uint8List? _webImage;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchProfileData();
  }

  Future<void> _loadCachedData() async {
    final cached = await CacheService.getData('student_profile');
    if (cached != null && mounted) {
      setState(() {
        profileData = StudentProfileData.fromJson(cached as Map<String, dynamic>);
        _initializeControllers(profileData!);
        if (isLoading) isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final data = await ApiService.getStudentProfile();
      if (mounted) {
        setState(() {
          profileData = data;
          _initializeControllers(data);
          isLoading = false;
          errorMessage = null;
        });
        await CacheService.saveData('student_profile', data.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = profileData == null ? e.toString() : null;
          isLoading = false;
        });
      }
    }
  }


  void _initializeControllers(StudentProfileData data) {
    final s = data.student;
    final f = data.family;
    final h = data.health;

    _controllers['place_of_birth'] = TextEditingController(text: s?.placeOfBirth);
    _controllers['gender'] = TextEditingController(text: _capitalize(s?.gender));
    _controllers['mobile'] = TextEditingController(text: s?.mobile);
    _controllers['blood_group'] = TextEditingController(text: s?.bloodGroup?.toUpperCase());
    _controllers['nationality'] = TextEditingController(text: s?.nationality);
    _controllers['religion'] = TextEditingController(text: s?.religion);
    _controllers['caste'] = TextEditingController(text: s?.caste);
    _controllers['domicile_state'] = TextEditingController(text: s?.domicileState);
    _controllers['age'] = TextEditingController(text: s?.age?.toString());
    _controllers['dob'] = TextEditingController(text: s?.dob);

    _controllers['address_line1'] = TextEditingController(text: s?.addressLine1);
    _controllers['city'] = TextEditingController(text: s?.city);
    _controllers['state'] = TextEditingController(text: s?.state);
    _controllers['pincode'] = TextEditingController(text: s?.pincode);

    _controllers['father_mobile'] = TextEditingController(text: f?.fatherMobile);
    _controllers['mother_mobile'] = TextEditingController(text: f?.motherMobile);

    _controllers['height'] = TextEditingController(text: h?.height?.toString());
    _controllers['weight'] = TextEditingController(text: h?.weight?.toString());
    _controllers['blood_group_health'] = TextEditingController(text: h?.bloodGroup?.toUpperCase());
    
    _controllers['password'] = TextEditingController();
    _controllers['password_confirmation'] = TextEditingController();
  }

  String? _capitalize(String? s) {
    if (s == null || s.isEmpty) return null;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Future<void> _updateProfile() async {
    if (_controllers['password']!.text.isNotEmpty && _controllers['password']!.text != _controllers['password_confirmation']!.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isUpdating = true);
    try {
      final Map<String, String> data = {};
      _controllers.forEach((key, controller) {
        if (controller.text.isNotEmpty || (key != 'password' && key != 'password_confirmation')) {
          data[key] = controller.text;
        }
      });

      if (kIsWeb && _webImage != null) {
        await ApiService.updateStudentProfileFromBytes(data, _webImage!, _fileName);
      } else {
        await ApiService.updateStudentProfile(data, profileImage: _selectedImage);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _fetchProfileData();
        setState(() {
          _controllers['password']?.clear();
          _controllers['password_confirmation']?.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: context.theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _fileName = pickedFile.name;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
      ),
      body: LoadingWrapper(
        isLoading: isLoading,
        hasData: profileData != null,
        error: errorMessage,
        onRetry: _fetchProfileData,
        skeleton: const _ProfileSkeleton(),
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  if (profileData != null) ...[
                    _buildHeader(profileData!.student),
                    SizedBox(height: context.xl),
                    
                    // TABS
                    Container(
                      margin: EdgeInsets.only(bottom: context.lg),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        border: Border.all(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          _tabButton("PERSONAL", 0),
                          _tabButton("ADDRESS", 1),
                          _tabButton("FAMILY", 2),
                          _tabButton("HEALTH", 3),
                          _tabButton("SECURITY", 4),
                        ],
                      ),
                    ),

                    _buildTabContent(),
                    
                    SizedBox(height: context.xl),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleLogout,
                        icon: Icon(Icons.logout_rounded, color: context.theme.colorScheme.error, size: context.scale(20)),
                        label: Text("LOGOUT", style: TextStyle(color: context.theme.colorScheme.error, fontWeight: FontWeight.w800, fontSize: context.font(14))),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.theme.colorScheme.error),
                          padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                      ),
                    ),
                    SizedBox(height: context.xl * 2),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StudentDetail? student) {
    return Flex(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileAvatar(
          radius: context.scale(60),
          imageUrl: student?.profileImage != null ? ApiService.getStorageUrl(student!.profileImage) : null,
          localImage: _selectedImage,
          webImage: _webImage,
          onCameraTap: _pickImage,
        ),
        if (!context.isMobile) SizedBox(width: context.xl),
        if (context.isMobile) SizedBox(height: context.md),
        Column(
          crossAxisAlignment: context.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              "${student?.firstName ?? ""} ${student?.lastName ?? ""}",
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(24),
              ),
            ),
            Text(
              "Roll No: ${student?.studentRollNo ?? "N/A"}",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(16),
              ),
            ),
            Text(
              "Reg. No: ${student?.registrationNo ?? "N/A"}",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(14),
              ),
            ),
            SizedBox(height: context.md),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemarksPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.colorScheme.primary,
                foregroundColor: context.theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(30))),
              ),
              child: Text("VIEW REMARKS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        if (selectedTabIndex != 4)
        ProfileSection(
          title: _getTabTitle(),
          icon: _getTabIcon(),
          status: "Information",
          isReadOnly: true,
          children: [
            AdaptiveFieldRow(children: _getTabInfoFields()),
          ],
        ),
        ProfileSection(
          title: selectedTabIndex == 4 ? "Update Password" : "Update Information",
          icon: selectedTabIndex == 4 ? Icons.lock_outline_rounded : Icons.edit_outlined,
          status: "Editable",
          children: [
            ..._getTabUpdateFields(),
            SizedBox(height: context.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpdating ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: isUpdating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text("UPDATE PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
              ),
            )
          ],
        ),
      ],
    );
  }

  String _getTabTitle() {
    switch (selectedTabIndex) {
      case 0: return "Student Information";
      case 1: return "Address Details";
      case 2: return "Family Details";
      case 3: return "Health Details";
      case 4: return "Security Settings";
      default: return "";
    }
  }

  IconData _getTabIcon() {
    switch (selectedTabIndex) {
      case 0: return Icons.person_outline;
      case 1: return Icons.home_outlined;
      case 2: return Icons.family_restroom_outlined;
      case 3: return Icons.medical_services_outlined;
      case 4: return Icons.lock_outline_rounded;
      default: return Icons.info_outline;
    }
  }

  List<Widget> _getTabInfoFields() {
    final s = profileData?.student;
    final f = profileData?.family;
    final h = profileData?.health;

    switch (selectedTabIndex) {
      case 0:
        return [
          Column(children: [
            ProfileBadge(label: "Registration Number", value: s?.registrationNo ?? "N/A"),
            ProfileBadge(label: "Academic Session", value: s?.academicSession ?? "N/A"),
            ProfileBadge(label: "Admission Category", value: s?.admissionCategory ?? "N/A"),
          ]),
          Column(children: [
            ProfileBadge(label: "Date of Admission", value: s?.dateOfAdmission ?? "N/A"),
            ProfileBadge(label: "Academic Year", value: s?.academicYear ?? "N/A"),
            ProfileBadge(label: "Mentor Name", value: s?.mentorName ?? "N/A"),
          ]),
        ];
      case 1:
        return [
          ProfileBadge(label: "Current Address", value: "${s?.addressLine1 ?? "N/A"}, ${s?.city ?? ""}, ${s?.state ?? ""} - ${s?.pincode ?? ""}"),
        ];
      case 2:
        return [
          ProfileBadge(label: "Father's Name", value: f?.fatherName ?? "N/A"),
          ProfileBadge(label: "Mother's Name", value: f?.motherName ?? "N/A"),
        ];
      case 3:
        return [
          ProfileBadge(label: "Height", value: h?.height != null ? "${h!.height} cm" : "N/A"),
          ProfileBadge(label: "Weight", value: h?.weight != null ? "${h!.weight} kg" : "N/A"),
          ProfileBadge(label: "Blood Group", value: h?.bloodGroup ?? "N/A"),
        ];
      default: return [];
    }
  }

  List<Widget> _getTabUpdateFields() {
    switch (selectedTabIndex) {
      case 0:
        return [
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Place of Birth", controller: _controllers['place_of_birth']!),
            ProfileDropdown(
              label: "Gender",
              value: _controllers['gender']!.text.isEmpty ? null : _controllers['gender']!.text,
              items: const ["Male", "Female", "Other"],
              onChanged: (val) => setState(() => _controllers['gender']!.text = val!),
            ),
          ]),
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Mobile", controller: _controllers['mobile']!, keyboardType: TextInputType.phone),
            ProfileTextField(
              label: "Date of Birth",
              controller: _controllers['dob']!,
              readOnly: true,
              icon: Icons.calendar_today_rounded,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_controllers['dob']!.text) ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _controllers['dob']!.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
                }
              },
            ),
          ]),
          AdaptiveFieldRow(children: [
            ProfileDropdown(
              label: "Blood Group",
              value: _controllers['blood_group']!.text.isEmpty ? null : _controllers['blood_group']!.text,
              items: const ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
              onChanged: (val) => setState(() => _controllers['blood_group']!.text = val!),
            ),
            ProfileTextField(label: "Nationality", controller: _controllers['nationality']!),
          ]),
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Religion", controller: _controllers['religion']!),
            ProfileTextField(label: "Caste", controller: _controllers['caste']!),
          ]),
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Domicile State", controller: _controllers['domicile_state']!),
            ProfileTextField(label: "Age", controller: _controllers['age']!, keyboardType: TextInputType.number),
          ]),
        ];
      case 1:
        return [
          ProfileTextField(label: "Address Line 1", controller: _controllers['address_line1']!, maxLines: 2),
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "City", controller: _controllers['city']!),
            ProfileTextField(label: "State", controller: _controllers['state']!),
          ]),
          ProfileTextField(label: "Pincode", controller: _controllers['pincode']!, keyboardType: TextInputType.number),
        ];
      case 2:
        return [
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Father's Mobile", controller: _controllers['father_mobile']!, keyboardType: TextInputType.phone),
            ProfileTextField(label: "Mother's Mobile", controller: _controllers['mother_mobile']!, keyboardType: TextInputType.phone),
          ]),
        ];
      case 3:
        return [
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "Height (cm)", controller: _controllers['height']!, keyboardType: TextInputType.number),
            ProfileTextField(label: "Weight (kg)", controller: _controllers['weight']!, keyboardType: TextInputType.number),
          ]),
        ];
      case 4:
        return [
          AdaptiveFieldRow(children: [
            ProfileTextField(label: "New Password", controller: _controllers['password']!, isPassword: true),
            ProfileTextField(label: "Confirm Password", controller: _controllers['password_confirmation']!, isPassword: true),
          ]),
        ];
      default: return [];
    }
  }

  Widget _tabButton(String title, int index) {
    bool isSelected = selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTabIndex = index),
        borderRadius: BorderRadius.circular(context.scale(12)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scale(16)),
          decoration: BoxDecoration(
            color: isSelected ? context.theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(context.scale(12)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isSelected ? context.theme.colorScheme.onPrimary : context.theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: context.font(10)),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("LOGOUT", style: TextStyle(color: context.theme.colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: context.scale(120), height: context.scale(120), borderRadius: context.scale(60)),
                if (!context.isMobile) ...[
                  SizedBox(width: context.xl),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: context.scale(200), height: 30),
                      SizedBox(height: context.sm),
                      SkeletonBox(width: context.scale(150), height: 20),
                    ],
                  )
                ]
              ],
            ),
            SizedBox(height: context.xl),
            SkeletonBox(height: context.scale(50), borderRadius: context.scale(12)),
            SizedBox(height: context.xl),
            SkeletonBox(height: context.scale(200), borderRadius: context.scale(12)),
            SizedBox(height: context.xl),
            SkeletonBox(height: context.scale(300), borderRadius: context.scale(12)),
          ],
        ),
      ),
    );
  }
}
