import 'package:eduphin/services/error_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_edit_testimonial_page.dart';

// Model for a single testimonial, matching the backend structure.
class Testimonial {
  final int id;
  final String name;
  final String designation;
  final String message;
  final String? image;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Testimonial({
    required this.id,
    required this.name,
    required this.designation,
    required this.message,
    this.image,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    // Helper function for robust date parsing.
    DateTime? safeParseDateTime(dynamic dateString) {
      if (dateString is String) {
        return DateTime.tryParse(dateString);
      }
      return null;
    }

    return Testimonial(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      designation: json['designation'] ?? 'N/A',
      message: json['message'] ?? '',
      image: json['image'],
      status: json['status'] ?? 1,
      createdAt: safeParseDateTime(json['created_at']),
      updatedAt: safeParseDateTime(json['updated_at']),
    );
  }
}

// Provider to interact with the testimonial API.
class TestimonialProvider {
  static const String _cacheKey = 'moderator_testimonials_list';

  Future<List<Testimonial>> fetchTestimonials({bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await CacheHelper.load(_cacheKey);
        if (cached != null && cached is List) {
          return cached.map((e) => Testimonial.fromJson(e)).toList();
        }
      }
      final response = await ApiService.get('moderator/testimonials');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        List<dynamic> testimonialsData;
        if (body is List) {
          testimonialsData = body;
        } else if (body is Map<String, dynamic> && body['data'] is List) {
          testimonialsData = body['data'];
        } else {
          throw ApiException('Received invalid data from server.');
        }

        await CacheHelper.save(_cacheKey, testimonialsData);
        return testimonialsData.map((json) => Testimonial.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException('Failed to load testimonials', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Testimonial>?> getCachedTestimonials() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null && cached is List) {
      return cached.map((e) => Testimonial.fromJson(e)).toList();
    }
    return null;
  }

  Future<void> deleteTestimonial(int id) async {
    try {
      final response = await ApiService.delete('moderator/testimonials/$id');

      if (response.statusCode == 200) {
        await CacheHelper.clear(_cacheKey);
      } else {
        throw ApiException('Failed to delete testimonial', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
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
  List<Testimonial>? _cachedTestimonials;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedTestimonials = await _provider.getCachedTestimonials();
    _fetchData();
  }

  Future<void> _fetchData({bool bypassCache = false}) async {
    setState(() {
      _testimonialsFuture = _provider.fetchTestimonials(bypassCache: bypassCache);
    });
    try {
      await _testimonialsFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  // Navigate to Add/Edit page and refresh if data was changed
  void _navigateAndRefresh({Testimonial? testimonial}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditTestimonialPage(testimonial: testimonial),
      ),
    );

    if (result == true) {
      _fetchData(bypassCache: true);
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _provider.deleteTestimonial(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Testimonial deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
          ),
        );
        _fetchData(bypassCache: true); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = context.theme;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.md),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          title: Text('Confirm Delete', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          content: Text(
              'Are you sure you want to delete this testimonial?',
              style: TextStyle(fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14), fontWeight: FontWeight.bold)),
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Testimonials', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined, size: context.scale(24)),
            onPressed: () => _navigateAndRefresh(),
          ),
          SizedBox(width: context.md),
        ],
      ),
      body: FutureBuilder<List<Testimonial>>(
        future: _testimonialsFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<Testimonial>>(
            snapshot: snapshot,
            cachedData: _cachedTestimonials,
            skeleton: const TestimonialSkeleton(),
            onRefresh: () async => _fetchData(bypassCache: true),
            builder: (testimonials) {
              if (testimonials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.reviews_outlined,
                          size: context.scale(64),
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3)),
                      SizedBox(height: context.md),
                      Text('No testimonials found.',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: context.font(16),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _fetchData(bypassCache: true),
                color: theme.colorScheme.primary,
                child: ListView.builder(
                  padding: context.pagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    return TestimonialCard(
                      testimonial: testimonials[index],
                      onDelete: () =>
                          _showDeleteConfirmation(testimonials[index].id),
                      onEdit: () =>
                          _navigateAndRefresh(testimonial: testimonials[index]),
                    );
                  },
                ),
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

  const TestimonialCard(
      {super.key,
      required this.testimonial,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final imageUrl = ApiService.getStorageUrl(testimonial.image);

    return Card(
      margin: EdgeInsets.only(bottom: context.md),
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileAvatar(
                  imageUrl: imageUrl,
                  radius: context.scale(24),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(testimonial.name,
                          style: TextStyle(
                              fontSize: context.font(16),
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface)),
                      Text(testimonial.designation,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: context.font(13),
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.md),
            Text(
              '"${testimonial.message}"',
              style: TextStyle(fontSize: context.font(15), height: 1.5, color: theme.colorScheme.onSurface),
            ),
            SizedBox(height: context.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (testimonial.createdAt != null)
                  Text(
                    DateFormat.yMMMd().format(testimonial.createdAt!),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: context.font(12),
                    ),
                  )
                else
                  const SizedBox(), // Keep alignment
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: theme.colorScheme.onSurfaceVariant, size: context.scale(20)),
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error, size: context.scale(20)),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
