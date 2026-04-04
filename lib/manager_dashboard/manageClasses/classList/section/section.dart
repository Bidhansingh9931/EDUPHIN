import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/edit_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/student_list.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'section_model.dart';

class SectionsPage extends StatefulWidget {
  final int classId;
  final String className;

  const SectionsPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  bool _isLoading = true;
  List<Section> _sections = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        final allClasses = responseData['data'] as List? ?? [];
        final currentClass = allClasses.firstWhere(
              (classData) => classData['id'] == widget.classId,
          orElse: () => null,
        );

        if (currentClass != null) {
          final sectionsData = currentClass['sections'] as List? ?? [];
          final fetchedSections = sectionsData
              .map((sectionJson) => Section.fromJson(sectionJson))
              .toList();

          if (mounted) {
            setState(() {
              _sections = fetchedSections;
            });
          }
        } else {
          throw Exception("Class with ID ${widget.classId} not found.");
        }
      } else {
        throw Exception(
            responseData['message'] ?? "Failed to fetch sections for class.");
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CreateNewSectionPage(classId: widget.classId),
            ),
          );
          if (result == true) {
            _fetchSections(); // Refresh data if a new section was created
          }
        },
        label: const Text("Create New Section"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Sections for ${widget.className}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.menu),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: TextStyle(color: theme.colorScheme.error)));
    }
    if (_sections.isEmpty) {
      return const Center(child: Text("No sections found for this class."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: _sections.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5, // Adjust for content
            ),
            itemBuilder: (context, index) {
              final section = _sections[index];
              return SectionCard(section: section, onUpdate: _fetchSections);
            },
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: _sections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final section = _sections[index];
              return SectionCard(section: section, onUpdate: _fetchSections);
            },
          );
        }
      },
    );
  }
}

class SectionCard extends StatelessWidget {
  final Section section;
  final VoidCallback onUpdate;

  const SectionCard({super.key, required this.section, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(section.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Class Limit",
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                  Text(section.limit.toString(),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: theme.colorScheme.onPrimary)),
                ],
              )
            ],
          ),
          Text("Mentor: ${section.mentor}",
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withAlpha(180))),
          const SizedBox(height: 12),
          Divider(
            color: theme.colorScheme.onPrimary.withAlpha(180),
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditSectionPage(section: section)));
                    if (result == true) {
                      onUpdate();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentListPage(
                                sectionId: section.id,
                                sectionName: section.name)));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer),
                  icon: const Icon(Icons.people_alt_outlined, size: 16),
                  label: const Text("Students", overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showDeleteDialog(context, section, onUpdate),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showDeleteDialog(
    BuildContext context, Section section, VoidCallback onUpdate) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Theme.of(context).colorScheme.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSectionDialog(
        section: section,
        onUpdate: onUpdate,
      );
    },
  );
}

class DeleteSectionDialog extends StatefulWidget {
  final Section section;
  final VoidCallback onUpdate;

  const DeleteSectionDialog({
    super.key,
    required this.section,
    required this.onUpdate,
  });

  @override
  State<DeleteSectionDialog> createState() => _DeleteSectionDialogState();
}

class _DeleteSectionDialogState extends State<DeleteSectionDialog> {
  bool _isDeleting = false;

  Future<void> _deleteSection() async {
    setState(() => _isDeleting = true);
    try {
      await ApiService.delete('manager/sections/${widget.section.id}');
      if (mounted) {
        final theme = Theme.of(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Section deleted successfully'),
            backgroundColor: theme.colorScheme.primary,
          ),
        );
        widget.onUpdate();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete Section",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete this section: ${widget.section.name}? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(220),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isDeleting ? null : _deleteSection,
                    child: _isDeleting
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                        : const Text("Yes, Delete"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
