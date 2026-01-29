
import 'package:flutter/material.dart';

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
}

class DashboardData {
  final List<GridItem> gridItems;
  final int accountants;
  final int staff;
  final int others;
  final List<Review> reviews;
  final String databaseCount;
  final String dataUsage;
  final String systemUptime;
  final List<RecentActivity> recentActivities;

  DashboardData({
    required this.gridItems,
    required this.accountants,
    required this.staff,
    required this.others,
    required this.reviews,
    required this.databaseCount,
    required this.dataUsage,
    required this.systemUptime,
    required this.recentActivities,
  });
}