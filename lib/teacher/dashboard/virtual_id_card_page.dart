import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class VirtualIdCardPage extends StatelessWidget {
  const VirtualIdCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee ID"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Column(
                      children: [
                        Text(
                          "Indian Institute of Applied Sciences (IIAS)",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Iot No. 88, Knowledge Park, Mock Industrial Estate,\nDelhi\nNew Delhi 102030",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// PROFILE ICON
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.person, size: 60, color: colorScheme.primary),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "EMPLOYEE ID",
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: theme.hintColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// DETAILS SECTION
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Devansh Mehra",
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Expanded(child: InfoWidget("Position", "Senior Mathematics Teacher")),
                              SizedBox(width: 16),
                              Expanded(child: InfoWidget("Employee ID", "EMP0005")),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Expanded(child: InfoWidget("Employment Type", "Full-time")),
                              SizedBox(width: 16),
                              Expanded(child: InfoWidget("Joining Date", "20 Jun 2017")),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// SIGNATURE
                    Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surface,
                      ),
                      child: Text(
                        "Authorized Signature",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.hintColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text("PRINT"),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text("PDF"),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// FLIP
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.flip_camera_android),
                      label: const Text("FLIP CARD"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// SMALL INFO WIDGET
class InfoWidget extends StatelessWidget {
  final String title;
  final String value;

  const InfoWidget(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
