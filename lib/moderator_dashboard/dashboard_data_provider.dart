import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'dashboard_models.dart';
import 'cache_helper.dart';

class DashboardDataProvider {
  static const String _cacheKey = 'dashboard_data';

  Future<DashboardData?> getCachedData() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null) {
      try {
        return DashboardData.fromJson(cached['dashboard'], profileJson: cached['profile']);
      } catch (e) {
        if (kDebugMode) print('Error parsing cached dashboard data: $e');
      }
    }
    return null;
  }

  Future<DashboardData> fetchDashboardData({bool bypassCache = false}) async {
    try {
      final responses = await Future.wait([
        ApiService.get('moderator/dashboard'),
        ApiService.get('moderator/profile'),
      ]);

      final dashboardResponse = responses[0];
      final profileResponse = responses[1];

      if (dashboardResponse.statusCode == 200) {
        final dashboardBody = json.decode(dashboardResponse.body);
        Map<String, dynamic>? profileBody;

        if (profileResponse.statusCode == 200) {
          profileBody = json.decode(profileResponse.body);
        }

        if (dashboardBody['success'] == true && dashboardBody['data'] != null) {
          await CacheHelper.save(_cacheKey, {
            'dashboard': dashboardBody['data'],
            'profile': profileBody,
          });
          
          return DashboardData.fromJson(dashboardBody['data'], profileJson: profileBody);
        } else {
          throw ApiException(dashboardBody['message'] ?? 'Failed to load dashboard data');
        }
      } else {
        throw ApiException('Failed to load dashboard data', statusCode: dashboardResponse.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

