import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
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
  
  late final TapGestureRecognizer _recognizer;
  
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  UserDetail? _currentDetail;
  Map<String, String> _serverErrors = {};

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://demo.eduphin.com/staff/profile');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the website')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = _launchUrl;
    _loadProfile();
  }

  @override
  void dispose() {
    _genderController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _relationshipController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recognizer.dispose();
    super.dispose();
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      setState(() => _serverErrors = {});

      try {
        final Map<String, String> data = {
          'gender': _genderController.text,
          'date_of_birth': _dobController.text,
          'phone': _phoneController.text.trim(),
          'alternate_phone': _altPhoneController.text.trim(),
          'relationship_status': _relationshipController.text,
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'bank_account_number': _accountNumberController.text.trim(),
          'ifsc_code': _ifscController.text.trim(),
          'bank_name': _bankNameController.text.trim(),
          'branch_name': _branchController.text.trim(),
          'emergency_contact_name': _emergencyNameController.text.trim(),
          'emergency_contact_number': _emergencyNumberController.text.trim(),
        };

        if (_passwordController.text.isNotEmpty) {
          data['password'] = _passwordController.text;
          data['password_confirmation'] = _confirmPasswordController.text;
        }

        http.StreamedResponse response;
        if (kIsWeb && _webImage != null) {
          response = await ApiService.postMultipartFromBytes(
            'staff/profile/update', 
            data, 
            files: {'photo': _webImage!}, 
            fileNames: _fileName != null ? {'photo': _fileName!} : null,
          );
        } else {
          response = await ApiService.postMultipart('staff/profile/update', data, files: _imageFile != null ? {'photo': _imageFile!} : null);
        }

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          
          final responseBody = await response.stream.bytesToString();
          dynamic decoded;
          try {
            decoded = jsonDecode(responseBody);
          } catch (e) {
            decoded = {'message': 'Server Error (${response.statusCode}): The backend encountered an issue.'};
          }

          if (response.statusCode >= 200 && response.statusCode < 300) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
            );
            _loadProfile();
            setState(() {
              _passwordController.clear();
              _confirmPasswordController.clear();
              _imageFile = null;
              _webImage = null;
              _serverErrors = {};
            });
          } else if (response.statusCode == 422) {
            final errors = decoded['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              setState(() {
                _serverErrors = errors.map((key, value) => MapEntry(key, (value as List).first.toString()));
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please correct the errors in the form'), backgroundColor: Colors.orange),
              );
            }
          } else {
            throw Exception(decoded['message'] ?? 'Failed to update profile');
          }
        }
      } catch (e) {
        if (mounted) {
          if (Navigator.canPop(context)) Navigator.pop(context); // Close loading dialog if still open
          ErrorHandler.showError(context, e);
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
                _buildEditNotice(context),
                SizedBox(height: context.scale(16)),
                _buildHeader(context, detail),
                SizedBox(height: context.scale(32)),
                
                ProfileSection(
                  title: "Personal Details",
                  icon: Icons.person_outline_rounded,
                  status: "View Only",
                  isReadOnly: true,
                  children: [
                    ProfileTextField(
                      label: "Full Name",
                      controller: TextEditingController(text: detail.user?.name ?? ''),
                      enabled: false,
                    ),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "Gender",
                        controller: _genderController,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "Date of Birth",
                        controller: _dobController,
                        icon: Icons.calendar_today_rounded,
                        enabled: false,
                      ),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "Phone Number", 
                        controller: _phoneController, 
                        icon: Icons.phone_android_rounded,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "Relationship Status",
                        controller: _relationshipController,
                        enabled: false,
                      ),
                    ]),
                    ProfileTextField(
                      label: "Alternate Phone", 
                      controller: _altPhoneController,
                      enabled: false,
                    ),
                  ],
                ),

                ProfileSection(
                  title: "Bank Details",
                  icon: Icons.account_balance_outlined,
                  status: "View Only",
                  isReadOnly: true,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "Bank Name", 
                        controller: _bankNameController,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "Account Number", 
                        controller: _accountNumberController,
                        enabled: false,
                      ),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "IFSC Code", 
                        controller: _ifscController,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "Branch Name", 
                        controller: _branchController,
                        enabled: false,
                      ),
                    ]),
                  ],
                ),

                ProfileSection(
                  title: "Emergency Contact",
                  icon: Icons.contact_phone_outlined,
                  status: "View Only",
                  isReadOnly: true,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "Contact Name", 
                        controller: _emergencyNameController,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "Contact Number", 
                        controller: _emergencyNumberController,
                        enabled: false,
                      ),
                    ]),
                  ],
                ),

                ProfileSection(
                  title: "Address Details",
                  icon: Icons.location_on_outlined,
                  status: "View Only",
                  isReadOnly: true,
                  children: [
                    ProfileTextField(
                      label: "Full Address", 
                      controller: _addressController, 
                      icon: Icons.home_outlined,
                      enabled: false,
                    ),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "City", 
                        controller: _cityController,
                        enabled: false,
                      ),
                      ProfileTextField(
                        label: "State", 
                        controller: _stateController,
                        enabled: false,
                      ),
                    ]),
                    ProfileTextField(
                      label: "Pincode", 
                      controller: _pincodeController,
                      enabled: false,
                    ),
                  ],
                ),

                ProfileSection(
                  title: "Security Settings",
                  icon: Icons.lock_outline_rounded,
                  status: "View Only",
                  isReadOnly: true,
                  children: [
                    ProfileTextField(
                      label: "Password", 
                      controller: TextEditingController(text: "********"), 
                      isPassword: true,
                      enabled: false,
                    ),
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

  Widget _buildEditNotice(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: context.scale(24)),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "Profile editing is currently unavailable in the app. To update your details, please visit our "),
                  TextSpan(
                    text: "website portal",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: _recognizer,
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
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
