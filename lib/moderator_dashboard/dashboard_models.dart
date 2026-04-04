
// import 'package:eduphin/moderator_dashboard/all_review.dart';
// import 'package:eduphin/moderator_dashboard/all_testimonials.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

import 'dashboard_cards/testimonials_page.dart';

class GridItem {
  final String tag;
  final IconData icon;
  final String value;
  final String title;
  final double percentage;
  final bool isPositive;
  final Widget page;

  GridItem({
    required this.tag,
    required this.icon,
    required this.value,
    required this.title,
    required this.percentage,
    required this.isPositive,
    required this.page,
  });
}

class Review {
  final String name;
  final String school;
  final double rating;
  final String review;
  final String avatarAsset;

  Review({
    required this.name,
    required this.school,
    required this.rating,
    required this.review,
    required this.avatarAsset,
  });

  // The API response doesn't contain detailed reviews, so this will be populated with placeholder data.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] ?? 'N/A',
      school: json['school'] ?? 'N/A',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'] ?? '',
      avatarAsset: json['avatarAsset'] ?? '',
    );
  }
}
class Testimonial {
  final String name;
  final String school;
  final String review;
  final String avatarAsset;

  Testimonial({
    required this.name,
    required this.school,
    required this.review,
    required this.avatarAsset,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      name: json['name'] ?? 'N/A',
      school: json['school'] ?? 'N/A',
      review: json['review'] ?? '',
      avatarAsset: json['avatarAsset'] ?? '',
    );
  }
}
class RecentActivity {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  RecentActivity({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    String event = json['event'] ?? 'unknown';
    // The model path can be long, like 'App\Models\User'. Get the last part.
    String model = json['model']?.toString().split('\\').last ?? 'item';
    String description = "User #${json['user_id']} triggered '$event' on $model #${json['model_id']}";

    String time = 'some time ago';
    if (json['created_at'] != null) {
      try {
        final dateTime = DateTime.parse(json['created_at']);
        final difference = DateTime.now().difference(dateTime);
        if (difference.inDays > 1) {
          time = '${difference.inDays} days ago';
        } else if (difference.inDays == 1) {
          time = '1 day ago';
        } else if (difference.inHours > 1) {
          time = '${difference.inHours} hours ago';
        } else if (difference.inHours == 1) {
          time = '1 hour ago';
        } else if (difference.inMinutes > 1) {
          time = '${difference.inMinutes} minutes ago';
        } else {
          time = 'just now';
        }
      } catch (e) {
        // Keep default time if parsing fails.
      }
    }

    IconData iconData = Icons.info_outline;
    Color color = Colors.grey;
    if (event.contains('login')) {
      iconData = Icons.login;
      color = Colors.green;
    } else if (event.contains('create')) {
      iconData = Icons.add_circle_outline;
      color = Colors.blue;
    } else if (event.contains('update')) {
      iconData = Icons.edit;
      color = Colors.orange;
    } else if (event.contains('delete')) {
      iconData = Icons.delete_outline;
      color = Colors.red;
    }

    return RecentActivity(
      icon: iconData,
      color: color,
      text: description,
      time: time,
    );
  }
}

class DashboardData {
  final List<GridItem> gridItems;
  final List<Review> reviews;
  final String databaseCount;
  final String dataUsage;
  final String systemUptime;
  final List<RecentActivity> recentActivities;
   final List<Testimonial> testimonials;

  DashboardData({
    required this.gridItems,
    required this.reviews,
    required this.databaseCount,
    required this.dataUsage,
    required this.systemUptime,
    required this.recentActivities,
    required this.testimonials,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final List<GridItem> gridItems = [];

    // Manually add institutes to the grid items
    final int institutesCount = (json['counts'] as Map<String, dynamic>?)?['institutes'] ?? 0;
    gridItems.add(GridItem(tag: 'institutes', icon: Icons.school, value: institutesCount.toString(), title: 'Institutes', percentage: 0, isPositive: true, page: const InstitutesPage()));
      final int testimonialCount = (json['counts'] as Map<String, dynamic>?)?['testimonials'] ?? 0;
    gridItems.add(GridItem(tag: 'testimonials', icon: Icons.comment, value: testimonialCount.toString(), title: 'Testimonials', percentage: 0, isPositive: true, page: const TestimonialsPage()));


    for (var role in roles) {
      final roleName = role['name'] as String? ?? 'Unnamed Role';
      final count = (role['users_count'] as num?)?.toInt() ?? 0;
      gridItems.add(
        GridItem(
          tag: roleName.toLowerCase(),
          icon: _getIconForRole(roleName),
          value: count.toString(),
          title: roleName,
          percentage: 0,
          isPositive: true,
          page: Container(), // Replace with actual page later
        ),
      );
    }
    
    final activitiesList = (json['recent_activities'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final recentActivities = activitiesList.map((i) => RecentActivity.fromJson(i)).toList();

    final List<Review> reviews = List.generate(testimonialCount, (index) => Review(
      name: 'User ${index + 1}',
      school: 'Eduphin Institute',
      rating: 5.0,
      review: 'This is a great platform!',
      avatarAsset: '',
    ));
 final testimonialsList = (json['testimonials'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final testimonials = testimonialsList.map((i) => Testimonial.fromJson(i)).toList();
    return DashboardData(
      gridItems: gridItems,
      reviews: reviews,
      databaseCount: json['database_size']?.toString() ?? 'N/A',
      dataUsage: json['total_data_usage']?.toString() ?? 'N/A',
      systemUptime: json['uptime']?.toString() ?? 'N/A',
      recentActivities: recentActivities,
      testimonials: testimonials,
    );
  }

  static IconData _getIconForRole(String roleName) {
    switch (roleName) {
      case 'Accountants':
        return Icons.person;
      case 'Staff':
        return Icons.group;
      case 'Counselors':
        return Icons.support_agent;
      case 'Teachers':
        return Icons.school;
      case 'Librarian':
        return Icons.local_library;
      default:
        return Icons.person_outline;
    }
  }
}
