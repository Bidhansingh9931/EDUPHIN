import 'dart:io';

import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/error_handler.dart';
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
  String _cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

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
      _processProfileData(cachedData);
    }
    _fetchProfile();
  }

  void _processProfileData(Map<String, dynamic> data) {
    final userData = data['user'] ?? data;
    setState(() {
      _nameController.text = userData['name']?.toString() ?? userData['full_name']?.toString() ?? _nameController.text;
      _emailController.text = userData['email']?.toString() ?? _emailController.text;
      
      // Handle various possible photo keys
      String? rawPhoto = userData['photo']?.toString() ?? 
                         userData['image']?.toString() ?? 
                         userData['profile_photo']?.toString() ??
                         userData['photo_url']?.toString();
      
      if (rawPhoto != null && rawPhoto.isNotEmpty && rawPhoto != "null") {
        // Clean the path to avoid double slashes or redundant storage prefixes
        if (rawPhoto.startsWith('/')) rawPhoto = rawPhoto.substring(1);
        if (rawPhoto.contains('storage/')) {
          rawPhoto = rawPhoto.split('storage/').last;
        }
        _existingPhotoUrl = rawPhoto;
      }
      
      _cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      _isLoading = false;
    });
  }

  Future<void> _fetchProfile() async {
    if (_nameController.text.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getSuperAdminProfile();
      if (data != null && mounted) {
        _processProfileData(data);
        await SuperAdminCacheService.save('super_admin_profile', data);
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) ErrorHandler.showError(context, e);
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

      // Re-fetch to get the updated URL from server
      final newData = await ApiService.getSuperAdminProfile();
      if (newData != null && mounted) {
        _processProfileData(newData);
        await SuperAdminCacheService.save('super_admin_profile', newData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() {
          _imageFile = null;
          _webImage = null;
          _fileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
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
                              key: ValueKey("$_existingPhotoUrl-$_cacheBuster"),
                              imageUrl: _existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty
                                  ? "${ApiService.getStorageUrl(_existingPhotoUrl)}?v=$_cacheBuster"
                                  : null,
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
