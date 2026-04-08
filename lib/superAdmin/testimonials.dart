import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testimonials Management"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTestimonialScreen())).then((_) => _fetchTestimonials());
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add New Testimonial",
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                const Text("Testimonial Directory",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Manage all platform testimonials.",
                                style: TextStyle(color: theme.hintColor, fontSize: 12)),
                            const SizedBox(height: 24),
                            _buildTable(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (context.isTablet ? 100 : 64)),
        child: DataTable(
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Image", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _testimonials.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final testimonial = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: testimonial['image'] != null
                          ? NetworkImage("${ApiService.baseUrl}/storage/${testimonial['image']}")
                          : null,
                      child: testimonial['image'] == null ? Icon(Icons.person, color: theme.colorScheme.primary, size: 18) : null,
                    ),
                  ),
                ),
                DataCell(Text(testimonial['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTestimonialScreen(testimonial: testimonial))).then((_) => _fetchTestimonials());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteTestimonial(testimonial['id'].toString()),
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
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.testimonial != null) {
      _nameController.text = widget.testimonial!['name'] ?? '';
      _designationController.text = widget.testimonial!['designation'] ?? '';
      _messageController.text = widget.testimonial!['message'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
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
        if (widget.testimonial != null) 'id': widget.testimonial!['id'].toString(),
      };

      await ApiService.storeOrUpdateTestimonial(
        fields,
        image: _imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Testimonial saved successfully")));
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testimonial != null ? "Edit Testimonial" : "Add Testimonial"),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                child: Column(
                                  children: [
                                    Text(widget.testimonial != null ? "Update Testimonial" : "Testimonial Details",
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                    Text("Enter person details and their feedback.",
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(context, Icons.person, "Full Name *"),
                                    TextFormField(
                                      controller: _nameController,
                                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                      decoration: const InputDecoration(hintText: "e.g., John Doe"),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildLabel(context, Icons.business_center, "Designation *"),
                                    TextFormField(
                                      controller: _designationController,
                                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                      decoration: const InputDecoration(hintText: "e.g., Student, Parent"),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildLabel(context, Icons.message, "Message *"),
                                    TextFormField(
                                      controller: _messageController,
                                      maxLines: 5,
                                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                      decoration: const InputDecoration(hintText: "Write feedback here..."),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildLabel(context, Icons.image, "Profile Photo"),
                                    _buildFilePicker(context),
                                    const SizedBox(height: 40),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("CANCEL"),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _save,
                                            child: const Text("SAVE"),
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

  Widget _buildFilePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                  alignment: Alignment.center,
                  child: Text("Choose Image", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(_imageFile != null ? _imageFile!.path.split('/').last : "No file chosen",
                        style: TextStyle(color: theme.hintColor, fontSize: 13), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text("JPG, PNG, GIF files only.", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}
