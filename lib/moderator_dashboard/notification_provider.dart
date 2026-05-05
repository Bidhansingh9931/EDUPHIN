import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
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
      throw ApiException("Session expired. Please log in again.", statusCode: 401);
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

        List<dynamic> jsonList;
        if (decodedBody is List) {
          jsonList = decodedBody;
        } else if (decodedBody is Map<String, dynamic>) {
          jsonList = decodedBody['notifications'] ?? decodedBody['data'] ?? [];
        } else {
          throw ApiException("Received invalid data from server.");
        }

        await CacheHelper.save(_cacheKey, jsonList);

        return jsonList.map((json) => Message.fromJson(json)).toList();
      } else {
        throw ApiException("Failed to load notifications", statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

