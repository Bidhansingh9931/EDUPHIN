import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/classList/section/create_new_section.dart';
import 'package:eduphin/manager_dashboard/manageClasses/classList/section/section.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'create_new_class.dart';

class Class {
  final int id;
  final String name;
  final List<SectionSummary> sections;

  Class({required this.id, required this.name, required this.sections});

  factory Class.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List;
    List<SectionSummary> sections =
        sectionsList.map((s) => SectionSummary.fromJson(s)).toList();
    return Class(
      id: json['id'],
      name: json['name'],
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Class List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateNewClassPage()),
              );
              if (result == true) {
                _fetchClasses(); // Refresh the list if a class was created
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? const Center(child: Text("No classes found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    return _buildClassCard(theme, _classes[index]);
                  },
                ),
    );
  }

  Widget _buildClassCard(ThemeData theme, Class classItem) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SectionsPage(classId: classItem.id, className: classItem.name),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    classItem.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const Icon(Icons.edit, color: Colors.white),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "${classItem.sections.length} Sections",
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              ...classItem.sections
                  .map((section) => _buildSectionRow(theme, section)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateNewSectionPage(classId: classItem.id),
                      ),
                    );
                    if (result == true) {
                      _fetchClasses(); // Refresh the list if a section was created
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text("Add Section",
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(26)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionRow(ThemeData theme, SectionSummary section) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Section ${section.name}",
                  style: const TextStyle(color: Colors.white)),
              Text("Limit: ${section.sectionLimit}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(section.mentorName,
                  style: const TextStyle(color: Colors.white)),
              const Text("Class Mentor",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
