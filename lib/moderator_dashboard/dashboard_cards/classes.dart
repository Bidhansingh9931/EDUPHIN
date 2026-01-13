import 'package:flutter/material.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
      ),
      body: ListView.builder(
        itemCount: 10, // Example class count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.book, color: Colors.white),
              ),
              title: Text(
                'Class ${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Section A',
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
