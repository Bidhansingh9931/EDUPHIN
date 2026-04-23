import 'dart:io';

import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  String? _existingPhotoUrl;

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
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('super_admin_profile');
    if (cachedData != null && mounted) {
      setState(() {
        _nameController.text = cachedData['name'] ?? '';
        _emailController.text = cachedData['email'] ?? '';
        _existingPhotoUrl = cachedData['photo'];
        _isLoading = false;
      });
    }
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (_nameController.text.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getSuperAdminProfile();
      if (data != null) {
        if (mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _existingPhotoUrl = data['photo'];
            _isLoading = false;
          });
          await SuperAdminCacheService.save('super_admin_profile', data);
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      final Map<String, String> data = {
        'name': _nameController.text,
        'email': _emailController.text,
        if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
      };
      
      if (kIsWeb) {
        await ApiService.updateSuperAdminProfileFromBytes(data, _webImage, _fileName);
      } else {
        await ApiService.updateSuperAdminProfile(data, photo: _imageFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() {
          _imageFile = null;
          _webImage = null;
          _fileName = null;
        });
        _fetchProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Your Profile", style: TextStyle(fontSize: context.font(20))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _nameController.text.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(600)),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(24.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                            ProfileAvatar(
                              imageUrl: ApiService.getStorageUrl(_existingPhotoUrl),
                              radius: context.scale(35),
                              localImage: _imageFile,
                              webImage: _webImage,
                              onCameraTap: _pickImage,
                            ),
                            SizedBox(width: context.scale(16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Manage Your Profile", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
                                    Text("Update your personal details and password.", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: context.font(12))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: context.scale(24)),
                            child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                          ),
                          _buildLabel(context, Icons.person, "Full Name *"),
                          TextField(
                            controller: _nameController,
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: const InputDecoration(hintText: "Full Name"),
                          ),
                          SizedBox(height: context.scale(20)),
                          _buildLabel(context, Icons.email, "Email Address *"),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: const InputDecoration(hintText: "Email Address"),
                          ),
                          SizedBox(height: context.scale(20)),
                          _buildLabel(context, Icons.lock, "New Password"),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(fontSize: context.font(14)),
                            decoration: const InputDecoration(hintText: "Enter a new password (optional)"),
                          ),
                          SizedBox(height: context.scale(8)),
                          Text("Leave blank to keep your current password.", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
                          SizedBox(height: context.scale(40)),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, context.scale(54)),
                            ),
                            child: _isSaving
                                ? SizedBox(height: context.scale(20), width: context.scale(20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("SAVE CHANGES", style: TextStyle(fontSize: context.font(16))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(600)),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(context.scale(24.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SuperAdminSkeleton(height: context.scale(70), width: context.scale(70), borderRadius: BorderRadius.circular(context.scale(35))),
                      SizedBox(width: context.scale(16)),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SuperAdminSkeleton(height: 24, width: 200),
                            SizedBox(height: 8),
                            SuperAdminSkeleton(height: 14, width: 250),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.scale(24)),
                  const Divider(),
                  SizedBox(height: context.scale(24)),
                  const SuperAdminSkeleton(height: 16, width: 100),
                  const SizedBox(height: 8),
                  const SuperAdminSkeleton(height: 48),
                  SizedBox(height: context.scale(20)),
                  const SuperAdminSkeleton(height: 16, width: 100),
                  const SizedBox(height: 8),
                  const SuperAdminSkeleton(height: 48),
                  SizedBox(height: context.scale(20)),
                  const SuperAdminSkeleton(height: 16, width: 100),
                  const SizedBox(height: 8),
                  const SuperAdminSkeleton(height: 48),
                  SizedBox(height: context.scale(40)),
                  const SuperAdminSkeleton(height: 54),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8.0)),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: context.scale(16)),
          SizedBox(width: context.scale(8)),
          Text(text, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12))),
        ],
      ),
    );
  }
}
