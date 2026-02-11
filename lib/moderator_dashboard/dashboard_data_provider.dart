import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import 'dashboard_cards/testimonials_page.dart';
import 'dashboard_models.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/accounts.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/classes.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/events.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/exam_types.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/students.dart';

// Placeholder page for items that don't have a dedicated screen yet.
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("This is the placeholder page for $title.")),
    );
  }
}

class DashboardDataProvider {
  final String realApiUrl = "${ApiService.baseUrl}/moderator/dashboard";

  Future<DashboardData> fetchDashboardData() async {
    try {
      final String? token = await ApiService.getToken();
      if (token == null) {
        throw Exception("Authentication token not found. Please log in again.");
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      debugPrint("Attempting to fetch data from Laravel API: $realApiUrl");
      final response = await http
          .get(Uri.parse(realApiUrl), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Full API Response: ${response.body}");
        final jsonData = jsonDecode(response.body);
        debugPrint("Laravel API successful!");
        return _mapLaravelResponse(jsonData['data']);
      } else {
        debugPrint("API failed with status code: ${response.statusCode} and body: ${response.body}");
        throw Exception("Failed to load dashboard data. Status code: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Connection to API timed out.");
      throw Exception("Connection timed out. Your server is taking too long to respond.");
    } catch (e) {
      debugPrint("An error occurred while fetching dashboard data: $e");
      throw Exception("An error occurred: $e");
    }
  }

  DashboardData _mapLaravelResponse(Map<String, dynamic> data) {
    // --- 1. Parse Dashboard Cards (Grid Items) ---
    final Map<String, dynamic> counts = data['counts'] ?? {};
    final List<GridItem> gridItems = counts.entries.map((entry) {
      return GridItem(
        tag: entry.key,
        icon: _getIconData(entry.key),
        value: entry.value.toString(),
        title: entry.key[0].toUpperCase() + entry.key.substring(1).replaceAll('_', ' '), // Capitalize and format title
        percentage: 0, // Not provided by API
        isPositive: true, // Not provided by API
        page: _getPage(entry.key),
      );
    }).toList();

    // --- 2. Parse User Role Distribution (Pie Chart) ---
    final List roles = data['roles'] ?? [];
    int accountantsCount = 0;
    int staffCount = 0;
    int othersCount = 0;

    for (var role in roles) {
        final count = role['users_count'] as int? ?? 0;
        switch (role['name']) {
            case 'Accountants':
                accountantsCount = count;
                break;
            case 'Staff':
                staffCount = count;
                break;
            // Sum up other relevant roles into "Others"
            case 'Institute Manager':
            case 'Counselors':
            case 'Teachers':
            case 'Librarian':
          case 'Testimonials':
                othersCount += count;
                break;
        }
    }

    // --- 3. Parse Recent Activities ---
    final List<dynamic> activitiesData = data['recent_activities'] ?? [];
    final List<RecentActivity> recentActivities = activitiesData.map((activity) {
      return _mapActivity(activity);
    }).toList();

    return DashboardData(
      gridItems: gridItems,
      accountants: accountantsCount,
      staff: staffCount,
      others: othersCount,
      reviews: [], // API does not provide reviews, so we pass an empty list.
      databaseCount: data['database_size']?.toString() ?? 'N/A',
      dataUsage: data['total_data_usage']?.toString() ?? 'N/A',
      systemUptime: data['uptime']?.toString() ?? 'N/A',
      recentActivities: recentActivities,
    );
  }

  RecentActivity _mapActivity(Map<String, dynamic> activity) {
    String event = activity['event'] ?? '';
    IconData icon;
    Color color;

    switch (event) {
      case 'api_login':
      case 'login':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'api_logout':
      case 'logout':
        icon = Icons.logout;
        color = Colors.red;
        break;
      case 'update':
        icon = Icons.update;
        color = Colors.orange;
        break;
      case 'create':
         icon = Icons.add_circle;
         color = Colors.blue;
         break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    // Format the timestamp
    String timeString = 'Just now';
    if (activity['created_at'] != null) {
      try {
        final dateTime = DateTime.parse(activity['created_at']);
        final difference = DateTime.now().difference(dateTime);

        if (difference.inDays > 1) {
          timeString = DateFormat('MMM d').format(dateTime);
        } else if (difference.inHours > 1) {
          timeString = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 1) {
          timeString = '${difference.inMinutes}m ago';
        } else {
           timeString = 'Just now';
        }

      } catch (e) { /* Ignore parsing errors */ }
    }

    String model = activity['model'] ?? 'System';
    String description = "User ${activity['user_id']} performed action: $event on $model";

    // Make description more user-friendly
    if(event.contains('login')) {
      description = "User ${activity['user_id']} logged in";
    } else if (event.contains('logout')) {
      description = "User ${activity['user_id']} logged out";
    }


    return RecentActivity(
      icon: icon,
      color: color,
      text: description,
      time: timeString,
    );
  }

  IconData _getIconData(String key) {
    switch (key) {
      case 'accounts':
        return Icons.people_alt_outlined;
      case 'institutes':
        return Icons.school_outlined;
      case 'students':
        return Icons.person_outline;
      case 'classes':
        return Icons.class_outlined;
      case 'events':
        return Icons.event_available_outlined;
      case 'exam_types':
        return Icons.rule_folder_outlined;
       case 'testimonials':
        return Icons.comment_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _getPage(String pageName) {
    switch (pageName) {
      case 'accounts':
        return const AccountsPage(instituteId: "1");
      case 'institutes':
        return const InstitutesPage();
      case 'students':
        return const StudentsPage(instituteId: "1");
      case 'classes':
        return const ClassesPage(instituteId: "1");
      case 'events':
        return const EventsPage();
      case 'testimonials':
        return const TestimonialsPage();
      case 'exam_types':
        return const ExamTypesPage();
      default:
        return PlaceholderPage(title: pageName);
    }
  }

  Future<String?> downloadDashboardData(DashboardData data) async {
    try {
      // 1. Request storage permission
      if (Platform.isAndroid) {
        var status = await permission_handler.Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission was denied.');
        }
      }

      // 2. Get the directory
      Directory? directory;
      if (Platform.isAndroid) {
        // This may point to an app-specific directory.
        directory = (await getExternalStorageDirectories(type: StorageDirectory.downloads))?.first;
      }
      // Fallback for iOS or if the specific directory is not available.
      directory ??= await getApplicationDocumentsDirectory();

      final path = directory.path;
      final fileName = "eduphin_dashboard_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt";
      final file = File('$path/$fileName');

      // 3. Format the data into a string
      final content = _formatDashboardDataForDownload(data);

      // 4. Write the file
      await file.writeAsString(content);

      final fullPath = file.path;
      debugPrint("Dashboard data saved to: $fullPath");
      return fullPath;

    } catch (e) {
      debugPrint("Error downloading dashboard data: $e");
      return null;
    }
  }

  String _formatDashboardDataForDownload(DashboardData data) {
    final StringBuffer content = StringBuffer();
    content.writeln("Eduphin Dashboard Report");
    content.writeln("========================");
    content.writeln("Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}");
    content.writeln();

    content.writeln("--- Summary ---");
    for (var item in data.gridItems) {
      content.writeln("${item.title}: ${item.value}");
    }
    content.writeln();

    content.writeln("--- User Role Distribution ---");
    content.writeln("Accountants: ${data.accountants}");
    content.writeln("Staff: ${data.staff}");
    content.writeln("Others: ${data.others}");
    content.writeln();

    content.writeln("--- System Information ---");
    content.writeln("Database Size: ${data.databaseCount}");
    content.writeln("Total Data Usage: ${data.dataUsage}");
    content.writeln("System Uptime: ${data.systemUptime}");
    content.writeln();

    content.writeln("--- Recent Activities ---");
    for (var activity in data.recentActivities) {
      content.writeln("[${activity.time}] ${activity.text}");
    }
    return content.toString();
  }
}
