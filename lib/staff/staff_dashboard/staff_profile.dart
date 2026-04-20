import 'package:eduphin/services/common_widgets.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import '../../login_logout/login.dart';
import 'staff_models.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  late Stream<UserDetail> _profileStream;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  UserDetail? _currentDetail;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileStream = ApiService.getStaffProfileStream();
  }

  void _updateControllers(UserDetail detail) {
    if (_currentDetail?.id == detail.id && _genderController.text.isNotEmpty) return;
    
    _currentDetail = detail;
    _genderController.text = detail.gender ?? '';
    _dobController.text = detail.dateOfBirth ?? '';
    _phoneController.text = detail.phone ?? '';
    _altPhoneController.text = detail.alternatePhone ?? '';
    _addressController.text = detail.address ?? '';
    _cityController.text = detail.city ?? '';
    _stateController.text = detail.state ?? '';
    _pincodeController.text = detail.pincode ?? '';
    _relationshipController.text = detail.relationshipStatus ?? 'Single';
    _bankNameController.text = detail.bankName ?? '';
    _accountNumberController.text = detail.bankAccountNumber ?? '';
    _ifscController.text = detail.ifscCode ?? '';
    _branchController.text = detail.branchName ?? '';
    _emergencyNameController.text = detail.emergencyContactName ?? '';
    _emergencyNumberController.text = detail.emergencyContactNumber ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
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
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      try {
        final Map<String, String> data = {
          'gender': _genderController.text,
          'date_of_birth': _dobController.text,
          'phone': _phoneController.text,
          'alternate_phone': _altPhoneController.text,
          'relationship_status': _relationshipController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
          'bank_account_number': _accountNumberController.text,
          'ifsc_code': _ifscController.text,
          'bank_name': _bankNameController.text,
          'branch_name': _branchController.text,
          'emergency_contact_name': _emergencyNameController.text,
          'emergency_contact_number': _emergencyNumberController.text,
        };

        if (_passwordController.text.isNotEmpty) {
          data['password'] = _passwordController.text;
          data['password_confirmation'] = _confirmPasswordController.text;
        }

        if (kIsWeb && _webImage != null) {
          await ApiService.updateStaffProfileFromBytes(data, _webImage!, _fileName);
        } else {
          await ApiService.updateStaffProfile(data, photo: _imageFile);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          _loadProfile();
          setState(() {
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Staff Profile", style: TextStyle(fontSize: context.font(20))),
      ),
      body: StreamBuilder<UserDetail>(
        stream: _profileStream,
        builder: (context, snapshot) {
          return LoadingWrapper<UserDetail>(
            snapshot: snapshot,
            onRetry: () => setState(() => _loadProfile()),
            skeleton: _buildSkeleton(context),
            builder: (detail) => _buildContent(context, detail),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          const Skeleton(height: 150, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 20, width: 150),
                const SizedBox(height: 16),
                const Skeleton(height: 200, width: double.infinity, borderRadius: 16),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserDetail detail) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateControllers(detail));
    
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context, detail),
                SizedBox(height: context.scale(32)),
                
                ProfileSection(
                  title: "Personal Details",
                  icon: Icons.person_outline_rounded,
                  status: "Editable",
                  children: [
                    ProfileTextField(
                      label: "Full Name",
                      controller: TextEditingController(text: detail.user?.name ?? ''),
                      enabled: false,
                    ),
                    AdaptiveFieldRow(children: [
                      ProfileDropdown(
                        label: "Gender *",
                        value: _genderController.text.isEmpty ? null : _genderController.text,
                        items: const ["Male", "Female", "Other"],
                        onChanged: (v) => setState(() => _genderController.text = v ?? ''),
                      ),
                      ProfileTextField(
                        label: "Date of Birth *",
                        controller: _dobController,
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dobController.text.isNotEmpty
                                ? DateTime.tryParse(_dobController.text) ?? DateTime.now()
                                : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _dobController.text = picked.toString().split(' ')[0]);
                          }
                        },
                      ),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Phone Number *", controller: _phoneController, icon: Icons.phone_android_rounded),
                      ProfileDropdown(
                        label: "Relationship Status",
                        value: _relationshipController.text.isEmpty ? "Single" : _relationshipController.text,
                        items: const ["Single", "Married", "Divorced", "Widowed"],
                        onChanged: (v) => setState(() => _relationshipController.text = v ?? 'Single'),
                      ),
                    ]),
                    ProfileTextField(label: "Alternate Phone", controller: _altPhoneController),
                  ],
                ),

                ProfileSection(
                  title: "Bank Details",
                  icon: Icons.account_balance_outlined,
                  status: "Editable",
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Bank Name", controller: _bankNameController),
                      ProfileTextField(label: "Account Number *", controller: _accountNumberController),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "IFSC Code", controller: _ifscController),
                      ProfileTextField(label: "Branch Name", controller: _branchController),
                    ]),
                  ],
                ),

                ProfileSection(
                  title: "Emergency Contact",
                  icon: Icons.contact_phone_outlined,
                  status: "Editable",
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Contact Name", controller: _emergencyNameController),
                      ProfileTextField(label: "Contact Number", controller: _emergencyNumberController),
                    ]),
                  ],
                ),

                ProfileSection(
                  title: "Address Details",
                  icon: Icons.location_on_outlined,
                  status: "Editable",
                  children: [
                    ProfileTextField(label: "Full Address *", controller: _addressController, icon: Icons.home_outlined),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "City *", controller: _cityController),
                      ProfileTextField(label: "State *", controller: _stateController),
                    ]),
                    ProfileTextField(label: "Pincode *", controller: _pincodeController),
                  ],
                ),

                ProfileSection(
                  title: "Security Settings",
                  icon: Icons.lock_outline_rounded,
                  status: "Editable",
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "New Password", controller: _passwordController, isPassword: true),
                      ProfileTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true),
                    ]),
                  ],
                ),

                SizedBox(height: context.scale(32)),
                _buildActionButtons(context),
                SizedBox(height: context.scale(60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserDetail detail) {
    final theme = context.theme;
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(isMobile ? 24 : 32)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(24)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            radius: context.scale(isMobile ? 50 : 60),
            imageUrl: ApiService.getStorageUrl(detail.photo),
            localImage: _imageFile,
            webImage: _webImage,
            onCameraTap: _pickImage,
          ),
          SizedBox(
            width: isMobile ? 0 : context.scale(32),
            height: isMobile ? context.scale(24) : 0,
          ),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  detail.user?.name ?? "Staff Member",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: context.font(24),
                  ),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                Text(
                  detail.user?.email ?? "",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.scale(12)),
                Chip(
                  label: Text(
                    "STAFF",
                    style: TextStyle(
                      fontSize: context.font(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: context.scale(18)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
            ),
            child: const Text("UPDATE PROFILE"),
          ),
        ),
        SizedBox(height: context.scale(16)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true) {
                await ApiService.logout();
                if (mounted && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            label: const Text("LOGOUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
          ),
        ),
      ],
    );
  }
}
