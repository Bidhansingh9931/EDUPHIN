import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'add_librarian.dart';

class Librarian {
  final int id;
  final String name;
  final String designation;

  Librarian({required this.id, required this.name, required this.designation});

  factory Librarian.fromJson(Map<String, dynamic> json) {
    return Librarian(
      id: json['id'],
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Librarian',
    );
  }
}

class LibrarianListPage extends StatefulWidget {
  const LibrarianListPage({super.key});

  @override
  State<StatefulWidget> createState() => _LibrarianListPageState();
}

class _LibrarianListPageState extends State<LibrarianListPage> {
  List<Librarian> _librarians = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchLibrarians();
  }

  Future<void> _fetchLibrarians() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/users/6'); // Role ID for Librarian

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> usersData = data['data'] ?? data;
          setState(() {
            _librarians =
                usersData.map((json) => Librarian.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load librarians');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadLibrarianList() async {
    if (_librarians.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No librarian data to download.")),
      );
      return;
    }

    // Convert librarian list to CSV
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['ID', 'Name', 'Designation']);
    // Add data rows
    for (var librarian in _librarians) {
      rows.add([librarian.id, librarian.name, librarian.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Get storage directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/librarian_list.csv';
      final file = File(path);

      // Write to file
      await file.writeAsString(csv);

      // Open file
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download librarian list: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddLibrarianPage(),
            ),
          );
          if (result == true && mounted) {
            _fetchLibrarians();
          }
        },
        label: Text("Add Librarian",
            style: TextStyle(color: theme.colorScheme.onPrimary)),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Librarian List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadLibrarianList,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            screenSize.width * 0.04,
            screenSize.width * 0.04,
            screenSize.width * 0.04,
            50),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(
                    child: Text(_error,
                        style: TextStyle(color: theme.colorScheme.error)))
                : _librarians.isEmpty
                    ? Center(
                        child: Text("No librarians found.",
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant)))
                    : RefreshIndicator(
                        onRefresh: _fetchLibrarians,
                        child: CustomLibrarianListBox(librarians: _librarians),
                      ),
      ),
    );
  }
}

class CustomLibrarianListBox extends StatelessWidget {
  final List<Librarian> librarians;
  const CustomLibrarianListBox({super.key, required this.librarians});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("All Librarians", style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              if (isLargeScreen) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: librarians.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3.5,
                  ),
                  itemBuilder: (context, index) {
                    return _buildLibrarianItem(context, librarians[index]);
                  },
                );
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: librarians.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildLibrarianItem(context, librarians[index]);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarianItem(BuildContext context, Librarian librarian) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child:
                Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  librarian.name,
                  style: textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  librarian.designation,
                  style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
