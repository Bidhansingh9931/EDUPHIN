import 'dart:async';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

// 1. Provider class to handle the data submission logic
class InstituteAddProvider {
  Future<Institute> addInstitute(Institute institute) async {
    debugPrint('Submitting institute: ${institute.name}');
    await Future.delayed(const Duration(seconds: 2));
    return institute;
  }
}

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

  final InstituteAddProvider _provider = InstituteAddProvider();
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

    try {
      final addedInstitute = await _provider.addInstitute(newInstitute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Institute added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(addedInstitute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add institute: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    final formFields = [
      _buildTextField(
        controller: _instituteNameController,
        labelText: 'Institute Name',
        icon: Icons.school_outlined,
      ),
      _buildTextField(
        controller: _chairmanController,
        labelText: 'Chairman',
        icon: Icons.person_outline_sharp,
      ),
      _buildTextField(
        controller: _instituteCodeController,
        labelText: 'Institute Code',
        icon: Icons.book_outlined,
      ),
      _buildTextField(
        controller: _addressController,
        labelText: 'Address',
        icon: Icons.location_on_outlined,
      ),
      _buildTextField(
        controller: _emailController,
        labelText: 'Email',
        icon: Icons.email_outlined,
      ),
      _buildTextField(
        controller: _phoneController,
        labelText: 'Phone Number',
        icon: Icons.phone_outlined,
      ),
      _buildTextField(
        controller: _websiteController,
        labelText: 'Website',
        icon: Icons.web_outlined,
      ),
      _buildTextField(
        controller: _affiliationController,
        labelText: 'Affiliation',
        icon: Icons.corporate_fare_outlined,
      ),
      _buildTextField(
        controller: _panController,
        labelText: 'PAN',
        icon: Icons.credit_card_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Institute',
              style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)),
            ),
            InkWell(
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ModeratorDashboardPage())),
              child: const Icon(
                Icons.home_sharp,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: screenWidth * 0.25,
                  width: screenWidth * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B263B),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: screenWidth * 0.15,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: formFields.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 5,
                    ),
                    itemBuilder: (context, index) => formFields[index],
                  );
                } else {
                  return Column(
                    children: formFields.map((widget) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: widget,
                      );
                    }).toList(),
                  );
                }
              }),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addInstitute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E86D4),
                    disabledBackgroundColor: const Color(0xFF0E86D4).withOpacity(0.5),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: responsiveFontSize(16),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(14)),
        filled: true,
        fillColor: const Color(0xFF1B263B),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0E86D4), width: 1.5),
        ),
      ),
    );
  }
}
