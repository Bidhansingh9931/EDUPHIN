import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) {
        return baseSize * 1.2;
      } else if (screenWidth > 600) {
        return baseSize * 1.1;
      }
      return baseSize;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          'Classes',
          style: TextStyle(fontSize: responsiveFontSize(20), color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<ClassInfo>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No classes found.', style: const TextStyle(color: Colors.white70)));
          }

          final classes = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 900 ? 3 : 2);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, 50),
                  itemCount: classes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5, // Aspect ratio for grid items
                  ),
                  itemBuilder: (context, index) {
                    return ClassCard(
                      classInfo: classes[index],
                      isGridView: true,
                    );
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 50),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    return ClassCard(
                      classInfo: classes[index],
                      isGridView: false,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final ClassInfo classInfo;
  final bool isGridView;

  const ClassCard({
    super.key,
    required this.classInfo,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsiveFontSize(double baseSize) {
      if (screenWidth > 1200) return baseSize * 1.2;
      if (screenWidth > 600) return baseSize * 1.1;
      return baseSize;
    }

    final cardContent = isGridView
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: responsiveFontSize(22),
                backgroundColor: const Color(0xFF0D1B2A),
                child: Icon(Icons.book, color: Colors.white, size: responsiveFontSize(24)),
              ),
              const SizedBox(height: 12),
              Text(
                classInfo.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(14),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                classInfo.section,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: responsiveFontSize(12),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        : ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0D1B2A),
              child: Icon(Icons.book, color: Colors.white, size: responsiveFontSize(22)),
            ),
            title: Text(
              classInfo.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(16),
              ),
            ),
            subtitle: Text(
              classInfo.section,
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsiveFontSize(14),
              ),
            ),
            onTap: () {},
          );

    return Card(
      color: const Color(0xFF1B263B),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: isGridView ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isGridView ? 16 : 8),
          child: cardContent,
        ),
      ),
    );
  }
}
