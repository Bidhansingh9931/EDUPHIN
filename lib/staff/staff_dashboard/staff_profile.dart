import 'dart:io';
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
  late Future<UserDetail> _profileFuture;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _relationController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  File? _imageFile;
  UserDetail? _currentDetail;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = ApiService.getStaffProfile();
    _profileFuture.then((detail) {
      if (mounted) {
        setState(() {
          _currentDetail = detail;
          _genderController.text = detail.gender ?? '';
          _dobController.text = detail.dateOfBirth ?? '';
          _phoneController.text = detail.phone ?? '';
          _altPhoneController.text = detail.alternatePhone ?? '';
          _relationController.text = detail.relationshipStatus ?? '';
          _addressController.text = detail.address ?? '';
          _cityController.text = detail.city ?? '';
          _stateController.text = detail.state ?? '';
          _pincodeController.text = detail.pincode ?? '';
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final Map<String, String> data = {
          'gender': _genderController.text,
          'date_of_birth': _dobController.text,
          'phone': _phoneController.text,
          'alternate_phone': _altPhoneController.text,
          'relationship_status': _relationController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
          'bank_account_number': _currentDetail?.bankAccountNumber ?? '',
        };

        await ApiService.updateStaffProfile(data, photo: _imageFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          _loadProfile();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<UserDetail>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: context.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(context, detail),
                  const SizedBox(height: 32),
                  _buildSection(
                    context,
                    title: "Personal Information",
                    subtitle: "Update your details.",
                    tag: "Editable",
                    children: [
                      _buildTextField(context, label: "GENDER *", controller: _genderController),
                      _buildTextField(
                        context,
                        label: "Date of Birth *",
                        controller: _dobController,
                        suffixIcon: Icons.calendar_month_rounded,
                      ),
                      _buildTextField(context, label: "Phone *", controller: _phoneController),
                      _buildTextField(context, label: "Alternate Phone", controller: _altPhoneController),
                      _buildTextField(context, label: "Relationship Status", controller: _relationController),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    title: "Address Information",
                    subtitle: "Your current address",
                    tag: "Editable",
                    children: [
                      _buildTextField(
                        context,
                        label: "Address *",
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      _buildTextField(context, label: "City *", controller: _cityController),
                      _buildTextField(context, label: "State *", controller: _stateController),
                      _buildTextField(context, label: "Pincode *", controller: _pincodeController),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    title: "Account Details",
                    subtitle: "System managed information",
                    tag: "Read Only",
                    children: [
                      _buildTextField(context, label: "USER NAME", initialValue: detail.user?.name ?? '', isReadOnly: true),
                      _buildTextField(context, label: "EMAIL ADDRESS", initialValue: detail.user?.email ?? '', isReadOnly: true),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserDetail detail) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: theme.cardTheme.color,
                backgroundImage: _imageFile != null 
                    ? FileImage(_imageFile!) 
                    : (detail.photo != null ? NetworkImage('${ApiService.baseUrl}/storage/${detail.photo}') : null) as ImageProvider?,
                child: (_imageFile == null && detail.photo == null) ? Icon(Icons.person, size: 65, color: theme.colorScheme.onSurface) : null,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          detail.user?.name ?? "Staff User",
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          detail.user?.email ?? "staff@iias.com",
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final bool isReadOnly = tag == "Read Only";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isReadOnly ? theme.dividerColor : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isReadOnly ? theme.hintColor : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children.expand((widget) => [widget, const SizedBox(height: 20)]).toList()..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    TextEditingController? controller,
    String? initialValue,
    bool isReadOnly = false,
    IconData? suffixIcon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: isReadOnly,
          maxLines: maxLines,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isReadOnly ? theme.hintColor : null,
          ),
          decoration: InputDecoration(
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveChanges,
            child: const Text("SAVE CHANGES"),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text("LOGOUT"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
