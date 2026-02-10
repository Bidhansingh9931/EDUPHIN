import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddNewInstitutePage extends StatefulWidget {
  const AddNewInstitutePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddInstitutePageState();
}

class _AddInstitutePageState extends State<AddNewInstitutePage> {
  final _formKey = GlobalKey<FormState>();

  // Updated controllers to match the backend model
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _chairmanNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _affiliationDetailsController = TextEditingController();

  File? _logo;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _codeController.dispose();
    _establishedYearController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _chairmanNameController.dispose();
    _websiteController.dispose();
    _affiliationDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  Future<void> _addInstitute() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = await ApiService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/moderator/institutes'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add all form fields
    request.fields.addAll({
      'name': _nameController.text,
      'code': _codeController.text,
      'established_year': _establishedYearController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'contact_email': _contactEmailController.text,
      'contact_phone': _contactPhoneController.text,
      'chairman_name': _chairmanNameController.text,
      'website': _websiteController.text,
      'affiliation_details': _affiliationDetailsController.text,
      'status': 'pending', // Default status
    });

    // Add logo file if selected
    if (_logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', _logo!.path));
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Institute added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Pop with success result
        }
      } else {
        final error = jsonDecode(responseBody);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add institute: ${error['message'] ?? 'Unknown error'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
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
        controller: _nameController,
        labelText: 'Institute Name *',
        icon: Icons.school_outlined,
        validator: (value) => value!.isEmpty ? 'Name is required' : null,
      ),
      _buildTextField(
        controller: _codeController,
        labelText: 'Institute Code *',
        icon: Icons.book_outlined,
        validator: (value) => value!.isEmpty ? 'Code is required' : null,
      ),
      _buildTextField(
        controller: _chairmanNameController,
        labelText: 'Chairman Name *',
        icon: Icons.person_outline_sharp,
         validator: (value) => value!.isEmpty ? 'Chairman Name is required' : null,
      ),
      _buildTextField(
        controller: _establishedYearController,
        labelText: 'Established Year *',
        icon: Icons.calendar_today_outlined,
        keyboardType: TextInputType.number,
         validator: (value) => value!.isEmpty ? 'Year is required' : null,
      ),
      _buildTextField(
        controller: _addressController,
        labelText: 'Address *',
        icon: Icons.location_on_outlined,
         validator: (value) => value!.isEmpty ? 'Address is required' : null,
      ),
        _buildTextField(
        controller: _cityController,
        labelText: 'City *',
        icon: Icons.location_city_outlined,
         validator: (value) => value!.isEmpty ? 'City is required' : null,
      ),
        _buildTextField(
        controller: _stateController,
        labelText: 'State *',
        icon: Icons.map_outlined,
         validator: (value) => value!.isEmpty ? 'State is required' : null,
      ),
        _buildTextField(
        controller: _pincodeController,
        labelText: 'Pincode *',
        icon: Icons.pin_drop_outlined,
        keyboardType: TextInputType.number,
        validator: (value) => value!.isEmpty ? 'Pincode is required' : null,
      ),
      _buildTextField(
        controller: _contactEmailController,
        labelText: 'Contact Email *',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
            if(value!.isEmpty) return 'Email is required';
            if(!value.contains('@')) return 'Enter a valid email';
            return null;
        }
      ),
      _buildTextField(
        controller: _contactPhoneController,
        labelText: 'Contact Phone *',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
         validator: (value) => value!.isEmpty ? 'Phone is required' : null,
      ),
      _buildTextField(
        controller: _websiteController,
        labelText: 'Website',
        icon: Icons.web_outlined,
        keyboardType: TextInputType.url,
      ),
      _buildTextField(
        controller: _affiliationDetailsController,
        labelText: 'Affiliation Details',
        icon: Icons.corporate_fare_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Add New Institute',
          style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(18)),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ModeratorDashboardPage(),
              ),
            ),
            icon: const Icon(
              Icons.home_sharp,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 16, screenWidth * 0.04, 80),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickLogo,
                  child: Center(
                    child: Container(
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1B263B),
                        border: Border.all(color: Colors.white24),
                        image: _logo != null ? DecorationImage(image: FileImage(_logo!), fit: BoxFit.cover) : null,
                      ),
                      child: _logo == null 
                          ? Icon(
                              Icons.add_a_photo_outlined,
                              size: screenWidth * 0.12,
                              color: Colors.white70,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text("Tap to upload logo", style: TextStyle(color: Colors.white54, fontSize: responsiveFontSize(12))),
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
                        childAspectRatio: 5.5, // Adjusted for validator text
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
                      disabledBackgroundColor: const Color(0xFF0E86D4).withAlpha(128),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(14)),
      keyboardType: keyboardType,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
