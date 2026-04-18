import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'add_librarian.dart';

class Librarian {
  final int id;
  final String name;
  final String designation;
  final String? photo;

  Librarian({required this.id, required this.name, required this.designation, this.photo});

  factory Librarian.fromJson(Map<String, dynamic> json) {
    return Librarian(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'Librarian',
      photo: json['photo'] ?? json['profile_image'],
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/users/6');

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> usersData = data['data'] ?? [];
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

  Future<void> _downloadLibrarianList() async {
    if (_librarians.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to download.")));
      return;
    }

    List<List<dynamic>> rows = [['ID', 'Name', 'Designation']];
    for (var lib in _librarians) {
      rows.add([lib.id, lib.name, lib.designation]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/librarian_list.csv';
      final file = File(path);
      await file.writeAsString(csv);
      await OpenFile.open(path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLibrarianPage()),
          );
          if (result == true && mounted) _fetchLibrarians();
        },
        label: Text("Add Librarian", style: theme.textTheme.labelLarge?.copyWith(fontSize: context.font(14))),
        icon: Icon(Icons.add, size: context.scale(20)),
      ),
      appBar: AppBar(
        title: Text("Librarian List", style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(icon: Icon(Icons.download, size: context.scale(24)), onPressed: _downloadLibrarianList),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _isLoading
                  ? Center(child: Padding(padding: EdgeInsets.all(context.scale(40)), child: const CircularProgressIndicator()))
                  : _error.isNotEmpty
                      ? Center(child: Text(_error, style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))))
                      : _librarians.isEmpty
                          ? Center(child: Text("No librarians found.", style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))))
                          : CustomLibrarianListBox(librarians: _librarians),
            ),
          ),
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
    final theme = context.theme;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("All Librarians", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
            SizedBox(height: context.scale(24)),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
                
                if (crossAxisCount > 1) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: librarians.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: context.scale(16),
                      mainAxisSpacing: context.scale(16),
                      mainAxisExtent: context.scale(80),
                    ),
                    itemBuilder: (context, index) => _buildLibrarianItem(context, librarians[index]),
                  );
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: librarians.length,
                    separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
                    itemBuilder: (context, index) => _buildLibrarianItem(context, librarians[index]),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrarianItem(BuildContext context, Librarian librarian) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(12)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            radius: context.scale(24),
            imageUrl: ApiService.getStorageUrl(librarian.photo),
          ),
          SizedBox(width: context.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(librarian.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(librarian.designation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: context.scale(20)),
        ],
      ),
    );
  }
}

