import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

// AddInstitutePage: A form for adding a new institute.
class AddNewInstitutePage extends StatefulWidget {
  const AddNewInstitutePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddInstitutePageState();
}

class _AddInstitutePageState extends State<AddNewInstitutePage> {
  final _instituteNameController = TextEditingController();
  final _chairmanController = TextEditingController();
  final _instituteCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _panController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _instituteNameController.dispose();
    _chairmanController.dispose();
    _instituteCodeController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _affiliationController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _addInstitute() async {
    // Basic validation to ensure key fields are not empty
    if (_instituteNameController.text.isEmpty ||
        _instituteCodeController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Institute Name, Code, and Email.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a network request to save the data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Create a new institute object from the form data
      final newInstitute = Institute(
        name: _instituteNameController.text,
        code: _instituteCodeController.text,
        chairman: _chairmanController.text,
        address: _addressController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        affiliation: _affiliationController.text,
        pan: _panController.text,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Institute added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back and pass the new institute data
      Navigator.of(context).pop(newInstitute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Institute',
            ),
            InkWell(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModeratorDashboardPage())),
                child: const Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: theme.cardColor,
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 60,
                    )),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                context,
                controller: _instituteNameController,
                labelText: 'Institute Name',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _chairmanController,
                labelText: 'Chairman',
                icon: Icons.person_outline_sharp,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _instituteCodeController,
                labelText: 'Institute Code',
                icon: Icons.book_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _addressController,
                labelText: 'Address',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _websiteController,
                labelText: 'Website',
                icon: Icons.web_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _affiliationController,
                labelText: 'Affiliation',
                icon: Icons.corporate_fare_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                context,
                controller: _panController,
                labelText: 'PAN',
                icon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addInstitute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Add Institute',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: theme.hintColor,
        ),
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
