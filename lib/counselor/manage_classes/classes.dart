import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  bool _isLoading = true;
  List<ClassInfo> _classes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/classes');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            dynamic classesData = data['classes'] ?? data['data'] ?? [];
            List rawList = [];
            if (classesData is List) {
              rawList = classesData;
            } else if (classesData is Map && classesData['data'] is List) {
              rawList = classesData['data'];
            }
            
            _classes = rawList.map((json) => ClassInfo.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load classes";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Classes"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ))
              : RefreshIndicator(
                  onRefresh: _fetchClasses,
                  child: _classes.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(child: Text("No classes found", style: TextStyle(color: theme.hintColor))),
                          ],
                        )
                      : GridView.builder(
                          padding: context.pagePadding,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: context.isTablet ? 2 : 1,
                            mainAxisExtent: 180,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            final classInfo = _classes[index];
                            final isActive = classInfo.status == 1;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          child: Icon(Icons.class_outlined, color: theme.colorScheme.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(classInfo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(isActive ? "ACTIVE" : "INACTIVE", 
                                                style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text("SECTIONS", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: classInfo.sections.map((s) => Chip(
                                        label: Text(s.name, style: const TextStyle(fontSize: 11)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
