import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data model for Study Material
class StudyMaterial {
  final int id;
  final String title;
  final String description;
  final int classId;
  final int sectionId;
  final String className; 
  final String section;
  final String uploadedBy;
  final String date;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.classId,
    required this.sectionId,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.date,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json, Map<int, String> classMap, Map<int, String> sectionMap, Map<int, String> teacherMap) {
    final int classId = int.tryParse(json['class_id']?.toString() ?? '') ?? 0;
    final int sectionId = int.tryParse(json['section_id']?.toString() ?? '') ?? 0;
    final int userId = int.tryParse(json['user_id']?.toString() ?? '') ?? 0;
    
    return StudyMaterial(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      classId: classId,
      sectionId: sectionId,
      className: classMap[classId] ?? 'N/A',
      section: sectionMap[sectionId] ?? 'N/A',
      uploadedBy: teacherMap[userId] ?? 'N/A',
      date: json['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(json['created_at'].toString())) : 'N/A',
    );
  }
}

class ApiClass {
  final int id;
  final String name;
  ApiClass({required this.id, required this.name});

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'N/A',
    );
  }
}

class ApiSection {
  final int id;
  final String name;
  ApiSection({required this.id, required this.name});

  factory ApiSection.fromJson(Map<String, dynamic> json) {
    return ApiSection(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['section_name']?.toString() ?? 'N/A',
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? selectedClass;
  String? selectedSection;

  List<ApiClass> classes = [];
  List<ApiSection> sections = [];
  List<StudyMaterial> allMaterials = [];
  List<StudyMaterial> filteredMaterials = [];
  bool isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    const cacheKey = 'manager_notes';
    final cachedData = await CacheService.getCache(cacheKey);
    if (cachedData != null && mounted) {
      _processResponse(cachedData);
      setState(() => isLoading = false);
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    const cacheKey = 'manager_notes';
    
    if (allMaterials.isEmpty) {
      setState(() {
        isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await ApiService.get('manager/study/notes');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];
        await CacheService.setCache(cacheKey, responseData);
        if (mounted) {
          _processResponse(responseData);
          setState(() => isLoading = false);
        }
      } else {
        throw Exception(ApiService.errorMessage(response, 'Failed to load data'));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = allMaterials.isEmpty;
          _error = e;
        });
      }
    }
  }

  void _processResponse(dynamic responseData) {
    final List<ApiClass> fetchedClasses = (responseData['classes'] as List)
        .map((data) => ApiClass.fromJson(data))
        .toList();
    final List<ApiSection> fetchedSections = (responseData['sections'] as List)
        .map((data) => ApiSection.fromJson(data))
        .toList();

    final classMap = {for (var e in fetchedClasses) e.id: e.name};
    final sectionMap = {for (var e in fetchedSections) e.id: e.name};

    final teachers = responseData['teachers'] as List;
    final Map<int, String> teacherMap = {for (var t in teachers) t['id']: t['name'] ?? 'N/A'};

    final List<StudyMaterial> fetchedMaterials = (responseData['study_materials'] as List)
        .map((data) => StudyMaterial.fromJson(data, classMap, sectionMap, teacherMap))
        .toList();

    setState(() {
      classes = fetchedClasses;
      sections = fetchedSections;
      allMaterials = fetchedMaterials;
      _filterMaterials();
    });
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = allMaterials.where((material) {
        final matchClass = selectedClass == null || material.className == selectedClass;
        final matchSection = selectedSection == null || material.section == selectedSection;
        return matchClass && matchSection;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Study Material List"),
      ),
      body: LoadingWrapper(
        isLoading: isLoading,
        hasData: allMaterials.isNotEmpty,
        error: _error,
        onRetry: _fetchData,
        skeleton: _buildSkeleton(context),
        child: Padding(
          padding: context.pagePadding.copyWith(bottom: 0),
          child: Column(
            children: [
              _buildFilterSection(theme),
              SizedBox(height: context.md),
              Expanded(
                child: context.responsive(
                  _buildListView(),
                  tablet: _buildGridView(),
                  desktop: _buildGridView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        children: [
          SkeletonBox(height: context.scale(100), borderRadius: context.scale(20)),
          SizedBox(height: context.md),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: context.sm),
              itemBuilder: (context, index) => SkeletonBox(height: context.scale(120), borderRadius: context.scale(18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              theme,
              "Select Class",
              selectedClass,
              ["All", ...classes.map((c) => c.name)],
              (v) {
                setState(() {
                  selectedClass = v == "All" ? null : v;
                  selectedSection = null;
                  _filterMaterials();
                });
              },
            ),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: _buildDropdown(
              theme,
              "Select Section",
              selectedSection,
              ["All", ...sections.map((s) => s.name)],
              (v) {
                setState(() {
                  selectedSection = v == "All" ? null : v;
                  _filterMaterials();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    final uniqueItems = items.toSet().toList();
    final String dropdownValue = (value == null || !uniqueItems.contains(value)) ? "All" : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: dropdownValue,
          dropdownColor: theme.colorScheme.surfaceContainerLow,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: uniqueItems.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildListView() {
    return filteredMaterials.isNotEmpty
        ? ListView.separated(
            padding: const EdgeInsets.only(bottom: 80), // Adjusted for FAB
            itemCount: filteredMaterials.length,
            separatorBuilder: (context, index) => SizedBox(height: context.sm),
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index]),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }

  Widget _buildGridView() {
    return filteredMaterials.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Adjusted for FAB
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: context.sm,
              crossAxisSpacing: context.sm,
              childAspectRatio: 1.8, // Adjust this for card height
            ),
            itemCount: filteredMaterials.length,
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index]),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }
}

class _StudyMaterialCard extends StatelessWidget {
  final StudyMaterial material;

  const _StudyMaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(18)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${material.className} - ${material.section}",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: context.xs),
          Text(
            material.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Uploaded by: ${material.uploadedBy} on ${material.date}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

