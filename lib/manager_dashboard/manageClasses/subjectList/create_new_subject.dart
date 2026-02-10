import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class CreateNewSubjectPage extends StatefulWidget {
  const CreateNewSubjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CreateNewSubjectPageState();
}

class _CreateNewSubjectPageState extends State<CreateNewSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditController = TextEditingController();
  String? _selectedType = 'Theory';
  String? _selectedStatus = 'Active';
  bool _isLoading = false;

  Future<void> _addSubject() async {
    // Use form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'subject_name': _nameController.text,
        'code': _codeController.text,
        'description': _descriptionController.text,
        'credit': _creditController.text,
        'type': _selectedType,
        'status': _selectedStatus?.toLowerCase(),
      };

      final response = await ApiService.post('manager/subjects', body);
      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? 'Subject added successfully!')),
        );
        Navigator.of(context).pop(true); // Pop with success
      } else {
        String errorMessage = responseData['message'] ?? 'An unknown error occurred.';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.map((e) => e[0]).join('\n');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red),
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
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Subject"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addSubject,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Add Subject"),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700), // Limit form width
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.primaryColor,
                ),
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    return isWide
                        ? _buildWideLayout(theme)
                        : _buildNarrowLayout(theme);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(theme, "Subject Name", _nameController, "Enter Subject Name"),
        const SizedBox(height: 16),
        _buildTextField(theme, "Subject Code", _codeController, "Enter Subject Code"),
        const SizedBox(height: 16),
        _buildTextField(theme, "Description (Optional)", _descriptionController,
            "Enter a brief description...",
            maxLines: 4),
        const SizedBox(height: 16),
        _buildTextField(theme, "Credit", _creditController, "Enter Subject Credit",
            keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Type", _selectedType, [
          'Theory',
          'Practical',
          'Applied'
        ], (val) => setState(() => _selectedType = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Status", _selectedStatus, ['Active', 'Inactive'],
            (val) => setState(() => _selectedStatus = val)),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildTextField(
                    theme, "Subject Name", _nameController, "Enter Subject Name")),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField(
                    theme, "Subject Code", _codeController, "Enter Subject Code")),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(theme, "Description (Optional)", _descriptionController,
            "Enter a brief description...",
            maxLines: 3),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildTextField(
                    theme, "Credit", _creditController, "Enter Subject Credit",
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDropdownField(theme, "Type", _selectedType, [
              'Theory',
              'Practical',
              'Applied'
            ], (val) => setState(() => _selectedType = val))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDropdownField(theme, "Status", _selectedStatus, [
              'Active',
              'Inactive'
            ], (val) => setState(() => _selectedStatus = val))),
          ],
        ),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
          validator: (value) {
            if (label.contains("Optional")) return null;
            return value == null || value.isEmpty
                ? 'This field is required'
                : null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    ThemeData theme,
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value == null ? 'Please make a selection' : null,
        ),
      ],
    );
  }
}
