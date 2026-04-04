import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'testimonials_page.dart';

class AddEditTestimonialPage extends StatefulWidget {
  final Testimonial? testimonial;

  const AddEditTestimonialPage({super.key, this.testimonial});

  @override
  State<AddEditTestimonialPage> createState() => _AddEditTestimonialPageState();
}

class _AddEditTestimonialPageState extends State<AddEditTestimonialPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _designationController;
  late final TextEditingController _messageController;

  File? _image;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.testimonial != null;

  @override
  void initState() {
    super.initState();
    final testimonial = widget.testimonial;
    _nameController = TextEditingController(text: testimonial?.name ?? '');
    _designationController = TextEditingController(text: testimonial?.designation ?? '');
    _messageController = TextEditingController(text: testimonial?.message ?? '');

    if (testimonial?.image != null) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      _existingImageUrl = '$baseUrl/storage/${testimonial!.image}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _existingImageUrl = null; // Clear existing image if new one is picked
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final token = await ApiService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication Error')));
      }
      setState(() => _isLoading = false);
      return;
    }

    // CORRECTED: Added '/api' prefix to the URLs
    final url = _isEditMode
        ? '${ApiService.baseUrl}/api/moderator/testimonials/${widget.testimonial!.id}/update'
        : '${ApiService.baseUrl}/api/moderator/testimonials';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = _nameController.text;
    request.fields['designation'] = _designationController.text;
    request.fields['message'] = _messageController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    debugPrint("Submitting Testimonial...");
    debugPrint("URL: ${request.url}");
    debugPrint("Method: ${request.method}");
    debugPrint("Fields: ${request.fields}");
    debugPrint("File attached: ${_image?.path}}");

    String? responseBody;

    try {
      var response = await request.send();
      responseBody = await response.stream.bytesToString();
      final decodedBody = jsonDecode(responseBody);

      // The PHP API returns 201 for creation and 200 for update.
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Submission successful: $responseBody");
        if (mounted) {
          // Use the message from the backend for the snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(decodedBody['message'] ?? 'Success!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to signal a refresh
        }
      } else {
        debugPrint("Submission failed with status ${response.statusCode}: $responseBody");
        // The backend validation errors might be in an 'errors' field.
        String errorMessage = decodedBody['message'] ?? 'An unknown error occurred.';
        if (decodedBody['errors'] != null && decodedBody['errors'] is Map) {
            Map<String, dynamic> errors = decodedBody['errors'];
            // Take the first error message to show.
            errorMessage = errors.values.first[0] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("An exception occurred: $e");
      if (responseBody != null) {
        debugPrint("Raw response body on error: $responseBody");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Testimonial' : 'Add Testimonial', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1B263B),
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_existingImageUrl != null ? NetworkImage(_existingImageUrl!) : null) as ImageProvider?,
                  child: _image == null && _existingImageUrl == null
                      ? const Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text("Tap to add image", style: TextStyle(color: Colors.white54))),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Name', validator: (v) => v!.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 16),
              _buildTextField(_designationController, 'Designation (e.g., Student, Parent)', validator: (v) => v!.isEmpty ? 'Designation is required' : null),
              const SizedBox(height: 16),
              _buildTextField(_messageController, 'Message', maxLines: 5, validator: (v) => v!.isEmpty ? 'Message is required' : null),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text(_isEditMode ? 'Save Changes' : 'Add Testimonial', style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int? maxLines, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white38), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF4A90E2)), borderRadius: BorderRadius.circular(8)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(8)),
        focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: const Color(0x800D1B2A),
      ),
      validator: validator,
    );
  }
}
