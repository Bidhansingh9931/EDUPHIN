import 'dart:async';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewClass {
  String className = '';
  String classCode = '';
  String description = '';
  String? level;
}

// ───────────────────────────────────────────────────────────
//                         API SERVICE
// ───────────────────────────────────────────────────────────

class ClassApiService {
  Future<List<String>> fetchClassLevels() async {
    // This could also be an API call, but keeping it as is for now if it's static
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Primary',
      'Secondary',
      'Higher Secondary',
      'Undergraduate',
      'Postgraduate'
    ];
  }

  // Updated to return response data and throw specific errors for better UI feedback
  Future<Map<String, dynamic>> addClass(NewClass newClass) async {
    final classData = {
      'name': newClass.className,
      'code': newClass.classCode,
      'description': newClass.description,
      'level': newClass.level,
    };
    return ApiService.addClass(classData);
  }
}

class AddNewClassPage extends StatefulWidget {
  const AddNewClassPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewClassPageState();
}

class _AddNewClassPageState extends State<AddNewClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ClassApiService();
  
  List<String> _levels = [];
  bool _isLoading = true;
  Object? _error;
  final String _cacheKey = 'class_levels';

  final _newClass = NewClass();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCachedData();
    await _fetchLevels();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getCache(_cacheKey);
    if (cachedData != null && cachedData is List) {
      if (mounted) {
        setState(() {
          _levels = List<String>.from(cachedData);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchLevels() async {
    if (_levels.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final levels = await _apiService.fetchClassLevels();
      await CachingService.setCache(_cacheKey, levels);
      if (mounted) {
        setState(() {
          _levels = levels;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  // Updated to handle exceptions from the API service gracefully
  Future<void> _submitForm() async {
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
      _isSubmitting = true;
    });

    try {
      final responseData = await _apiService.addClass(_newClass);

      if (!mounted) return;

      final message = responseData['message'] ?? 'Class added successfully!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true); // Pop with success

    } catch (e) {
      if (!mounted) return;
      // Display specific error message from the exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add New Class"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading && _levels.isEmpty ? null : _buildActionButtons(theme),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _levels.isNotEmpty,
        error: _error,
        onRetry: _fetchLevels,
        skeleton: _buildSkeleton(),
        child: _buildForm(theme, _levels),
      ),
    );
  }

  Widget _buildSkeleton() {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 120),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildForm(ThemeData theme, List<String> levels) {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        screenSize.width * 0.04,
        screenSize.width * 0.04,
        screenSize.width * 0.04,
        screenSize.height * 0.15, // Space for floating action buttons
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenSize.width * 0.04),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    theme: theme,
                    label: "Class Name",
                    hint: "Enter Class Name",
                    onChanged: (value) => _newClass.className = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Class name is required' : null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildTextField(
                    theme: theme,
                    label: "Class Code",
                    hint: "Enter Class Code",
                    onChanged: (value) => _newClass.classCode = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Class code is required' : null,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildTextField(
                    theme: theme,
                    label: "Description (Optional)",
                    hint: "Enter a brief description of the class...",
                    onChanged: (value) => _newClass.description = value,
                    maxLines: 5,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  _buildDropdown(theme, levels),
                  SizedBox(height: screenSize.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          onChanged: onChanged,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.hintColor),
            filled: true,
            fillColor: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, List<String> levels) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Level",
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        DropdownButtonFormField<String>(
          value: _newClass.level,
          hint: Text("Select Level", style: TextStyle(color: theme.hintColor)),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          items: levels.map((String level) {
            return DropdownMenuItem<String>(value: level, child: Text(level));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _newClass.level = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a level' : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                side: BorderSide(color: theme.dividerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
          ),
          SizedBox(width: screenSize.width * 0.04),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.02),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              icon: _isSubmitting ? Container() : const Icon(Icons.add),
              label: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text("Add Class", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

