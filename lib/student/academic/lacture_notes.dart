import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<dynamic> _notes = [];
  bool _isLoading = true;
  final Map<String, bool> _subjectOpenStates = {};

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentNotes();
      setState(() {
        if (data is List) {
          _notes = data;
        } else if (data is Map && data.containsKey('notes')) {
          _notes = data['notes'] as List? ?? [];
        } else {
          _notes = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching notes: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    Map<String, List<dynamic>> groupedNotes = {};
    for (var note in _notes) {
      final subjectName = note['subject']?['name'] ?? 'General';
      if (!groupedNotes.containsKey(subjectName)) {
        groupedNotes[subjectName] = [];
      }
      groupedNotes[subjectName]!.add(note);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Lecture Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : groupedNotes.isEmpty
              ? Center(child: Text("No notes available", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))))
              : RefreshIndicator(
                  onRefresh: _fetchNotes,
                  color: colorScheme.primary,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: ListView.separated(
                        padding: context.pagePadding,
                        itemCount: groupedNotes.length,
                        separatorBuilder: (context, index) => SizedBox(height: context.md),
                        itemBuilder: (context, index) {
                          final subjectName = groupedNotes.keys.elementAt(index);
                          final subjectNotes = groupedNotes[subjectName]!;
                          final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(context.md),
                              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    subjectName,
                                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                  ),
                                  trailing: AnimatedRotation(
                                    duration: const Duration(milliseconds: 200),
                                    turns: isOpen ? 0.5 : 0,
                                    child: Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant, size: context.scale(24)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _subjectOpenStates[subjectName] = !isOpen;
                                    });
                                  },
                                ),
                                if (isOpen)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: context.sm),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                                        if (crossAxisCount > 1) {
                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(horizontal: context.sm),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: context.sm,
                                              mainAxisSpacing: context.sm,
                                              childAspectRatio: 2.2,
                                            ),
                                            itemCount: subjectNotes.length,
                                            itemBuilder: (context, idx) => _noteCard(subjectNotes[idx]),
                                          );
                                        }
                                        return Column(
                                          children: subjectNotes.map((note) => _noteCard(note)).toList(),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _noteCard(dynamic note) {
    final theme = context.theme;
    final uploadedAt = note['created_at'] != null ? DateTime.tryParse(note['created_at']) : null;
    final dateStr = uploadedAt != null ? DateFormat('dd MMM, yyyy').format(uploadedAt) : (note['created_at'] ?? 'N/A');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.md, vertical: context.xs),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? 'N/A',
                      style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.xs),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: theme.colorScheme.onSurfaceVariant, size: context.scale(14)),
                        SizedBox(width: context.xs),
                        Text(
                          "Uploaded: $dateStr",
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.description, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3), size: context.scale(24)),
            ],
          ),
          SizedBox(height: context.md),
          Row(
            children: [
              Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant, size: context.scale(14)),
              SizedBox(width: context.xs),
              Text(
                "By: ${note['uploaded_by_name'] ?? 'N/A'}",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
              )
            ],
          ),
          if (note['description'] != null && note['description'].toString().isNotEmpty) ...[
            SizedBox(height: context.md),
            Text(
              note['description'] ?? '',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          SizedBox(height: context.md),
          SizedBox(
            width: double.infinity,
            height: context.scale(40),
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle download using note['file_path']
              },
              icon: Icon(Icons.visibility_outlined, size: context.scale(18)),
              label: Text("VIEW / DOWNLOAD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13))),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
