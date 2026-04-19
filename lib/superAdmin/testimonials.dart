import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class TestimonialsManagementScreen extends StatefulWidget {
  const TestimonialsManagementScreen({super.key});

  @override
  State<TestimonialsManagementScreen> createState() => _TestimonialsManagementScreenState();
}

class _TestimonialsManagementScreenState extends State<TestimonialsManagementScreen> {
  List<dynamic> _testimonials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestimonials();
  }

  Future<void> _fetchTestimonials() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSuperAdminTestimonials();
      if (mounted) {
        setState(() {
          _testimonials = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteTestimonial(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Testimonial"),
        content: const Text("Are you sure you want to delete this testimonial?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteTestimonial(id);
        _fetchTestimonials();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Testimonials Management",
            style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.scale(8)),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddTestimonialScreen()))
                    .then((_) => _fetchTestimonials());
              },
              icon: Icon(Icons.add_circle_outline_rounded,
                  color: theme.colorScheme.primary, size: context.scale(22)),
              tooltip: "Add New Testimonial",
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchTestimonials,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(context.scale(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.format_quote_rounded,
                                        color: theme.colorScheme.primary, size: context.scale(24)),
                                    SizedBox(width: context.scale(12)),
                                    Text("Testimonial Directory",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font(16))),
                                  ],
                                ),
                                SizedBox(height: context.scale(4)),
                                Text("Manage all platform testimonials and user feedback.",
                                    style: TextStyle(
                                        color: theme.hintColor, fontSize: context.font(12))),
                              ],
                            ),
                          ),
                          Divider(color: theme.colorScheme.outlineVariant, height: 1),
                          _buildTable(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - (context.isMobile ? 32 : 48)),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columnSpacing: context.scale(24),
          horizontalMargin: context.scale(20),
          dataRowMinHeight: context.scale(56),
          dataRowMaxHeight: context.scale(72),
          columns: [
            DataColumn(
                label: Text("#",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
            DataColumn(
                label: Text("Image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
            DataColumn(
                label: Text("Name",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
            DataColumn(
                label: Text("Action",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
          ],
          rows: _testimonials.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final testimonial = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString(),
                    style: TextStyle(fontSize: context.font(13), color: theme.hintColor))),
                DataCell(
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                    child: ProfileAvatar(
                      radius: context.scale(18),
                      imageUrl: testimonial['image'] != null
                          ? ApiService.getStorageUrl(testimonial['image'])
                          : null,
                      borderWidth: 0,
                    ),
                  ),
                ),
                DataCell(Text(testimonial['name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(13)))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            color: theme.colorScheme.primary, size: context.scale(20)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddTestimonialScreen(testimonial: testimonial))).then((_) => _fetchTestimonials());
                        },
                        tooltip: "Edit",
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: theme.colorScheme.error, size: context.scale(20)),
                        onPressed: () => _deleteTestimonial(testimonial['id'].toString()),
                        tooltip: "Delete",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AddTestimonialScreen extends StatefulWidget {
  final Map<String, dynamic>? testimonial;
  const AddTestimonialScreen({super.key, this.testimonial});

  @override
  State<AddTestimonialScreen> createState() => _AddTestimonialScreenState();
}

class _AddTestimonialScreenState extends State<AddTestimonialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _messageController = TextEditingController();
  final _dateController = TextEditingController();
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.testimonial != null) {
      _nameController.text = widget.testimonial!['name'] ?? '';
      _designationController.text = widget.testimonial!['designation'] ?? '';
      _messageController.text = widget.testimonial!['message'] ?? '';
      _dateController.text = widget.testimonial!['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
        });
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final fields = {
        'name': _nameController.text,
        'designation': _designationController.text,
        'message': _messageController.text,
        'date': _dateController.text,
        if (widget.testimonial != null) 'id': widget.testimonial!['id'].toString(),
      };

      if (kIsWeb) {
        await ApiService.storeOrUpdateTestimonialFromBytes(
          fields,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );
      } else {
        await ApiService.storeOrUpdateTestimonial(
          fields,
          image: _imageFile,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Testimonial saved successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.testimonial != null ? "Edit Testimonial" : "Add Testimonial",
            style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold)),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(600)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(context.scale(12)),
                            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(context.scale(20)),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(context.scale(12)),
                                      topRight: Radius.circular(context.scale(12))),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                        widget.testimonial != null
                                            ? "Update Testimonial"
                                            : "Testimonial Details",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                            fontSize: context.font(16))),
                                    Text("Enter person details and their feedback.",
                                        style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.hintColor, fontSize: context.font(12))),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(context.scale(24.0)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(context, Icons.person_outline_rounded, "Full Name *"),
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(fontSize: context.font(14)),
                                      validator: (v) =>
                                          v == null || v.isEmpty ? "Required" : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g., John Doe",
                                        filled: true,
                                        fillColor: context.isDarkMode
                                            ? theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3)
                                            : theme.colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(20)),
                                    _buildLabel(
                                        context, Icons.business_center_outlined, "Designation *"),
                                    TextFormField(
                                      controller: _designationController,
                                      style: TextStyle(fontSize: context.font(14)),
                                      validator: (v) =>
                                          v == null || v.isEmpty ? "Required" : null,
                                      decoration: InputDecoration(
                                        hintText: "e.g., Student, Parent",
                                        filled: true,
                                        fillColor: context.isDarkMode
                                            ? theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3)
                                            : theme.colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(20)),
                                    _buildLabel(context, Icons.chat_bubble_outline_rounded, "Message *"),
                                    TextFormField(
                                      controller: _messageController,
                                      maxLines: 5,
                                      style: TextStyle(fontSize: context.font(14)),
                                      validator: (v) =>
                                          v == null || v.isEmpty ? "Required" : null,
                                      decoration: InputDecoration(
                                        hintText: "Write feedback here...",
                                        filled: true,
                                        fillColor: context.isDarkMode
                                            ? theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3)
                                            : theme.colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(20)),
                                    _buildLabel(context, Icons.calendar_today_outlined, "Date *"),
                                    TextFormField(
                                      controller: _dateController,
                                      readOnly: true,
                                      onTap: _selectDate,
                                      style: TextStyle(fontSize: context.font(14)),
                                      validator: (v) =>
                                          v == null || v.isEmpty ? "Required" : null,
                                      decoration: InputDecoration(
                                        hintText: "Select Date",
                                        suffixIcon: Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                                        filled: true,
                                        fillColor: context.isDarkMode
                                            ? theme.colorScheme.surfaceContainerHighest
                                                .withValues(alpha: 0.3)
                                            : theme.colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(24)),
                                    _buildLabel(context, Icons.image_outlined, "Profile Photo"),
                                    _buildFilePicker(context),
                                    SizedBox(height: context.scale(40)),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: Size(double.infinity, context.scale(48)),
                                              side: BorderSide(
                                                  color: theme.colorScheme.outlineVariant),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Text("CANCEL",
                                                style: TextStyle(
                                                    fontSize: context.font(14),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        SizedBox(width: context.scale(16)),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _save,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: theme.colorScheme.onPrimary,
                                              minimumSize: Size(double.infinity, context.scale(48)),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                            child: Text("SAVE",
                                                style: TextStyle(
                                                    fontSize: context.font(14),
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildFilePicker(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: context.scale(48),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  ),
                  alignment: Alignment.center,
                  child: Text("Choose Image",
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(13))),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: context.scale(12.0)),
                    child: Text(
                        _imageName ?? (_imageFile != null ? _imageFile!.path : "No file chosen"),
                        style: TextStyle(color: theme.hintColor, fontSize: context.font(13)),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.scale(6)),
        Text("JPG, PNG, GIF files only.",
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
      ],
    );
  }
}
