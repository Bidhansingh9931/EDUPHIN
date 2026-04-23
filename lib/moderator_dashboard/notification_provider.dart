import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'notification_model.dart';
import 'cache_helper.dart';

class NotificationProvider {
  // Added /api/ prefix to match standard Laravel API routing
  final String _notificationsApiUrl = "${ApiService.baseUrl}/api/notifications";
  static const String _cacheKey = 'notifications';

  Future<List<Message>?> getCachedMessages() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null) {
      return (cached as List).map((json) => Message.fromJson(json)).toList();
    }
    return null;
  }

  Future<List<Message>> fetchMessages({bool bypassCache = false}) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      debugPrint("Fetching notifications from: $_notificationsApiUrl");
      final response = await http.get(
        Uri.parse(_notificationsApiUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        debugPrint("Notifications API Response received.");
        final dynamic decodedBody = jsonDecode(response.body);

        // Handle cases where the list is nested under a key like 'data' or 'notifications'
        List<dynamic> jsonList;
        if (decodedBody is List) {
          jsonList = decodedBody;
        } else if (decodedBody is Map<String, dynamic>) {
          jsonList = decodedBody['notifications'] ?? decodedBody['data'] ?? [];
        } else {
          throw Exception("Unexpected response format.");
        }

        // Save to cache
        await CacheHelper.save(_cacheKey, jsonList);

        return jsonList.map((json) => Message.fromJson(json)).toList();
      } else {
        debugPrint(
            "Failed to load notifications. Status: ${response.statusCode}, Body: ${response.body}");
        return []; // Return empty list instead of throwing to avoid UI crash
      }
    } on TimeoutException {
      debugPrint("Notification fetch timed out.");
      return [];
    } catch (e) {
      debugPrint("An error occurred fetching notifications: $e");
      return [];
    }
  }
}
