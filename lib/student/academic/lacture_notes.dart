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

  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

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
          SnackBar(content: Text("Error fetching notes: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedNotes = {};
    for (var note in _notes) {
      final subjectName = note['subject']?['name'] ?? 'General';
      if (!groupedNotes.containsKey(subjectName)) {
        groupedNotes[subjectName] = [];
      }
      groupedNotes[subjectName]!.add(note);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lecture Notes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : groupedNotes.isEmpty
              ? const Center(child: Text("No notes available", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchNotes,
                  color: _primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: groupedNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final subjectName = groupedNotes.keys.elementAt(index);
                      final subjectNotes = groupedNotes[subjectName]!;
                      final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                      return Container(
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                subjectName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: isOpen ? 0.5 : 0,
                                child: const Icon(Icons.expand_more, color: Colors.white70),
                              ),
                              onTap: () {
                                setState(() {
                                  _subjectOpenStates[subjectName] = !isOpen;
                                });
                              },
                            ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  children: subjectNotes.map((note) => _noteCard(note)).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _noteCard(dynamic note) {
    final uploadedAt = note['created_at'] != null ? DateTime.tryParse(note['created_at']) : null;
    final dateStr = uploadedAt != null ? DateFormat('dd MMM, yyyy').format(uploadedAt) : (note['created_at'] ?? 'N/A');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Uploaded: $dateStr",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.description, color: Colors.white38, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                "By: ${note['uploaded_by_name'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )
            ],
          ),
          if (note['description'] != null && note['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              note['description'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle download using note['file_path']
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text("VIEW / DOWNLOAD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
