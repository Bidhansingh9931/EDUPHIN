import 'dart:async';
import 'package:eduphin/services/responsive_helper.dart';
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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Exam Types',
          style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ExamType>>(
        future: _examTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: context.pagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: context.scale(48), color: theme.colorScheme.error),
                    SizedBox(height: context.md),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14))),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  SizedBox(height: context.md),
                  Text('No exam types found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          final examTypes = snapshot.data!;

          return GridView.builder(
            padding: context.pagePadding,
            itemCount: examTypes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              mainAxisExtent: context.scale(100),
            ),
            itemBuilder: (context, index) {
              return ExamTypeCard(
                examType: examTypes[index],
              );
            },
          );
        },
      ),
    );
  }
}

class ExamTypeCard extends StatelessWidget {
  final ExamType examType;

  const ExamTypeCard({
    super.key,
    required this.examType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        leading: CircleAvatar(
          radius: context.scale(20),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.laptop_chromebook_outlined, color: colorScheme.primary, size: context.scale(22)),
        ),
        title: Text(
          examType.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          examType.description,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {},
      ),
    );
  }
}
