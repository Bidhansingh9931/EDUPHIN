import 'dart:async';
import 'package:flutter/material.dart';

// 1. Data Model for an Exam Type
class ExamType {
  final String name;
  final String description;

  ExamType({
    required this.name,
    required this.description,
  });
}

// 2. Data Provider to fetch exam types
class ExamTypeProvider {
  Future<List<ExamType>> fetchExamTypes() async {
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(
      15,
      (index) => ExamType(
        name: 'Exam Type ${index + 1}',
        description: 'Description for exam type ${index + 1}',
      ),
    );
  }
}

// 3. StatefulWidget to handle dynamic data
class ExamTypesPage extends StatefulWidget {
  const ExamTypesPage({super.key});

  @override
  State<ExamTypesPage> createState() => _ExamTypesPageState();
}

class _ExamTypesPageState extends State<ExamTypesPage> {
  final ExamTypeProvider _provider = ExamTypeProvider();
  late Future<List<ExamType>> _examTypesFuture;

  @override
  void initState() {
    super.initState();
    _examTypesFuture = _provider.fetchExamTypes();
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
          'Exam Types',
          style: TextStyle(fontSize: responsiveFontSize(20), color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<ExamType>>(
        future: _examTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam types found.', style: const TextStyle(color: Colors.white70)));
          }

          final examTypes = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 900 ? 3 : 2);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, 50),
                  itemCount: examTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0, 
                  ),
                  itemBuilder: (context, index) {
                    return ExamTypeCard(
                      examType: examTypes[index],
                      isGridView: true,
                    );
                  },
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 50),
                  itemCount: examTypes.length,
                  itemBuilder: (context, index) {
                    return ExamTypeCard(
                      examType: examTypes[index],
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

class ExamTypeCard extends StatelessWidget {
  final ExamType examType;
  final bool isGridView;

  const ExamTypeCard({
    super.key,
    required this.examType,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: responsiveFontSize(22),
                backgroundColor: const Color(0xFF0D1B2A),
                child: Icon(Icons.laptop_chromebook_outlined, color: Colors.white, size: responsiveFontSize(24)),
              ),
              const Spacer(),
              Text(
                examType.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(14),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                examType.description,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: responsiveFontSize(12),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
            ],
          )
        : ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0D1B2A),
              child: Icon(Icons.laptop_chromebook_outlined, color: Colors.white, size: responsiveFontSize(22)),
            ),
            title: Text(
              examType.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(16),
              ),
            ),
            subtitle: Text(
              examType.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsiveFontSize(14),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
