import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await ApiService.getSuperAdminProfile();
      if (data != null) {
        if (mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
          });
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
      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
      };
      await ApiService.updateSuperAdminProfile(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Your Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35, 
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1), 
                                child: Icon(Icons.person, color: theme.colorScheme.primary, size: 40)
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Manage Your Profile", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                    Text("Update your personal details and password.", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildLabel(context, Icons.person, "Full Name *"),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: "Full Name"),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(context, Icons.email, "Email Address *"),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(hintText: "Email Address"),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(context, Icons.lock, "New Password"),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: "Enter a new password (optional)"),
                          ),
                          const SizedBox(height: 8),
                          Text("Leave blank to keep your current password.", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _updateProfile,
                            child: _isSaving
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("SAVE CHANGES"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
