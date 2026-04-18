import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class RegisteredEventsPage extends StatelessWidget {
  const RegisteredEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: context.scale(80),
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              SizedBox(height: context.scale(24)),
              Text(
                'No Registered Events',
                style: TextStyle(
                  fontSize: context.font(18),
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.scale(8)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scale(40)),
                child: Text(
                  'When you register for events from the Explore Events section, they will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.font(14),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
