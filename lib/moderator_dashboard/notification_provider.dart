import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'notification_model.dart';

class NotificationProvider {
  final String _notificationsApiUrl = "${ApiService.baseUrl}/notifications";

  Future<List<Message>> fetchMessages() async {
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

        return jsonList.map((json) => Message.fromJson(json)).toList();
      } else {
        debugPrint(
            "Failed to load notifications. Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception(
            "Failed to load notifications. Status: ${response.statusCode}\nBody: ${response.body}");
      }
    } on TimeoutException {
      throw Exception("Connection timed out. Please check your network.");
    } catch (e) {
      debugPrint("An error occurred fetching notifications: $e");
      rethrow;
    }
  }
}
