import 'dart:convert';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'create_new_class.dart';

class Class {
  final int id;
  final String name;
  final String code;
  final String description;
  final String level;
  final List<SectionSummary> sections;

  Class({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.level,
    required this.sections,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List? ?? [];
    List<SectionSummary> sections =
        sectionsList.map((s) => SectionSummary.fromJson(s)).toList();
    return Class(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? '',
      sections: sections,
    );
  }
}

class SectionSummary {
  final String name;
  final int sectionLimit;
  final String mentorName;

  SectionSummary(
      {required this.name, required this.sectionLimit, required this.mentorName});

  factory SectionSummary.fromJson(Map<String, dynamic> json) {
    final mentorData = json['mentor'] as Map<String, dynamic>?;
    final mentorName = mentorData?['name'] as String? ?? 'Not Assigned';

    return SectionSummary(
      name: json['section_name'] ?? 'N/A',
      sectionLimit: json['section_limit'] ?? 0,
      mentorName: mentorName,
    );
  }
}

class ClassListPage extends StatefulWidget {
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  bool _isLoading = true;
  List<Class> _classes = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CachingService.getCache('manager_classes');
    if (cachedData != null && mounted) {
      final List classesData = cachedData;
      setState(() {
        _classes = classesData.map((c) => Class.fromJson(c)).toList();
      });
    }
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List classesData = responseData['data'];
        await CachingService.setCache('manager_classes', classesData);
        if (mounted) {
          setState(() {
            _classes = classesData.map((c) => Class.fromJson(c)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception(responseData['message'] ?? "Failed to fetch classes.");
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage Classes", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Create and organize class sections", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary, size: context.scale(24)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateNewClassPage()),
              );
              if (result == true) {
                _fetchClasses();
              }
            },
          ),
          SizedBox(width: context.spacing),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _classes.isNotEmpty,
        error: _error,
        onRetry: _fetchClasses,
        skeleton: _buildSkeleton(),
        child: _classes.isEmpty
            ? _buildEmptyState(theme)
            : RefreshIndicator(
                onRefresh: _fetchClasses,
                color: theme.colorScheme.primary,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: GridView.builder(
                      padding: context.pagePadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                        crossAxisSpacing: context.spacing,
                        mainAxisSpacing: context.spacing,
                        mainAxisExtent: context.scale(300), // Fixed height for cards
                      ),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        return _buildClassCard(context, _classes[index]);
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
        mainAxisExtent: context.scale(300),
      ),
      itemCount: 6,
      itemBuilder: (context, index) => SkeletonBox(height: context.scale(300), borderRadius: context.scale(16)),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant),
          SizedBox(height: context.md),
          Text("No classes found", style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: context.md),
          ElevatedButton(
            onPressed: _fetchClasses,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
            ),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Class classItem) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SectionsPage(classId: classItem.id, className: classItem.name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      classItem.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(8)),
                    ),
                    child: Text(
                      "${classItem.sections.length} SECTIONS",
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontSize: context.font(10), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing),
              Divider(color: theme.colorScheme.outlineVariant, thickness: 0.5),
              SizedBox(height: context.spacing / 2),
              Expanded(
                child: classItem.sections.isEmpty
                    ? Center(child: Text("No sections added", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: classItem.sections.length > 2 ? 2 : classItem.sections.length,
                        separatorBuilder: (context, index) => SizedBox(height: context.spacing / 2),
                        itemBuilder: (context, index) {
                          final section = classItem.sections[index];
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: context.scale(14),
                                backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
                                child: Text(section.name.isNotEmpty ? section.name[0] : 'S', style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(10), color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: context.spacing / 2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Section ${section.name}", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(13), color: theme.colorScheme.onSurface)),
                                    Text(section.mentorName, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
                                  ],
                                ),
                              ),
                              Text("${section.sectionLimit} Max", style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(11), color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                            ],
                          );
                        },
                      ),
              ),
              if (classItem.sections.length > 2)
                Padding(
                  padding: EdgeInsets.only(top: context.scale(4)),
                  child: Text("+${classItem.sections.length - 2} more sections...", style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(11), color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              SizedBox(height: context.spacing),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateNewSectionPage(classId: classItem.id),
                          ),
                        );
                        if (result == true) {
                          _fetchClasses();
                        }
                      },
                      icon: Icon(Icons.add, size: context.scale(16)),
                      label: Text("SECTION", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(12), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                        side: BorderSide(color: theme.colorScheme.primary),
                        foregroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacing / 2),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewClassPage(classToEdit: classItem),
                        ),
                      );
                      if (result == true) {
                        _fetchClasses();
                      }
                    }, // Edit class logic
                    icon: Icon(Icons.edit_rounded, size: context.scale(18)),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

