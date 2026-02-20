import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dashboard_models.dart';

class DashboardDataProvider {
  Future<DashboardData> fetchDashboardData() async {
    try {
      final response = await ApiService.get('moderator/dashboard');

      if (kDebugMode) {
        print('API Response Status Code: \${response.statusCode}');
      }

      if (response.statusCode == 200) {
        try {
          final responseBody = json.decode(response.body);
          if (kDebugMode) {
            print('API Response Body: $responseBody');
          }

          // The actual dashboard data is nested under the 'data' key.
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return DashboardData.fromJson(responseBody['data']);
          } else {
            // Handle cases where success is false or data is null.
            throw Exception('API call successful but returned no data or indicated failure.');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing dashboard data: $e');
          }
          throw Exception('Failed to load dashboard data.');
        }
      } else {
        if (kDebugMode) {
          print('API responded with error code: \${response.statusCode}');
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

  DashboardData _emptyDashboardData() {
    return DashboardData(
      gridItems: [
        GridItem(tag: 'institutes', icon: Icons.school, value: '0', title: 'Institutes', percentage: 0, isPositive: true, page: Container()),
        GridItem(tag: 'accountants', icon: Icons.person, value: '0', title: 'Accountants', percentage: 0, isPositive: true, page: Container()),
        GridItem(tag: 'staff', icon: Icons.group, value: '0', title: 'Staff', percentage: 0, isPositive: true, page: Container()),
        GridItem(tag: 'others', icon: Icons.person_outline, value: '0', title: 'Others', percentage: 0, isPositive: true, page: Container()),
      ],
      accountants: 0,
      staff: 0,
      others: 0,
      institutes: 0,
      reviews: [],
      databaseCount: 'N/A',
      dataUsage: 'N/A',
      systemUptime: 'N/A',
      recentActivities: [],
    );
  }
}
