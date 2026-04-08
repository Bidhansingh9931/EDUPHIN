import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class Testimonial {
  final String name;
  final String role;
  final String content;
  final String date;

  Testimonial({required this.name, required this.role, required this.content, required this.date});
}

class AllTestimonialsPage extends StatelessWidget {
  const AllTestimonialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dummy data for testimonials
    final List<Testimonial> testimonials = [
      Testimonial(
        name: "Dr. Robert Smith",
        role: "Principal, Global Academy",
        content: "Eduphin has transformed how we manage our administrative tasks. The automation is seamless.",
        date: "Oct 12, 2023",
      ),
      Testimonial(
        name: "Maria Garcia",
        role: "Parent",
        content: "I can easily track my child's progress and attendance. The interface is very user-friendly.",
        date: "Nov 05, 2023",
      ),
      Testimonial(
        name: "James Wilson",
        role: "HOD Mathematics",
        content: "The examination management module is a lifesaver. It saves us hours of manual work.",
        date: "Dec 15, 2023",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Success Stories'),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("What our users say", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Real feedback from our global community", style: TextStyle(color: theme.hintColor)),
                const SizedBox(height: 32),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: testimonials.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = testimonials[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.format_quote_rounded, color: Colors.blueAccent, size: 32),
                            const SizedBox(height: 12),
                            Text(
                              item.content,
                              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                                  child: Text(item.name[0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(item.role, style: TextStyle(color: theme.hintColor, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(item.date, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
