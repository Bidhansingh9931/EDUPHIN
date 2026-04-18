import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
  Uint8List? _webImage;
  String? _imageName;
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
      _existingImageUrl = ApiService.getStorageUrl(testimonial!.image);
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
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageName = pickedFile.name;
          _existingImageUrl = null;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _existingImageUrl = null;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final endpoint = _isEditMode
          ? 'moderator/testimonials/${widget.testimonial!.id}/update'
          : 'moderator/testimonials';

      final Map<String, String> body = {
        'name': _nameController.text,
        'designation': _designationController.text,
        'message': _messageController.text,
        'status': (widget.testimonial?.status ?? 1).toString(),
      };

      if (_isEditMode) {
        body['_method'] = 'PUT';
      }

      debugPrint("Submitting Testimonial to endpoint: $endpoint");

      http.Response response;

      final hasNewImage = (kIsWeb && _webImage != null) || (!kIsWeb && _image != null);

      if (hasNewImage) {
        // Multipart flow
        http.StreamedResponse streamedResponse;
        if (kIsWeb) {
          streamedResponse = await ApiService.postMultipartFromBytes(
            endpoint,
            body,
            files: {'image': _webImage!},
            fileNames: {'image': _imageName ?? 'image.jpg'},
            forceMultipart: true,
          );
        } else {
          streamedResponse = await ApiService.postMultipart(
            endpoint,
            body,
            files: {'image': _image!},
          );
        }
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Standard JSON flow
        response = await ApiService.post(endpoint, body);
      }

      final responseBody = response.body;
      final decodedBody = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Submission successful: $responseBody");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(decodedBody['message'] ?? 'Success!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to signal a refresh
        }
      } else {
        debugPrint("Submission failed with status ${response.statusCode}: $responseBody");
        String errorMessage = decodedBody['message'] ?? 'An unknown error occurred.';
        if (decodedBody['errors'] != null && decodedBody['errors'] is Map) {
            Map<String, dynamic> errors = decodedBody['errors'];
            errorMessage = errors.values.first[0] ?? errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("An exception occurred: $e");
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Testimonial' : 'Add Testimonial', style: TextStyle(fontSize: context.font(20))),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(600)),
              child: Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant, width: 1),
                  borderRadius: BorderRadius.circular(context.scale(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ProfileAvatar(
                          radius: context.scale(60),
                          localImage: _image,
                          webImage: _webImage,
                          imageUrl: _existingImageUrl,
                          onCameraTap: _pickImage,
                        ),
                      ),
                      SizedBox(height: context.sm),
                      Center(child: Text("Tap to add image", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)))),
                      SizedBox(height: context.lg),
                      _buildTextField(context, _nameController, 'Name', validator: (v) => v!.isEmpty ? 'Name is required' : null),
                      SizedBox(height: context.md),
                      _buildTextField(context, _designationController, 'Designation (e.g., Student, Parent)', validator: (v) => v!.isEmpty ? 'Designation is required' : null),
                      SizedBox(height: context.md),
                      _buildTextField(context, _messageController, 'Message', maxLines: 5, validator: (v) => v!.isEmpty ? 'Message is required' : null),
                      SizedBox(height: context.lg),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: context.scale(20),
                                width: context.scale(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                ),
                              )
                            : Text(_isEditMode ? 'Save Changes' : 'Add Testimonial', style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, {int? maxLines, String? Function(String?)? validator}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
