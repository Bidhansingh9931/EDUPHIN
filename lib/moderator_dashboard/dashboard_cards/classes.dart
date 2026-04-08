import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Data Model for a Class
class ClassInfo {
  final String name;
  final String section;

  ClassInfo({
    required this.name,
    required this.section,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      name: json['name'] ?? 'No Name',
      section: json['section'] ?? 'No Section',
    );
  }
}

// 2. Data Provider to fetch class data
class ClassProvider {
  Future<List<ClassInfo>> fetchClasses(String instituteId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/moderator/institutes/$instituteId/classes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['classes'] != null) {
        final List<dynamic> classesJson = data['classes'];
        return classesJson.map((json) => ClassInfo.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load classes.');
      }
    } else {
      throw Exception('Failed to load classes. Status Code: ${response.statusCode}');
    }
  }
}

// 3. Updated StatefulWidget
class ClassesPage extends StatefulWidget {
  final String instituteId;
  const ClassesPage({super.key, required this.instituteId});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final ClassProvider _provider = ClassProvider();
  late Future<List<ClassInfo>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = _provider.fetchClasses(widget.instituteId);
  }

  Future<void> _refreshClasses() async {
    setState(() {
      _classesFuture = _provider.fetchClasses(widget.instituteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Classes'),
        actions: [
          IconButton(
            onPressed: _refreshClasses,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshClasses,
        child: FutureBuilder<List<ClassInfo>>(
          future: _classesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _refreshClasses, child: const Text("Retry")),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(theme);
            }

            final classes = snapshot.data!;

            return SingleChildScrollView(
              padding: context.pagePadding,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 100,
                    ),
                    itemBuilder: (context, index) {
                      return _buildClassCard(context, classes[index]);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassInfo classInfo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.class_rounded, color: colorScheme.primary),
        ),
        title: Text(
          classInfo.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Section: ${classInfo.section}",
          style: TextStyle(color: theme.hintColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("No classes found", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("There are no classes recorded for this institute.", style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }
}
