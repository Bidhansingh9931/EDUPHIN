import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/edit_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/studentList/student_list.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
        final List allClasses = responseData['data'] as List? ?? [];
        final currentClass = allClasses.firstWhere(
              (classData) => (classData['id'] is int ? classData['id'] : int.tryParse(classData['id'].toString())) == widget.classId,
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
        label: Text("Create New Section", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sections for ${widget.className}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(18),
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = context.theme;
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Text(_error, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
        ),
      );
    }
    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant),
            SizedBox(height: context.scale(16)),
            Text("No sections found for this class.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
          ],
        ),
      );
    }

    return context.responsive(
      ListView.separated(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(100)),
        itemCount: _sections.length,
        separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return SectionCard(section: section, onUpdate: _fetchSections);
        },
      ),
      tablet: GridView.builder(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(100)),
        itemCount: _sections.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: context.scale(16),
          crossAxisSpacing: context.scale(16),
          mainAxisExtent: context.scale(200),
        ),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return SectionCard(section: section, onUpdate: _fetchSections);
        },
      ),
      desktop: GridView.builder(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(100)),
        itemCount: _sections.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: context.scale(20),
          crossAxisSpacing: context.scale(20),
          mainAxisExtent: context.scale(200),
        ),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return SectionCard(section: section, onUpdate: _fetchSections);
        },
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Section section;
  final VoidCallback onUpdate;

  const SectionCard({super.key, required this.section, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.scale(16)),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Class Limit",
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(10), letterSpacing: 0.5)),
                  Text(section.limit.toString(),
                      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(16))),
                ],
              )
            ],
          ),
          SizedBox(height: context.scale(4)),
          Text(
            "Mentor: ${section.mentor}",
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          ),
          SizedBox(height: context.scale(16)),
          Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  color: theme.colorScheme.primary,
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
                ),
              ),
              SizedBox(width: context.scale(8)),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.people_alt_outlined,
                  label: "Students",
                  color: theme.colorScheme.secondary,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentListPage(
                                sectionId: section.id,
                                sectionName: section.name)));
                  },
                ),
              ),
              SizedBox(width: context.scale(8)),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.delete_outline,
                  label: "Delete",
                  color: theme.colorScheme.error,
                  onPressed: () => showDeleteDialog(context, section, onUpdate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(context.scale(8)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.scale(8)),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(context.scale(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.scale(16), color: color),
            SizedBox(height: context.scale(2)),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.font(10)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
    barrierColor: context.theme.colorScheme.scrim.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, __, ___) {
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
        final theme = context.theme;
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
    final theme = context.theme;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.scale(24)),
        padding: EdgeInsets.all(context.scale(20)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(context.scale(20)),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: context.scale(48)),
              SizedBox(height: context.scale(16)),
              Text(
                "Delete Section",
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(20)),
              ),
              SizedBox(height: context.scale(12)),
              Text(
                "Are you sure you want to delete this section: ${widget.section.name}? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
              ),
              SizedBox(height: context.scale(24)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: context.scale(12)),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        elevation: 0,
                      ),
                      onPressed: _isDeleting ? null : _deleteSection,
                      child: _isDeleting
                          ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onError))
                          : const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
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

