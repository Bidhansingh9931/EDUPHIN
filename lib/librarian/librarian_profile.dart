import 'dart:io';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'librarian_models.dart';
import 'package:image_picker/image_picker.dart';

class LibrarianProfilePage extends StatefulWidget {
  const LibrarianProfilePage({super.key});

  @override
  State<LibrarianProfilePage> createState() => _LibrarianProfilePageState();
}

class _LibrarianProfilePageState extends State<LibrarianProfilePage> {
  bool _isLoading = true;
  UserDetail? _profile;
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = "Male";
  String _selectedDob = "";
  String _selectedStatus = "Single";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ApiService.getLibrarianProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _addressController.text = profile.address ?? "";
        _cityController.text = profile.city ?? "";
        _stateController.text = profile.state ?? "";
        _pincodeController.text = profile.pincode ?? "";
        _phoneController.text = profile.phone ?? "";
        _altPhoneController.text = profile.alternatePhone ?? "";
        _bankAccController.text = profile.bankAccountNumber ?? "";
        _ifscController.text = profile.ifscCode ?? "";
        _bankNameController.text = profile.bankName ?? "";
        _branchNameController.text = profile.branchName ?? "";
        _emergencyNameController.text = profile.emergencyContactName ?? "";
        _emergencyPhoneController.text = profile.emergencyContactNumber ?? "";
        _selectedGender = profile.gender ?? "Male";
        _selectedDob = profile.dob ?? "";
        _selectedStatus = profile.relationshipStatus ?? "Single";
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching profile: $e")));
        setState(() => _isLoading = false);
      }
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
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob.isNotEmpty ? DateTime.tryParse(_selectedDob) ?? DateTime.now().subtract(const Duration(days: 365 * 25)) : DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDob = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, String> fields = {
        "gender": _selectedGender,
        "date_of_birth": _selectedDob,
        "relationship_status": _selectedStatus,
        "address": _addressController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "pincode": _pincodeController.text,
        "phone": _phoneController.text,
        "alternate_phone": _altPhoneController.text,
        "bank_account_number": _bankAccController.text,
        "ifsc_code": _ifscController.text,
        "bank_name": _bankNameController.text,
        "branch_name": _branchNameController.text,
        "emergency_contact_name": _emergencyNameController.text,
        "emergency_contact_number": _emergencyPhoneController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        fields["password"] = _passwordController.text;
      }

      if (kIsWeb && _webImage != null) {
        await ApiService.updateLibrarianProfileFromBytes(fields, _webImage!, _fileName);
      } else {
        await ApiService.updateLibrarianProfile(fields, photo: _imageFile);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
      _fetchProfile();
      setState(() {
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (_isLoading && _profile == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Profile Settings",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                /// TOP PROFILE CARD
                _buildHeaderCard(context, theme),

                SizedBox(height: context.lg),

                /// PERSONAL INFORMATION
                ProfileSection(
                  title: "Personal Details",
                  icon: Icons.person_outline_rounded,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileDropdown(
                        label: "Gender",
                        icon: Icons.wc_rounded,
                        value: _selectedGender,
                        items: const ["Male", "Female", "Other"],
                        onChanged: (val) {
                          setState(() => _selectedGender = val!);
                        },
                      ),
                      ProfileTextField(
                        label: "Date of Birth",
                        controller: TextEditingController(text: _selectedDob),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        icon: Icons.calendar_today_rounded,
                      ),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(
                        label: "Phone Number",
                        controller: _phoneController,
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      ProfileDropdown(
                        label: "Relationship Status",
                        icon: Icons.favorite_border_rounded,
                        value: _selectedStatus,
                        items: const ["Single", "Married", "Divorced", "Widowed"],
                        onChanged: (val) {
                          setState(() => _selectedStatus = val!);
                        },
                      ),
                    ]),
                  ],
                ),

                /// ADDRESS INFORMATION
                ProfileSection(
                  title: "Address Information",
                  icon: Icons.location_on_outlined,
                  children: [
                    ProfileTextField(
                      label: "Full Address",
                      icon: Icons.home_outlined,
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "City", icon: Icons.location_city_rounded, controller: _cityController),
                      ProfileTextField(label: "State", icon: Icons.map_rounded, controller: _stateController),
                    ]),
                    ProfileTextField(label: "Postal Code (PINCODE)", icon: Icons.pin_drop_rounded, controller: _pincodeController, keyboardType: TextInputType.number),
                  ],
                ),

                /// BANKING INFORMATION
                ProfileSection(
                  title: "Banking Information",
                  icon: Icons.account_balance_outlined,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Account Number", icon: Icons.numbers_rounded, controller: _bankAccController, keyboardType: TextInputType.number),
                      ProfileTextField(label: "IFSC Code", icon: Icons.code_rounded, controller: _ifscController),
                    ]),
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Bank Name", icon: Icons.account_balance_rounded, controller: _bankNameController),
                      ProfileTextField(label: "Branch Name", icon: Icons.store_rounded, controller: _branchNameController),
                    ]),
                  ],
                ),

                /// EMERGENCY CONTACT
                ProfileSection(
                  title: "Emergency Contact",
                  icon: Icons.emergency_outlined,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "Contact Name", icon: Icons.person_pin_rounded, controller: _emergencyNameController),
                      ProfileTextField(label: "Contact Number", icon: Icons.phone_rounded, controller: _emergencyPhoneController, keyboardType: TextInputType.phone),
                    ]),
                  ],
                ),

                /// SECURITY
                ProfileSection(
                  title: "Security Settings",
                  icon: Icons.lock_outline_rounded,
                  children: [
                    AdaptiveFieldRow(children: [
                      ProfileTextField(label: "New Password", controller: _passwordController, isPassword: true, icon: Icons.lock_open_rounded),
                      ProfileTextField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_rounded),
                    ]),
                    Text(
                      "Leave password fields empty if you don't want to change it.",
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),

                SizedBox(height: context.xl),

                FilledButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading 
                    ? SizedBox(width: context.scale(20), height: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary)) 
                    : const Icon(Icons.check_circle_outline_rounded),
                  label: const Text("UPDATE PROFILE"),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, context.scale(56)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                  ),
                ),
                SizedBox(height: context.md),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Logout"),
                        content: const Text("Are you sure you want to log out of your account?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("LOGOUT", style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ApiService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
                      }
                    }
                  },
                  icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                  label: Text("LOGOUT FROM ACCOUNT", style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, context.scale(56)),
                    backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
                  ),
                ),
                SizedBox(height: context.xl * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            theme.colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.scale(24)),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1),
      ),
      child: context.isMobile
          ? Column(
              children: [
                _buildProfileAvatar(context, theme),
                SizedBox(height: context.md),
                ..._buildProfileInfo(context, theme),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileAvatar(context, theme),
                SizedBox(width: context.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildProfileInfo(context, theme),
                  ),
                ),
                _buildHeaderBadge(context, theme),
              ],
            ),
    );
  }

  Widget _buildHeaderBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: context.scale(16), color: theme.colorScheme.primary),
          SizedBox(width: context.xs),
          Text(
            "ACTIVE",
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, ThemeData theme) {
    return ProfileAvatar(
      radius: context.scale(55),
      localImage: _imageFile,
      webImage: _webImage,
      imageUrl: ApiService.getStorageUrl(_profile?.photo),
      onCameraTap: _pickImage,
      borderWidth: 3,
    );
  }

  List<Widget> _buildProfileInfo(BuildContext context, ThemeData theme) {
    return [
      Text(
        _profile?.fullName ?? "N/A",
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
      ),
      SizedBox(height: context.xs),
      Text(
        "Librarian • Employee ID: ${_profile?.employeeId ?? 'N/A'}",
        textAlign: context.isMobile ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.w500),
      ),
      if (context.isMobile) ...[
        SizedBox(height: context.sm),
        _buildHeaderBadge(context, theme),
      ]
    ];
  }
}
