import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Data Model for a Student
class Student {
  final String name;
  final String grade;
  final String section;
  final String id;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? 'N/A',
      name: json['name'] ?? 'No Name',
      grade: json['grade'] ?? 'No Grade',
      section: json['section'] ?? 'No Section',
    );
  }
}

// 2. Data Provider to fetch student data
class StudentProvider {
  Future<List<Student>> fetchStudents(String instituteId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/moderator/institutes/$instituteId/students'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['students'] != null) {
        final List<dynamic> studentsJson = data['students'];
        return studentsJson.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load students.');
      }
    } else {
      throw Exception('Failed to load students. Status Code: ${response.statusCode}');
    }
  }
}

// 3. Updated StatefulWidget to be dynamic
class StudentsPage extends StatefulWidget {
  final String instituteId;
  const StudentsPage({super.key, required this.instituteId});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StudentProvider _provider = StudentProvider();
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _provider.fetchStudents(widget.instituteId);
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
          'Students',
          style: TextStyle(fontSize: responsiveFontSize(20), color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found.', style: TextStyle(color: Colors.white70)));
          }

          final students = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 900 ? 4 : 3);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, 50),
                  itemCount: students.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8, // Adjusted for better content fit
                  ),
                  itemBuilder: (context, index) {
                    return StudentCard(
                      student: students[index],
                      isGridView: true,
                    );
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 50),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return StudentCard(
                      student: students[index],
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

class StudentCard extends StatelessWidget {
  final Student student;
  final bool isGridView;

  const StudentCard({
    super.key,
    required this.student,
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
                radius: responsiveFontSize(28),
                backgroundColor: const Color(0xFF0D1B2A),
                child: Icon(Icons.person_outline, color: Colors.white, size: responsiveFontSize(30)),
              ),
              const SizedBox(height: 12),
              Text(
                student.name,
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
                '${student.grade} - ${student.section}',
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
              child: Icon(Icons.person, color: Colors.white, size: responsiveFontSize(22)),
            ),
            title: Text(
              student.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(16),
              ),
            ),
            subtitle: Text(
              '${student.grade} - ${student.section}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsiveFontSize(14),
              ),
            ),
          );

    return Card(
      color: const Color(0xFF1B263B),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: isGridView ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
      child: InkWell(
        onTap: () {
          // You can add navigation to a student detail page here
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isGridView ? 16 : 8),
          child: cardContent,
        ),
      ),
    );
  }
}
