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
        // Handle both List and Map response safely
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
    // Group notes by subject
    Map<String, List<dynamic>> groupedNotes = {};
    for (var note in _notes) {
      final subjectName = note['subject']?['name'] ?? 'General';
      if (!groupedNotes.containsKey(subjectName)) {
        groupedNotes[subjectName] = [];
      }
      groupedNotes[subjectName]!.add(note);
    }

    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        title: const Text(
          "Lecture Notes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : groupedNotes.isEmpty
              ? const Center(child: Text("No notes available", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchNotes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final subjectName = groupedNotes.keys.elementAt(index);
                      final subjectNotes = groupedNotes[subjectName]!;
                      final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff3c4566),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            /// SUBJECT HEADER
                            ListTile(
                              title: Text(
                                subjectName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(
                                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onTap: () {
                                setState(() {
                                  _subjectOpenStates[subjectName] = !isOpen;
                                });
                              },
                            ),

                            /// NOTES LIST
                            if (isOpen)
                              ...subjectNotes.map((note) => noteCard(note)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget noteCard(dynamic note) {
    final uploadedAt = note['created_at'] != null ? DateTime.tryParse(note['created_at']) : null;
    final dateStr = uploadedAt != null ? DateFormat('dd MMM, yyyy').format(uploadedAt) : (note['created_at'] ?? 'N/A');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff46507a),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Row(
            children: [
              const Icon(Icons.description, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note['title'] ?? 'N/A',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                "Uploaded: $dateStr",
                style: const TextStyle(color: Colors.white70),
              )
            ],
          ),
          const SizedBox(height: 10),
          /// UPLOADED BY
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                "Uploaded by: ${note['uploaded_by_name'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white70),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            note['description'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 20),
          /// VIEW / DOWNLOAD BUTTON
          GestureDetector(
            onTap: () {
              // Handle download using note['file_path']
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff6b7685),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "VIEW / DOWNLOAD",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
