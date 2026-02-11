
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduphin/manager_dashboard/events/event_model.dart';

class ApiService {
  // 1. UNIVERSAL BASE URL SOLUTION
  // Use --dart-define to set this at compile time.
  // Example: flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const String _envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

  static String get baseUrl {
    if (kIsWeb) {
      // For web, use the provided environment URL directly.
      return _envUrl;
    } else if (Platform.isAndroid) {
      // For Android, if the URL is localhost, map it to the emulator's special IP.
      // Otherwise, use the provided IP for real devices.
      if (_envUrl.contains('127.0.0.1') || _envUrl.contains('localhost')) {
        return 'http://10.0.2.2:8000';
      }
      return _envUrl;
    } else {
      // For desktop (Windows, macOS, Linux), use the environment URL.
      return _envUrl;
    }
  }

  static String get baseImageUrl => baseUrl;


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    try {
      // This might fail if the token is already invalid, so don't throw an error.
      await post('logout', {}); // Calls /api/logout
    } catch (e) {
      // Silently fail or log to a crash reporting service.
    }
  }

  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<int> login(String email, String password) async {
    // CORRECTED URL: Removed the unnecessary '/auth' segment.
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['token'];
        final roleId = responseData['user']?['role_id'];

        if (token != null && roleId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return roleId;
        } else {
          throw Exception('Login failed: Missing token or role ID in response.');
        }
      } else {
        // Use the message from the backend if available.
        throw Exception(responseData['message'] ?? 'An unknown error occurred.');
      }
    } on TimeoutException {
      throw Exception('The connection timed out. Please try again.');
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on HttpException {
      throw Exception("Couldn't find the server. Please check the address.");
    } on FormatException {
      throw Exception('Bad response format from the server.');
    } catch (e) {
      // Re-throw other exceptions to be handled by the UI.
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // All other methods correctly call /api/endpoint
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
    try {
      final headers = await _getHeaders();
      return await http.get(url, headers: headers).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The connection timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to fetch data: ${e.toString()}');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
    try {
      final headers = await _getHeaders();
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The connection timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to post data: ${e.toString()}');
    }
  }

    static Future<http.StreamedResponse> postMultipart(String endpoint, Map<String, String> fields, {Map<String, File>? files}) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(Map<String, String>.from(headers));
      request.fields.addAll(fields);

      if (files != null) {
        files.forEach((key, value) async {
          request.files.add(await http.MultipartFile.fromPath(key, value.path));
        });
      }

      return await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('The connection timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to send data: ${e.toString()}');
    }
  }


  // ... (the rest of your ApiService methods are structured correctly)
    static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
    try {
      final headers = await _getHeaders();
      return await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The connection timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to update data: ${e.toString()}');
    }
  }

  static Future<http.StreamedResponse> postWithFile(
      String endpoint, Map<String, String> data, File file, String fileField) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', url);

      headers.remove('Content-Type');
      request.headers.addAll(Map<String, String>.from(headers));

      request.fields.addAll(data);
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

      return await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('The file upload timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/api/$endpoint');
     try {
      final headers = await _getHeaders();
      return await http.delete(url, headers: headers).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('The connection timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to delete item: ${e.toString()}');
    }
  }

  static Future<http.StreamedResponse> createEvent(Event event) async {
    final url = Uri.parse('$baseUrl/api/manager/events');
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(Map<String, String>.from(headers));

      final fields = {
        'title': event.title,
        'description': event.description,
        'venue': event.venue,
        'event_date': DateFormat('yyyy-MM-dd').format(event.eventDate),
        'start_time': event.startTime,
        'end_time': event.endTime,
        'is_ticketed': event.isTicketed ? '1' : '0',
        if (event.isTicketed) 'ticket_price': event.ticketPrice!,
        if (event.maxParticipants != null) 'max_participants': event.maxParticipants!,
      };

      request.fields.addAll(fields);

      for (int i = 0; i < event.audience.length; i++) {
        request.fields['audience[$i]'] = event.audience[i];
      }

      if (event.image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', event.image!.path));
      }

      return request.send();
    } on TimeoutException {
      throw Exception('The event creation timed out.');
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> addClass(Map<String, dynamic> classData) async {
    try {
      final response = await post('manager/classes', classData);
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add class.');
      }
    } catch (e) {
      throw Exception('An error occurred while adding class: ${e.toString()}');
    }
  }
}
