import 'dart:io';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
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
    setState(() => _isLoading = true);
    try {
      Map<String, String> data = {
        'gender': _selectedGender,
        'date_of_birth': _selectedDob,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'phone': _phoneController.text,
        'alternate_phone': _altPhoneController.text,
        'relationship_status': _selectedStatus,
        'bank_account_number': _bankAccController.text,
        'ifsc_code': _ifscController.text,
        'bank_name': _bankNameController.text,
        'branch_name': _branchNameController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_number': _emergencyPhoneController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      await ApiService.updateLibrarianProfile(data, photo: _imageFile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
      _fetchProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading && _profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                /// TOP PROFILE CARD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (_profile?.photo != null
                                        ? NetworkImage("${ApiService.baseImageUrl}/storage/${_profile!.photo}") as ImageProvider
                                        : null),
                                child: (_imageFile == null && _profile?.photo == null)
                                    ? Text(_profile?.firstName?.isNotEmpty == true ? _profile!.firstName!.substring(0, 1).toUpperCase() : "L",
                                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.bold))
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _profile?.fullName ?? "N/A",
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Librarian - ${_profile?.employeeId ?? 'N/A'}",
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// PERSONAL INFORMATION
                _buildSection(
                  context,
                  title: "Personal Details",
                  icon: Icons.person_outline,
                  children: [
                    _buildResponsiveRow(context, [
                      _buildDropdownField(context, "Gender", _selectedGender, ["Male", "Female", "Other"], (val) {
                        setState(() => _selectedGender = val!);
                      }),
                      _buildDateField(context, "Date of Birth", _selectedDob, () => _selectDate(context)),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildEditableTextField(context, "Phone Number", _phoneController),
                      _buildEditableTextField(context, "Alternate Phone", _altPhoneController),
                    ]),
                    _buildDropdownField(context, "Relationship Status", _selectedStatus, ["Single", "Married", "Divorced", "Widowed"], (val) {
                      setState(() => _selectedStatus = val!);
                    }),
                  ],
                ),

                /// ADDRESS INFORMATION
                _buildSection(
                  context,
                  title: "Address Information",
                  icon: Icons.location_on_outlined,
                  children: [
                    _buildEditableTextField(context, "Address", _addressController, maxLines: 2),
                    _buildResponsiveRow(context, [
                      _buildEditableTextField(context, "City", _cityController),
                      _buildEditableTextField(context, "State", _stateController),
                    ]),
                    _buildEditableTextField(context, "PINCODE", _pincodeController),
                  ],
                ),

                /// BANKING INFORMATION
                _buildSection(
                  context,
                  title: "Banking Information",
                  icon: Icons.account_balance_outlined,
                  children: [
                    _buildResponsiveRow(context, [
                      _buildEditableTextField(context, "Account Number", _bankAccController),
                      _buildEditableTextField(context, "IFSC Code", _ifscController),
                    ]),
                    _buildResponsiveRow(context, [
                      _buildEditableTextField(context, "Bank Name", _bankNameController),
                      _buildEditableTextField(context, "Branch Name", _branchNameController),
                    ]),
                  ],
                ),

                /// SECURITY
                _buildSection(
                  context,
                  title: "Security Settings",
                  icon: Icons.lock_outline,
                  children: [
                    _buildEditableTextField(context, "Update Password", _passwordController, isPassword: true),
                  ],
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                  label: const Text("UPDATE PROFILE"),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
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
                  icon: const Icon(Icons.logout),
                  label: const Text("LOGOUT"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField(BuildContext context, String label, TextEditingController controller, {bool isPassword = false, int maxLines = 1}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            maxLines: maxLines,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.inputDecorationTheme.fillColor,
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(value.isEmpty ? "Select Date" : value, style: theme.textTheme.bodyMedium)),
                  const Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
