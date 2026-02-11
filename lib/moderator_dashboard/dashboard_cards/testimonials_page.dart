import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_edit_testimonial_page.dart';

// Model for a single testimonial, matching the backend structure.
class Testimonial {
  final int id;
  final String name;
  final String designation;
  final String message;
  final String? image;

  Testimonial({
    required this.id,
    required this.name,
    required this.designation,
    required this.message,
    this.image,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'N/A',
      message: json['message'] ?? '',
      image: json['image'],
    );
  }
}

// Provider to interact with the testimonial API.
class TestimonialProvider {
  Future<List<Testimonial>> fetchTestimonials() async {
    final token = await ApiService.getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/moderator/testimonials'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    // Logging to debug the server response.
    print('Testimonials API Response: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // CORRECTED: More robust JSON parsing to handle multiple possible structures.
      List<dynamic> testimonialsData;

      if (body is List) {
        testimonialsData = body;
      } else if (body is Map<String, dynamic> && body['data'] is List) {
        testimonialsData = body['data'];
      } else {
        // This will catch cases where 'data' is not a list or the structure is unexpected.
        throw Exception('Failed to parse testimonials: Unexpected JSON structure.');
      }

      return testimonialsData.map((json) => Testimonial.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load testimonials. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteTestimonial(int id) async {
    final token = await ApiService.getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/moderator/testimonials/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete testimonial.');
    }
  }
}

// The main page to display and manage testimonials.
class TestimonialsPage extends StatefulWidget {
  const TestimonialsPage({super.key});

  @override
  State<TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  final TestimonialProvider _provider = TestimonialProvider();
  late Future<List<Testimonial>> _testimonialsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _testimonialsFuture = _provider.fetchTestimonials();
    });
  }

  // Navigate to Add/Edit page and refresh if data was changed
  void _navigateAndRefresh({Testimonial? testimonial}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTestimonialPage(testimonial: testimonial),
      ),
    );

    if (result == true) {
      _fetchData();
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _provider.deleteTestimonial(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Testimonial deleted successfully'), backgroundColor: Colors.green),
        );
        _fetchData(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this testimonial?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Testimonials', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
            onPressed: () => _navigateAndRefresh(),
          ),
        ],
      ),
      body: FutureBuilder<List<Testimonial>>(
        future: _testimonialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No testimonials found.', style: TextStyle(color: Colors.white70)));
          }

          final testimonials = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              return TestimonialCard(
                testimonial: testimonials[index],
                onDelete: () => _showDeleteConfirmation(testimonials[index].id),
                onEdit: () => _navigateAndRefresh(testimonial: testimonials[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TestimonialCard({super.key, required this.testimonial, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (testimonial.image != null) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      imageUrl = '$baseUrl/storage/${testimonial.image}';
    }

    return Card(
      color: const Color(0xFF1B263B),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF0D1B2A),
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.person, color: Colors.white70, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(testimonial.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(testimonial.designation, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${testimonial.message}"',
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: onDelete,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
