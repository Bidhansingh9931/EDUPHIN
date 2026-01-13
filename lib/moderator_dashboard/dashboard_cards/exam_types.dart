import 'package:flutter/material.dart';

class ExamTypesPage extends StatelessWidget {
  const ExamTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Types'),
      ),
      body: ListView.builder(
        itemCount: 15, // Example exam type count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.laptop_chromebook_outlined, color: Colors.white),
              ),
              title: Text(
                'Exam Type ${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Description for exam type ${index + 1}',
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
