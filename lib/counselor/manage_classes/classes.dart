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
      if (!mounted) return;
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] is Map ? jsonResponse['data'] : jsonResponse;
        
        final List classesJson = data['classes'] is List ? data['classes'] : [];
        final List sectionsJson = data['sections'] is List ? data['sections'] : [];

        setState(() {
          _classes = classesJson.map((classMap) {
            // Link sections to their respective classes based on class_id
            final classId = classMap['id'];
            final classSections = sectionsJson.where((s) => s['class_id'] == classId).toList();
            
            // Inject sections into the map so ClassInfo.fromJson can pick them up
            final fullClassMap = Map<String, dynamic>.from(classMap);
            fullClassMap['sections'] = classSections;
            
            return ClassInfo.fromJson(fullClassMap);
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load classes";
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Classes"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.theme.colorScheme.error)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchClasses,
                  child: _classes.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: context.scale(200)),
                            Center(
                                child: Text("No classes found",
                                    style: TextStyle(color: context.theme.hintColor))),
                          ],
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: GridView.builder(
                              padding: context.pagePadding,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                mainAxisExtent: context.scale(200),
                                crossAxisSpacing: context.spacing,
                                mainAxisSpacing: context.spacing,
                              ),
                              itemCount: _classes.length,
                              itemBuilder: (context, index) {
                                final classInfo = _classes[index];
                                final isActive = classInfo.status == 1;
                                return Card(
                                  elevation: 0,
                                  color: context.theme.colorScheme.surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.scale(12)),
                                    side: BorderSide(
                                      color: context.theme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(context.spacing),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: context.scale(20),
                                              backgroundColor: context.theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              child: Icon(Icons.class_outlined,
                                                  color: context.theme.colorScheme.primary,
                                                  size: context.scale(20)),
                                            ),
                                            SizedBox(width: context.sm),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(classInfo.name,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: context.font(16))),
                                                  Text(isActive ? "ACTIVE" : "INACTIVE",
                                                      style: TextStyle(
                                                          color: isActive ? Colors.green : Colors.red,
                                                          fontSize: context.font(10),
                                                          fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.edit_outlined,
                                                    size: context.scale(20))),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text("SECTIONS",
                                            style: context.theme.textTheme.labelSmall?.copyWith(
                                                color: context.theme.hintColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(10))),
                                        SizedBox(height: context.xs),
                                        Expanded(
                                          flex: 2,
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              spacing: context.xs,
                                              runSpacing: context.xs,
                                              children: classInfo.sections
                                                  .map((s) => Chip(
                                                        label: Text(s.name,
                                                            style: TextStyle(fontSize: context.font(11))),
                                                        padding: EdgeInsets.zero,
                                                        visualDensity: VisualDensity.compact,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize.shrinkWrap,
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
    );
  }
}
