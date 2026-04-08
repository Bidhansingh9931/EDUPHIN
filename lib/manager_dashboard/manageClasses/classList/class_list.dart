import 'dart:convert';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'create_new_class.dart';

class Class {
  final int id;
  final String name;
  final List<SectionSummary> sections;

  Class({required this.id, required this.name, required this.sections});

  factory Class.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List? ?? [];
    List<SectionSummary> sections =
        sectionsList.map((s) => SectionSummary.fromJson(s)).toList();
    return Class(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
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

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List classesData = responseData['data'];
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
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Classes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateNewClassPage()),
              );
              if (result == true) {
                _fetchClasses();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _fetchClasses,
                  child: GridView.builder(
                    padding: context.pagePadding,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 260, // Fixed height for cards
                    ),
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      return _buildClassCard(context, _classes[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64, color: theme.hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("No classes found", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _fetchClasses, child: const Text("Refresh")),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Class classItem) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SectionsPage(classId: classItem.id, className: classItem.name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      classItem.name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${classItem.sections.length} Sections",
                      style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: classItem.sections.isEmpty
                    ? Center(child: Text("No sections added", style: TextStyle(color: theme.hintColor, fontSize: 12)))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: classItem.sections.length > 2 ? 2 : classItem.sections.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final section = classItem.sections[index];
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: colorScheme.secondary.withOpacity(0.1),
                                child: Text(section.name[0], style: TextStyle(fontSize: 10, color: colorScheme.secondary)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Section ${section.name}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(section.mentorName, style: TextStyle(color: theme.hintColor, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text("${section.sectionLimit} Max", style: TextStyle(fontSize: 11, color: theme.hintColor)),
                            ],
                          );
                        },
                      ),
              ),
              if (classItem.sections.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text("+${classItem.sections.length - 2} more sections...", style: TextStyle(fontSize: 11, color: colorScheme.primary)),
                ),
              const SizedBox(height: 12),
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
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Section", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {}, // Edit class logic
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
