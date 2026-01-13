import 'package:flutter/material.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: ListView.builder(
        itemCount: 20, // Example account count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.person_outline, color: Colors.white),
              ),
              title: Text(
                'Account User ${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'user${index + 1}@example.com',
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
