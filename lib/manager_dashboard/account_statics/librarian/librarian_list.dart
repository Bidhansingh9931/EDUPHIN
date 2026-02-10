import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

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
      final response = await ApiService.get('manager/users/6');

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> usersData = data['data'] ?? data;
          setState(() {
            _librarians = usersData.map((json) => Librarian.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load librarians');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FloatingActionButton(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  "Add Librarian",
                  style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Librarian List",
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.download,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50.0, left: 16, right: 16, top: 16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Center(child: Text(_error))
                : _librarians.isEmpty
                    ? const Center(child: Text("No librarians found."))
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
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: librarians.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final librarian = librarians[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            librarian.name,
                            style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            librarian.designation,
                            style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
