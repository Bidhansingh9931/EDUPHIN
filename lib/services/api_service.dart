import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform, SocketException;
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/new_employee_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduphin/manager_dashboard/events/event_model.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employee_model.dart';

class ApiService {
  // =========================
  // BASE URL (WEB + MOBILE)
  // =========================
  static const String _envUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get baseUrl {
    if (kIsWeb) {
      return _envUrl;
    } else if (Platform.isAndroid) {
      // When running on the Android emulator, 10.0.2.2 points to the host machine's localhost.
      return 'http://10.0.2.2:8000';
    } else {
      // For other platforms like iOS simulator, localhost or 127.0.0.1 generally works.
      return _envUrl;
    }
  }

  static String get baseImageUrl => baseUrl;

  // =========================
  // INTERNAL URI BUILDER
  // =========================
  static Uri _uri(String endpoint) {
    return Uri.parse('$baseUrl/api/$endpoint');
  }

  // =========================
  // TOKEN HANDLING
  // =========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    try {
      await post('logout', {});
    } catch (_) {
      // silent
    }
  }

  // =========================
  // HEADERS
  // =========================
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // =========================
  // LOGIN
  // =========================
  static Future<int> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http
          .post(
        url,
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid server response.');
      }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['token'];
        final roleId = responseData['user']?['role_id'];

        if (token != null && roleId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return roleId;
        } else {
          throw Exception('Missing token or role.');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Login failed.');
      }
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // =========================
  // GET
  // =========================
  static Future<http.Response> get(String endpoint) async {
    try {
      return await http
          .get(_uri(endpoint), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('GET failed: $e');
    }
  }

  // =========================
  // POST (JSON)
  // =========================
  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      return await http
          .post(
        _uri(endpoint),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('POST failed: $e');
    }
  }

  // =========================
  // PUT
  // =========================
  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      return await http
          .put(
        _uri(endpoint),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('PUT failed: $e');
    }
  }

  // =========================
  // DELETE
  // =========================
  static Future<http.Response> delete(String endpoint) async {
    try {
      return await http
          .delete(_uri(endpoint), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('DELETE failed: $e');
    }
  }

  // =========================
  // MULTIPART
  // =========================
  static Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    Map<String, File>? files,
  }) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              entry.value.path,
            ),
          );
        }
      }

      return await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('Upload timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Multipart failed: $e');
    }
  }

  // =========================
  // SINGLE FILE UPLOAD
  // =========================
  static Future<http.StreamedResponse> postWithFile(
      String endpoint,
      Map<String, String> data,
      File file,
      String fileField,
      ) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(headers);
      request.fields.addAll(data);
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );

      return await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('Upload timed out.');
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // =========================
  // GET INSTITUTES
  // =========================
  static Future<List<Institute>> getInstitutes() async {
    try {
      final response = await get('moderator/institutes');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> instituteList = data['data'];
          return instituteList
              .map((json) => Institute.fromJson(json))
              .toList();
        } else {
          throw Exception('Failed to load institutes: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load institutes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching institutes: $e');
    }
  }

  // =========================
  // GET INSTITUTE DETAILS
  // =========================
  static Future<Institute> getInstituteDetails(String instituteId) async {
    try {
      final response = await get('moderator/institutes/$instituteId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Institute.fromJson(data['data']);
        } else {
          throw Exception('Failed to load institute details: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load institute details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching institute details: $e');
    }
  }

  // =========================
  // GET EMPLOYEES
  // =========================
  static Future<List<Employee>> getEmployees(String instituteId) async {
    try {
      final response = await get('moderator/institutes/$instituteId/accounts');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['accounts'] != null) {
          final List<dynamic> accountsJson = data['accounts'];
          return accountsJson.map((json) => Employee.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load accounts.');
        }
      } else {
        throw Exception('Failed to load employees. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }
  
  // =========================
  // ADD EMPLOYEE
  // =========================
  static Future<void> addEmployee(NewEmployee employee) async {
    final fields = employee.toApiData();
    final files = <String, File>{};

    if (employee.profileImage != null) {
      files['profile_image'] = employee.profileImage!;
    }

    try {
      final response = await postMultipart('moderator/accounts', fields, files: files);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(responseBody);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'An unknown error occurred');
        }
      } else {
        String errorMessage = 'Failed to add employee. Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(responseBody);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Ignore if the body is not valid JSON
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error adding employee: $e');
    }
  }

  // =========================
  // CREATE EVENT
  // =========================
  static Future<http.StreamedResponse> createEvent(Event event) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');

    final request =
    http.MultipartRequest('POST', _uri('manager/events'));
    request.headers.addAll(headers);

    request.fields.addAll({
      'title': event.title,
      'description': event.description,
      'venue': event.venue,
      'event_date': DateFormat('yyyy-MM-dd').format(event.eventDate),
      'start_time': event.startTime,
      'end_time': event.endTime,
      'is_ticketed': event.isTicketed ? '1' : '0',
      if (event.isTicketed) 'ticket_price': event.ticketPrice!,
      if (event.maxParticipants != null)
        'max_participants': event.maxParticipants!,
    });

    for (int i = 0; i < event.audience.length; i++) {
      request.fields['audience[$i]'] = event.audience[i];
    }

    if (event.image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', event.image!.path),
      );
    }

    return request.send();
  }

  // =========================
  // ADD CLASS
  // =========================
  static Future<Map<String, dynamic>> addClass(
      Map<String, dynamic> classData) async {
    final response = await post('manager/classes', classData);

    Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid server response.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to add class.');
    }
  }
}
