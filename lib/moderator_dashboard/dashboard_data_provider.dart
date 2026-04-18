import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dashboard_models.dart';

class DashboardDataProvider {
  Future<DashboardData> fetchDashboardData() async {
    try {
      final responses = await Future.wait([
        ApiService.get('moderator/dashboard'),
        ApiService.get('moderator/profile'),
      ]);

      final dashboardResponse = responses[0];
      final profileResponse = responses[1];

      if (kDebugMode) {
        print('Dashboard API Response Status Code: ${dashboardResponse.statusCode}');
        print('Profile API Response Status Code: ${profileResponse.statusCode}');
      }

      if (dashboardResponse.statusCode == 200) {
        try {
          final dashboardBody = json.decode(dashboardResponse.body);
          Map<String, dynamic>? profileBody;

          if (profileResponse.statusCode == 200) {
            profileBody = json.decode(profileResponse.body);
          }

          if (kDebugMode) {
            print('Dashboard API Response Body: $dashboardBody');
            if (profileBody != null) {
              print('Profile API Response Data: $profileBody');
            }
          }

          // The actual dashboard data is nested under the 'data' key.
          if (dashboardBody['success'] == true && dashboardBody['data'] != null) {
            return DashboardData.fromJson(dashboardBody['data'], profileJson: profileBody);
          } else {
            // Handle cases where success is false or data is null.
            throw Exception('Dashboard API call successful but returned no data or indicated failure.');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing dashboard data: $e');
          }
          throw Exception('Failed to load dashboard data.');
        }
      } else {
        if (kDebugMode) {
          print('Dashboard API responded with error code: ${dashboardResponse.statusCode}');
        }
        throw Exception('Failed to load dashboard data.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while fetching dashboard data: $e');
      }
      // Re-throw the exception to be handled by the FutureBuilder.
      throw Exception('An error occurred: $e');
    }
  }
}
