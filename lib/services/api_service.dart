import 'package:eduphin/services/caching_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:eduphin/main.dart';
import 'package:eduphin/teacher/dashboard/class_models.dart';
import 'package:eduphin/teacher/dashboard/event_models.dart' as teacher_event;
import 'package:eduphin/teacher/dashboard/student_leave_model.dart' as leave_model;
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart' hide StudentLeave;
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/new_employee_model.dart' as moderator_employee;
import 'package:eduphin/models/new_student.dart' as global_student;
import 'package:eduphin/models/new_employee.dart' as global_employee;
import 'package:eduphin/librarian/librarian_models.dart' as librarian_model;
import 'package:eduphin/teacher/dashboard/library_models.dart' as teacher_library;
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart' as teacher_ticket_details;
import 'package:eduphin/teacher/dashboard/ticket_models.dart' as teacher_ticket;
import 'package:eduphin/teacher/dashboard/schedule_models.dart' as teacher_ticket_schedule;
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart' as teacher_view_schedule;
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart' as teacher_profile;
import 'package:eduphin/teacher/dashboard/salary_models.dart' as teacher_salary;
import 'package:eduphin/teacher/dashboard/exam_models.dart' as teacher_exam;
import 'package:eduphin/teacher/dashboard/study_material_model.dart' as teacher_study_material;
import 'package:eduphin/teacher/dashboard/my_class_model.dart' as teacher_my_class;
import 'package:eduphin/staff/staff_dashboard/staff_models.dart' as staff_model;
import 'package:eduphin/accountant/dashboard/accountant_dashboard_model.dart' as accountant_model;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduphin/manager_dashboard/events/event_model.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart' as moderator_institute;
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employee_model.dart';

import 'package:eduphin/student/student_dashboard_model.dart' as student_dashboard;
import 'package:eduphin/student/student_profile_model.dart' as student_profile;
import 'package:eduphin/student/student_virtual_id_model.dart' as student_id;
import 'package:eduphin/student/student_fee_model.dart' as student_fee;

class ApiService {
  static const String _envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://eduphin.com'
  );

  static String get baseUrl {
    return _envUrl;
  }

  static String get baseImageUrl => baseUrl;

  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    return "$baseUrl/storage/$path";
  }

  static Uri _uri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    String baseUrlString = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    // On Web, sometimes the browser or proxy might have issues with how URIs are constructed
    // Ensure we don't have double slashes after /api/
    String cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final uri = Uri.parse('$baseUrlString/api/$cleanEndpoint');
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    final roleId = prefs.get('role_id');
    if (roleId is int) return roleId;
    if (roleId is String) return int.tryParse(roleId);
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('role_id');
    await prefs.remove('user_name');
    await CacheService.clearAll();
    
    // Navigate to login page
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
    }

    try {
      // Use a direct http call to avoid infinite recursion if post() handles 401
      final token = await getToken();
      if (token != null) {
        await http.post(
          _uri('logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }

  static Future<void> handleUnauthorized() async {
    if (kDebugMode) {
      print('🚨 [AUTH] Unauthorized access (401). Logging out...');
    }
    await logout();
  }

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

  static Future<int> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(withAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['token'];
        final roleIdRaw = responseData['user']?['role_id'];
        final roleId = int.tryParse(roleIdRaw.toString()) ?? 0;
        final userName = responseData['user']?['name'];
        if (token != null && roleId != 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setInt('role_id', roleId);
          if (userName != null) await prefs.setString('user_name', userName);
          return roleId;
        } else {
          throw Exception('Missing token or invalid role.');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Clean up the error message to avoid "Exception: Exception: ..." nesting
      String message = e.toString().replaceFirst('Exception: ', '');
      if (!message.contains('Login failed')) {
        message = 'Login failed: $message';
      }
      throw Exception(message);
    }
  }

  static String errorMessage(http.Response response, String defaultMessage) {
    try {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          List<String> allErrors = [];
          errors.forEach((key, value) {
            if (value is List) {
              allErrors.addAll(value.map((e) => e.toString()));
            } else {
              allErrors.add(value.toString());
            }
          });
          return allErrors.join('\n');
        }
      }
      if (data['message'] != null) return data['message'];
      if (data['error'] != null) return data['error'];
    } catch (_) {}
    return defaultMessage;
  }

  static Future<http.Response> get(String endpoint, [Map<String, dynamic>? queryParameters]) async {
    final uri = _uri(endpoint, queryParameters);
    _logRequest('GET', uri);
    try {
      final response = await http.get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
      _logResponse('GET', uri, response);

      if (response.statusCode == 401) {
        await handleUnauthorized();
      }

      return response;
    } catch (e) {
      _logError('GET', uri, e);
      throw Exception('GET failed: $e');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final uri = _uri(endpoint);
    _logRequest('POST', uri, body: data);
    try {
      final response = await http.post(uri, headers: await _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      _logResponse('POST', uri, response);

      if (response.statusCode == 401) {
        await handleUnauthorized();
      }

      return response;
    } catch (e) {
      _logError('POST', uri, e);
      throw Exception('POST failed: $e');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final uri = _uri(endpoint);
    _logRequest('PUT', uri, body: data);
    try {
      final response = await http.put(uri, headers: await _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      _logResponse('PUT', uri, response);

      if (response.statusCode == 401) {
        await handleUnauthorized();
      }

      return response;
    } catch (e) {
      _logError('PUT', uri, e);
      throw Exception('PUT failed: $e');
    }
  }

  // Debug Logging Helpers
  static void _logRequest(String method, Uri uri, {Map<String, dynamic>? body}) {
    if (kDebugMode) {
      print('🚀 [API REQUEST] $method $uri');
      if (body != null) print('📦 Body: ${jsonEncode(body)}');
    }
  }

  static void _logResponse(String method, Uri uri, http.Response response) {
    if (kDebugMode) {
      final status = response.statusCode;
      final icon = status >= 200 && status < 300 ? '✅' : '❌';
      print('$icon [API RESPONSE] $method ($status) $uri');
      try {
        final decoded = jsonDecode(response.body);
        print('📄 Data: ${const JsonEncoder.withIndent('  ').convert(decoded)}');
      } catch (_) {
        print('📄 Body: ${response.body}');
      }
    }
  }

  static void _logError(String method, Uri uri, dynamic error) {
    if (kDebugMode) {
      print('🚨 [API ERROR] $method $uri: $error');
    }
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(_uri(endpoint), headers: await _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        await handleUnauthorized();
      }
      return response;
    } catch (e) {
      throw Exception('PATCH failed: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(_uri(endpoint), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        await handleUnauthorized();
      }
      return response;
    } catch (e) {
      throw Exception('DELETE failed: $e');
    }
  }

  static Future<http.StreamedResponse> postMultipart(String endpoint, Map<String, dynamic> fields, {Map<String, File>? files, bool forceMultipart = false}) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');
      if (kIsWeb) {
        // Some servers fail preflight if 'Accept' is application/json during multipart upload
        headers.remove('Accept');
      }
      
      final uri = _uri(endpoint);
      
      _logRequest('POST-MULTIPART', uri, body: fields);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (files != null) {
        for (final entry in files.entries) {
          if (kIsWeb) {
            throw Exception('Web uploads must use postMultipartFromBytes instead of postMultipart');
          } else {
            request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
          }
        }
      }
      final response = await request.send().timeout(const Duration(minutes: 5));
      if (response.statusCode == 401) {
        await handleUnauthorized();
      }
      return response;
    } catch (e) {
      throw Exception('Multipart failed: $e');
    }
  }

  static Future<http.StreamedResponse> postMultipartFromBytes(String endpoint, Map<String, dynamic> fields, {Map<String, Uint8List>? files, Map<String, String>? fileNames, bool forceMultipart = false}) async {
    try {
      final headers = await _getHeaders();
      // On Web, Content-Type must be handled by the browser for multipart
      headers.remove('Content-Type');
      if (kIsWeb) {
        // Some servers fail preflight if 'Accept' is application/json during multipart upload
        headers.remove('Accept');
      }
      
      // Some servers fail preflight if 'Accept' is application/json during multipart upload
      // We'll keep it as is for now, but ensure it's allowed.
      
      final uri = _uri(endpoint);

      _logRequest('POST-MULTIPART-BYTES', uri, body: fields);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (files != null) {
        for (final entry in files.entries) {
          final bytes = entry.value;
          if (bytes.isNotEmpty) {
            request.files.add(http.MultipartFile.fromBytes(
              entry.key, 
              bytes, 
              filename: fileNames?[entry.key] ?? 'upload.png'
            ));
          }
        }
      }
      
      final response = await request.send().timeout(const Duration(minutes: 5));
      if (response.statusCode == 401) {
        await handleUnauthorized();
      }
      return response;
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('Failed to fetch')) {
        errorMsg = "Connection failed. This is likely a CORS issue or your session expired. Try refreshing the page.";
      }
      throw Exception('Multipart failed: $errorMsg');
    }
  }

  static Future<http.StreamedResponse> postWithFile(String endpoint, Map<String, String> data, File file, String fileField) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(headers);
      request.fields.addAll(data);
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
      return await request.send().timeout(const Duration(minutes: 5));
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<List<librarian_model.IssuedBook>> getLibrarianOverdueBooks(Map<String, String> filters) async {
    final response = await get('librarian/overdue-books', filters);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final rawList = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (rawList as List).map<librarian_model.IssuedBook>((e) => librarian_model.IssuedBook.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load overdue books');
  }

  static Stream<List<librarian_model.IssuedBook>> getLibrarianOverdueBooksStream(Map<String, String> filters) => Stream.fromFuture(getLibrarianOverdueBooks(filters));

  static Future<List<staff_model.UserDetail>> getStaffEmployees(dynamic roleId) async {
    final encodedId = Uri.encodeComponent(roleId.toString());
    final response = await get('staff/accounts/$encodedId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final payload = data['data'] ?? data;
        final usersData = payload['users'] ?? payload['employees'] ?? (payload is List ? payload : []);
        List usersList = [];
        if (usersData is List) {
          usersList = usersData;
        } else if (usersData is Map) {
          usersList = usersData.values.toList();
        }
        return usersList.map((e) => staff_model.UserDetail.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load employees');
  }

  static Stream<List<staff_model.UserDetail>> getStaffEmployeesStream(dynamic roleId) => Stream.fromFuture(getStaffEmployees(roleId));

  // Staff Stream Wrappers
  static Stream<staff_model.StaffDashboardData> getStaffDashboardStream() => Stream.fromFuture(getStaffDashboard());
  static Stream<staff_model.UserDetail> getStaffProfileStream() => Stream.fromFuture(getStaffProfile());
  static Stream<List<staff_model.Exam>> getStaffExamsStream() => Stream.fromFuture(getStaffExams());
  static Stream<Map<String, dynamic>> getStaffExamScheduleStream(String examId) => Stream.fromFuture(getStaffExamSchedule(examId));
  static Stream<staff_model.SalaryPageData> getStaffSalariesStream() => Stream.fromFuture(getStaffSalaries());
  static Stream<staff_model.SalaryDetailData> getStaffSalarySlipStream(String salaryId) => Stream.fromFuture(getStaffSalaryDetails(salaryId));
  static Stream<List<teacher_ticket.SupportTicket>> getStaffTicketsStream(Map<String, String> filters) => Stream.fromFuture(getStaffTickets(filters));
  static Stream<List<teacher_ticket.SupportTicket>> getStaffAssignedTicketsStream(Map<String, String> filters) => Stream.fromFuture(getStaffAssignedTickets(filters));
  static Stream<teacher_ticket_details.TicketDetails> getStaffTicketDetailsStream(String ticketId) => Stream.fromFuture(getStaffTicketDetails(ticketId));
  static Stream<List<librarian_model.IssuedBook>> getStaffIssuedBooksStream(Map<String, String> filters) => Stream.fromFuture(getStaffIssuedBooks(filters));
  static Stream<teacher_library.BookPagination> getStaffLibraryBooksStream(Map<String, String> filters, int page) => Stream.fromFuture(getStaffLibraryBooks(filters, page));
  static Stream<List<staff_model.Event>> getStaffEventsStream({String? status, String? type}) => Stream.fromFuture(getStaffEvents(status: status, type: type));
  static Stream<List<staff_model.EventRegistration>> getStaffRegisteredEventsStream() => Stream.fromFuture(getStaffRegisteredEvents());
  static Stream<List<staff_model.Fee>> getStaffFeesStream() => Stream.fromFuture(getStaffFees());
  static Stream<staff_model.StudentFeeDetail> getStaffStudentFeeDetailStream(String studentId) => Stream.fromFuture(getStaffStudentFeeDetail(studentId));

  // Librarian Stream Wrappers
  static Stream<librarian_model.LibrarianDashboardData> getLibrarianDashboardStream() => Stream.fromFuture(getLibrarianDashboard());
  static Stream<List<librarian_model.ExamType>> getLibrarianExamsStream() => Stream.fromFuture(getLibrarianExams());
  static Stream<Map<String, dynamic>> getLibrarianExamScheduleStream(String examId) => Stream.fromFuture(getLibrarianExamSchedule(examId));
  static Stream<List<librarian_model.IssuedBook>> getLibrarianMyIssuedBooksStream([Map<String, String>? filters]) => Stream.fromFuture(getLibrarianMyIssuedBooks(filters));
  static Stream<List<librarian_model.IssuedBook>> getLibrarianIssuedBooksStream(Map<String, String> filters) => Stream.fromFuture(getLibrarianIssuedBooks(filters));
  static Stream<List<dynamic>> getIssueAuditLogsStream(String issueId) => Stream.fromFuture(getIssueAuditLogs(issueId));
  static Stream<Map<String, dynamic>> getIssueBookCreateDataStream() => Stream.fromFuture(getIssueBookCreateData());
  static Stream<Map<String, dynamic>> getEditIssueDataStream(String issueId) => Stream.fromFuture(getEditIssueData(issueId));
  static Stream<librarian_model.UserDetail> getLibrarianProfileStream() => Stream.fromFuture(getLibrarianProfile());
  static Stream<Map<String, dynamic>> getLibrarianSalariesStream() => Stream.fromFuture(getLibrarianSalaries());
  static Stream<teacher_library.BookPagination> getLibrarianBooksStream(Map<String, String> filters, int page) => Stream.fromFuture(getLibrarianBooks(filters, page));
  static Stream<List<librarian_model.Event>> getLibrarianEventsStream({String? status, String? type}) => Stream.fromFuture(getLibrarianEvents(status: status, type: type));
  static Stream<List<librarian_model.EventRegistration>> getLibrarianRegisteredEventsStream() => Stream.fromFuture(getLibrarianRegisteredEvents());
  static Stream<List<librarian_model.SupportTicket>> getLibrarianTicketsStream(Map<String, String> filters) => Stream.fromFuture(getLibrarianTickets(filters));
  static Stream<List<librarian_model.SupportTicket>> getLibrarianAssignedTicketsStream(Map<String, String> filters) => Stream.fromFuture(getLibrarianAssignedTickets(filters));
  static Stream<teacher_ticket_details.TicketDetails> getLibrarianTicketDetailsStream(String ticketId) => Stream.fromFuture(getLibrarianTicketDetails(ticketId));

  // Accountant Stream Wrappers
  static Stream<accountant_model.AccountantDashboardData> getAccountantDashboardStream() => Stream.fromFuture(getAccountantDashboard()).asBroadcastStream();
  static Stream<List<accountant_model.Event>> getAccountantEventsStream({String? status, String? type}) => Stream.fromFuture(getAccountantEvents(status: status, type: type)).asBroadcastStream();
  static Stream<List<accountant_model.EventRegistration>> getAccountantRegisteredEventsStream({String? status, String? type}) => Stream.fromFuture(getAccountantRegisteredEvents(status: status, type: type)).asBroadcastStream();
  static Stream<List<accountant_model.Exam>> getAccountantExamsStream() => Stream.fromFuture(getAccountantExams()).asBroadcastStream();
  static Stream<accountant_model.UserDetail> getAccountantProfileStream() => Stream.fromFuture(getAccountantProfile()).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantExamScheduleStream(String id) => Stream.fromFuture(getAccountantExamSchedule(id)).asBroadcastStream();
  static Stream<teacher_library.BookPagination> getAccountantLibraryBooksStream(Map<String, String> filters, int page) => Stream.fromFuture(getAccountantLibraryBooks(filters, page)).asBroadcastStream();
  static Stream<teacher_library.LendingPagination> getAccountantLendingBooksStream(Map<String, String> filters, int page) => Stream.fromFuture(getAccountantLendingBooks(filters, page)).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantStudentsStream(Map<String, String> filters) => Stream.fromFuture(getAccountantStudents(filters)).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantStudentFeeDetailsStream(String studentId) => Stream.fromFuture(getAccountantStudentFeeDetails(studentId)).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantMySalariesStream() => Stream.fromFuture(getAccountantMySalaries()).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantEmployeeSalaryStream(String id) => Stream.fromFuture(getAccountantEmployeeSalary(id)).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantSalaryDetailStream(String id, {String? employeeId, String? numericId}) => Stream.fromFuture(getAccountantSalaryDetail(id, employeeId: employeeId, numericId: numericId)).asBroadcastStream();
  static Stream<Map<String, dynamic>> getAccountantFeesStream() {
    return (() async* {
      while (true) {
        yield await getAccountantFees();
        await Future.delayed(const Duration(seconds: 10));
      }
    })().asBroadcastStream();
  }
  static Stream<List<accountant_model.UserDetail>> getEmployeesByRoleStream(dynamic roleId) => Stream.fromFuture(getEmployeesByRole(roleId)).asBroadcastStream();
  static Stream<teacher_ticket_details.TicketDetails> getTicketDetailsAccountantStream(String id) => Stream.fromFuture(getTicketDetailsAccountant(id)).asBroadcastStream();
  static Stream<List<teacher_ticket.SupportTicket>> getAccountantTicketsStream(Map<String, String> filters) => Stream.fromFuture(getAccountantTickets(filters)).asBroadcastStream();
  static Stream<List<teacher_ticket.SupportTicket>> getAccountantAssignedTicketsStream(Map<String, String> filters) => Stream.fromFuture(getAccountantAssignedTickets(filters)).asBroadcastStream();

  static Future<List<moderator_institute.Institute>> getInstitutes() async {
    final response = await get('moderator/institutes');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((json) => moderator_institute.Institute.fromJson(json)).toList();
    }
    throw Exception('Failed to load institutes');
  }

  static Future<moderator_institute.Institute> getInstituteDetails(String instituteId) async {
    final response = await get('moderator/institutes/$instituteId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return moderator_institute.Institute.fromJson(data['data']);
    }
    throw Exception('Failed to load institute details');
  }

  static Future<List<Employee>> getEmployees(String instituteId) async {
    final response = await get('moderator/institutes/$instituteId/accounts');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if ((data['success'] == true || data['status'] == true) && data['accounts'] != null) {
        return (data['accounts'] as List).map((json) => Employee.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load employees');
  }

  static Future<void> addEmployee(moderator_employee.NewEmployee employee) async {
    final fields = employee.toApiData();
    final files = employee.profileImage != null ? {'profile_image': employee.profileImage!} : null;
    final response = await postMultipart('moderator/accounts', fields, files: files);
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(responseBody);
      if (data['success'] == true || data['status'] == true) return;
    }
    throw Exception('Failed to add employee');
  }

  static Future<http.StreamedResponse> createEvent(Event event) async {
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    final request = http.MultipartRequest('POST', _uri('manager/events'));
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
      if (event.maxParticipants != null) 'max_participants': event.maxParticipants!,
    });
    for (int i = 0; i < event.audience.length; i++) {
      request.fields['audience[$i]'] = event.audience[i];
    }
    if (event.image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', event.image!.path));
    }
    return request.send();
  }

  static Future<Map<String, dynamic>> addClass(Map<String, dynamic> classData) async {
    final response = await post('manager/classes', classData);
    if (response.statusCode >= 200 && response.statusCode < 300) return jsonDecode(response.body);
    throw Exception('Failed to add class');
  }

  static Future<TeacherDashboardData> getTeacherDashboard() async {
    final response = await get('teacher/dashboard');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return TeacherDashboardData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load teacher dashboard');
  }

  static Future<AssignmentPageData> getAssignmentsPageData() async {
    final response = await get('teacher/assignments');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return AssignmentPageData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load assignments');
  }

  static Future<void> createAssignment(int scheduleId, String title, String? description, String dueDate, File attachment) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, 'due_date': dueDate, if (description != null) 'description': description};
    final files = {'attachment': attachment};
    final response = await postMultipart('teacher/assignments', fields, files: files);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to create assignment: $body');
    }
  }

  static Future<void> createAssignmentFromBytes(int scheduleId, String title, String? description, String dueDate, Uint8List attachmentBytes, String fileName) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, 'due_date': dueDate, if (description != null) 'description': description};
    final response = await postMultipartFromBytes('teacher/assignments', fields, files: {'attachment': attachmentBytes}, fileNames: {'attachment': fileName});
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to create assignment: $body');
    }
  }

  static Future<void> updateAssignment(int assignmentId, String title, String? description, String dueDate, File? attachment) async {
    final fields = {'title': title, 'due_date': dueDate, if (description != null) 'description': description};
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('teacher/assignments/$assignmentId/update', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to update assignment');
  }

  static Future<void> updateAssignmentFromBytes(int assignmentId, String title, String? description, String dueDate, Uint8List? attachmentBytes, String? fileName) async {
    final fields = {'title': title, 'due_date': dueDate, if (description != null) 'description': description};
    final files = attachmentBytes != null && fileName != null ? {'attachment': attachmentBytes} : null;
    final fileNames = fileName != null ? {'attachment': fileName} : null;
    final response = await postMultipartFromBytes('teacher/assignments/$assignmentId/update', fields, files: files, fileNames: fileNames);
    if (response.statusCode != 200) throw Exception('Failed to update assignment');
  }

  static Future<void> deleteAssignment(int assignmentId) async {
    final response = await delete('teacher/assignments/$assignmentId');
    if (response.statusCode != 200) throw Exception('Failed to update assignment');
  }

  static Future<Map<String, dynamic>> getAttendanceData(int scheduleId, String date) async {
    final response = await get('teacher/attendance/$scheduleId', {'date': date});
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load attendance');
  }

  static Future<void> markAttendance(int scheduleId, String date, Map<String, String> attendance, Map<String, String> remarks) async {
    final response = await post('teacher/attendance/$scheduleId', {'date': date, 'attendance': attendance, 'remarks': remarks});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to mark attendance');
  }

  static Future<List<leave_model.StudentLeave>> getStudentLeaveDetails() async {
    final response = await get('teacher/leave-details');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['leaves'] != null) return (data['leaves'] as List).map((i) => leave_model.StudentLeave.fromJson(i)).toList();
    }
    throw Exception('Failed to load leave details');
  }

  static Future<void> updateStudentLeaveStatus(int leaveId, String status, {String? remarks}) async {
    final response = await post('teacher/leave/$leaveId', {'status': status, if (remarks != null) 'remarks': remarks});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update leave status');
  }

  static Future<ClassesAndSectionsData> getTeacherClassesAndSections() async {
    final response = await get('teacher/classes');
    if (response.statusCode == 200) return ClassesAndSectionsData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load classes');
  }

  static Future<List<Event>> getEvents({String? status, String? type}) async {
    final query = <String, String>{if (status != null) 'status': status, if (type != null) 'type': type};
    final response = await get('teacher/events', query);
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return (jsonDecode(response.body)['events'] as List).map((e) => Event.fromJson(e)).toList();
    throw Exception('Failed to load events');
  }

  static Future<List<teacher_event.RegisteredEvent>> getRegisteredEvents({String? status, String? type}) async {
    final query = <String, String>{if (status != null) 'status': status, if (type != null) 'type': type};
    final response = await get('teacher/events/registered', query);
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return (jsonDecode(response.body)['registered_events'] as List).map((e) => teacher_event.RegisteredEvent.fromJson(e)).toList();
    throw Exception('Failed to load registered events');
  }

  static Future<void> registerForEvent(int eventId, {String? paymentId}) async {
    final response = await post('teacher/events/$eventId/register', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception('Failed to register for event');
  }

  // Librarian APIs
  static Future<librarian_model.LibrarianDashboardData> getLibrarianDashboard() async {
    final response = await get('librarian/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        return librarian_model.LibrarianDashboardData.fromJson(data['data'] ?? {});
      }
    }
    throw Exception('Failed to load librarian dashboard');
  }

  static Future<List<librarian_model.ExamType>> getLibrarianExams() async {
    final response = await get('librarian/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final list = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (list as List).map<librarian_model.ExamType>((e) => librarian_model.ExamType.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getLibrarianExamSchedule(String examId) async {
    final response = await get('librarian/exams/$examId/schedule');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        if (data['data'] is Map<String, dynamic>) return data['data'];
        if (data['data'] is List) return {'schedules': data['data']};
        return {};
      }
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<List<librarian_model.IssuedBook>> getLibrarianMyIssuedBooks([Map<String, String>? filters]) async {
    final response = await get('librarian/my-issued-books', filters ?? {});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final rawList = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (rawList as List).map<librarian_model.IssuedBook>((e) => librarian_model.IssuedBook.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load issued books');
  }

  static Future<List<librarian_model.IssuedBook>> getLibrarianIssuedBooks(Map<String, String> filters) async {
    final response = await get('librarian/issued-books', filters);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final rawList = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (rawList as List).map<librarian_model.IssuedBook>((e) => librarian_model.IssuedBook.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load issued books');
  }

  static Future<void> returnIssuedBook(String issueId) async {
    final response = await post('librarian/issued-books/$issueId/return', {});
    if (response.statusCode != 200) throw Exception('Failed to return book');
  }

  static Future<void> deleteIssuedBook(String issueId) async {
    final response = await delete('librarian/issued-books/$issueId');
    if (response.statusCode != 200) throw Exception('Failed to delete record');
  }

  static Future<List<dynamic>> getIssueAuditLogs(String issueId) async {
    final response = await get('librarian/issued-books/$issueId/logs');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load logs');
  }

  static Future<Map<String, dynamic>> getIssueBookCreateData() async {
    final response = await get('librarian/issued-books/create');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load data');
  }

  static Future<void> createIssuedBook(Map<String, dynamic> data) async {
    final response = await post('librarian/issued-books', data);
    if (response.statusCode != 200) throw Exception('Failed to issue book');
  }

  static Future<Map<String, dynamic>> getEditIssueData(String issueId) async {
    final response = await get('librarian/issued-books/$issueId/edit');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load edit data');
  }

  static Future<void> updateIssuedBook(String issueId, Map<String, dynamic> data) async {
    final response = await put('librarian/issued-books/$issueId', data);
    if (response.statusCode != 200) throw Exception('Failed to update record');
  }

  static Future<librarian_model.UserDetail> getLibrarianProfile() async {
    final response = await get('librarian/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return librarian_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load profile');
  }

  static Future<librarian_model.UserDetail> updateLibrarianProfile(Map<String, String> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('librarian/update-profile', data, files: files);
    final res = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return librarian_model.UserDetail.fromJson(decoded['data']);
    }
    throw Exception(errorMessage(res, 'Failed to update profile'));
  }

  static Future<Map<String, dynamic>> getLibrarianSalaries() async {
    final response = await get('librarian/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['success'] == true || data['status'] == true) return data['data'] ?? data;
        return data;
      }
    }
    final decoded = jsonDecode(response.body);
    throw Exception(decoded['message'] ?? 'Failed to load salaries');
  }

  static Future<Map<String, dynamic>> getLibrarianSalarySlip(String salaryId) async {
    final encodedId = Uri.encodeComponent(salaryId);

    // 1. Try librarian specific endpoint
    try {
      final response = await get('librarian/salary/$encodedId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == true || data['status'] == true) return data['data'] ?? data;
          return data;
        }
      }
    } catch (_) {}

    // 2. Fallback: Search in My Salaries list
    try {
      final response = await get('librarian/salary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['salaries'] ?? data['data']?['salaries'] ?? data['data'];
        if (list is List) {
          final record = list.firstWhere(
                (s) => s['id'].toString() == salaryId || s['encrypted_id']?.toString() == salaryId,
            orElse: () => null,
          );
          if (record != null) {
            return {
              'salary': record,
              'amount_in_words': 'Unavailable (Detailed view fallback)',
              'status': true
            };
          }
        }
      }
    } catch (_) {}

    throw Exception('Failed to load salary slip');
  }

  static Future<teacher_library.BookPagination> getLibrarianBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters);

    // Clean filters: remove "All", empty strings, and map 'year' to 'publication_year'
    query.removeWhere((k, v) => v.isEmpty || v.toLowerCase() == 'all');
    if (query.containsKey('year')) {
      query['publication_year'] = query.remove('year')!;
    }

    query['page'] = page.toString();

    final response = await get('librarian/books', query);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Pass the top-level 'data' object. Our updated model will look inside it
      // for 'books' and metadata like 'total: 257'.
      return teacher_library.BookPagination.fromJson(decoded['data'] ?? decoded);
    }
    throw Exception('Failed to load books');
  }

  static Future<void> createLibrarianBook(Map<String, dynamic> data) async {
    final response = await post('librarian/books', data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to add book');
    }
  }

  static Future<void> updateLibrarianBook(String bookId, Map<String, dynamic> data) async {
    final response = await post('librarian/books/$bookId', data);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to update book');
    }
  }

  static Future<void> deleteLibrarianBook(String bookId) async {
    final response = await delete('librarian/books/$bookId');
    if (response.statusCode != 200) throw Exception('Failed to delete book');
  }

  static Future<List<librarian_model.Event>> getLibrarianEvents({String? status, String? type}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    final response = await get('librarian/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final list = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (list as List).map<librarian_model.Event>((e) => librarian_model.Event.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load events');
  }

  static Future<void> librarianRegisterForEvent(String eventId) async {
    final response = await post('librarian/events/register/$eventId', {});
    if (response.statusCode != 200) throw Exception('Failed to register');
  }

  static Future<List<librarian_model.EventRegistration>> getLibrarianRegisteredEvents() async {
    final response = await get('librarian/events/registered');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final list = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (list as List).map<librarian_model.EventRegistration>((e) => librarian_model.EventRegistration.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> cancelLibrarianEventRegistration(String registrationId) async {
    final response = await post('librarian/events/cancel/$registrationId', {});
    if (response.statusCode != 200) throw Exception('Failed to cancel');
  }

  static Future<List<librarian_model.SupportTicket>> getLibrarianTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('librarian/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final list = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (list as List).map<librarian_model.SupportTicket>((j) => librarian_model.SupportTicket.fromJson(j)).toList();
      }
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<librarian_model.SupportTicket>> getLibrarianAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('librarian/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final list = (data['data'] is List) ? data['data'] : (data['data']?['data'] as List? ?? []);
        return (list as List).map<librarian_model.SupportTicket>((j) => librarian_model.SupportTicket.fromJson(j)).toList();
      }
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<void> createLibrarianTicket(Map<String, dynamic> data) async {
    final response = await post('librarian/tickets', data);
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  static Future<void> updateLibrarianTicketStatus(String ticketId, String status) async {
    final response = await post('librarian/tickets/status/$ticketId', {'status': status});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update status');
  }

  static Future<teacher_ticket_details.TicketDetails> getLibrarianTicketDetails(String ticketId) async {
    final response = await get('librarian/tickets/$ticketId/replies');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return teacher_ticket_details.TicketDetails.fromJson(data['data']);
    }
    throw Exception('Failed to load ticket details');
  }

  static Future<void> replyLibrarianTicket(String ticketId, Map<String, String> fields, {File? attachment}) async {
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('librarian/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to add reply');
  }

  static Future<staff_model.StaffVirtualIdCardData> getLibrarianVirtualIdCard() async {
    final response = await get('librarian/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        return staff_model.StaffVirtualIdCardData.fromJson(data['data'] ?? {});
      }
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Stream<staff_model.StaffVirtualIdCardData> getLibrarianVirtualIdCardStream() => Stream.fromFuture(getLibrarianVirtualIdCard());

  static Future<teacher_ticket_details.TicketDetails> getTicketDetailsAccountant(String id) async {
    // Attempt 1: General accountant see-reply endpoint (Matches PHP seeReply method)
    var response = await get('accountants/tickets/see-reply/$id');

    // Attempt 2: Specific accountant view endpoint
    if (response.statusCode != 200) {
      final altResponse = await get('accountants/tickets/view/$id');
      if (altResponse.statusCode == 200) response = altResponse;
    }

    // Attempt 3: Standard REST-style endpoint
    if (response.statusCode != 200) {
      final altResponse2 = await get('accountants/tickets/$id');
      if (altResponse2.statusCode == 200) response = altResponse2;
    }

    // Attempt 4: Laravel common pattern for replies
    if (response.statusCode != 200) {
      final altResponse3 = await get('accountants/tickets/$id/replies');
      if (altResponse3.statusCode == 200) response = altResponse3;
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final payload = data['data'] ?? data;

        if (payload is Map<String, dynamic>) {
          if (payload.containsKey('ticket')) {
            return teacher_ticket_details.TicketDetails.fromJson(payload);
          }
          if (payload.containsKey('id') || payload.containsKey('title')) {
            return teacher_ticket_details.TicketDetails(
              ticket: teacher_ticket.SupportTicket.fromJson(payload),
              replies: (payload['replies'] as List? ?? []).map((r) => teacher_ticket_details.TicketReply.fromJson(r as Map<String, dynamic>)).toList(),
            );
          }
        }
      }
      if (data['message'] != null) throw Exception(data['message']);
    }

    throw Exception('Failed to load ticket details (Status: ${response.statusCode})');
  }

  static Future<void> replyAccountantTicket(String id, Map<String, String> fields, {File? attachment}) async {
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('accountants/tickets/reply/$id', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to reply');
  }

  static Future<void> updateAccountantTicketStatus(String id, String status) async {
    final response = await post('accountants/tickets/status/$id', {'status': status});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update status');
  }

  static Future<List<teacher_ticket.SupportTicket>> getAccountantTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('accountants/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<teacher_ticket.SupportTicket>> getAccountantAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('accountants/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<Map<String, dynamic>> getAccountantStudentFeeDetails(String studentId) async {
    final encodedId = Uri.encodeComponent(studentId);
    // Attempt 1: The ID-specific endpoint (studentId could be encrypted or numeric)
    var response = await get('accountants/students/$encodedId');

    // Attempt 2: Laravel standard 'view' pattern
    if (response.statusCode != 200) {
      final altResponse = await get('accountants/students/view/$encodedId');
      if (altResponse.statusCode == 200) response = altResponse;
    }

    // Attempt 3: Specific 'show' pattern if previous failed
    if (response.statusCode != 200) {
      final altResponse2 = await get('accountants/students/show/$encodedId');
      if (altResponse2.statusCode == 200) response = altResponse2;
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        return data['data'] ?? data;
      }
      if (data['message'] != null) throw Exception(data['message']);
    }

    // If we reach here, check if it's a 500 error specifically on a numeric ID
    if (response.statusCode == 500 && RegExp(r'^\d+$').hasMatch(studentId)) {
      throw Exception('Server error (500). The backend may require an ENCRYPTED student ID instead of "$studentId".');
    }

    throw Exception('Failed to load student fee details (Status: ${response.statusCode})');
  }

  static Future<void> storeAccountantPayment(Map<String, dynamic> data) async {
    final response = await post('accountants/students/payment', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store payment');
  }

  static Future<void> storeFeeOverride(String studentId, String feeId, Map<String, dynamic> data) async {
    final encodedStudentId = Uri.encodeComponent(studentId);
    final encodedFeeId = Uri.encodeComponent(feeId);
    final response = await post('accountants/fee-override/$encodedStudentId/$encodedFeeId', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store fee override');
  }

  static Future<void> storeOrUpdateFine(Map<String, dynamic> data) async {
    final response = await post('accountants/fines/store-update', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to save fine');
  }

  static Future<void> deleteFine(String fineId) async {
    final response = await delete('accountants/fines/delete/$fineId');
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete fine');
  }

  static Future<Map<String, dynamic>> getAccountantMySalaries() async {
    final response = await get('accountants/my-salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load salaries');
  }

  static Future<Map<String, dynamic>> getAccountantEmployeeSalary(String id) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await get('accountants/account/$encodedId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load employee salary');
  }

  static Future<Map<String, dynamic>> getAccountantSalaryDetail(String id, {String? employeeId, String? numericId}) async {
    final encodedId = Uri.encodeComponent(id);

    // 1. Try accountant specific endpoint
    try {
      final response = await get('accountants/salary/view/$encodedId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == true) return data['data'];
      }
    } catch (_) {}

    // 2. Try POST with ID in body
    try {
      final response = await post('accountants/salary/view', {'id': id});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == true) return data['data'];
      }
    } catch (_) {}

    // 3. Fallback: Search in My Salaries or Employee Salaries list
    try {
      final String endpoint = employeeId != null ? 'accountants/account/${Uri.encodeComponent(employeeId)}' : 'accountants/my-salary';
      final response = await get(endpoint);
      if (response.statusCode == 200) {
        final dataMap = jsonDecode(response.body);
        final data = dataMap['data'] ?? dataMap;
        
        dynamic list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = data['salaries'] ?? (data['data'] is Map ? data['data']['salaries'] : data['data']);
        }

        if (list is List) {
          final record = list.firstWhere(
            (s) {
              final sId = s['id']?.toString();
              final sEncId = s['encrypted_id']?.toString() ?? s['encryptedId']?.toString();
              return (numericId != null && sId == numericId) || sId == id || sEncId == id;
            },
            orElse: () => null,
          );
          if (record != null) {
            return {
              'salary': record,
              'amount_in_words': '',
              'status': true
            };
          }
        }
      }
    } catch (_) {}

    throw Exception('Failed to load salary detail');
  }

  static Future<void> deleteAccountantSalary(String id) async {
    final encodedId = Uri.encodeComponent(id);
    var response = await delete('accountants/salary/destroy/$encodedId');
    
    if (response.statusCode != 200) {
      if (response.statusCode == 500 || response.body.contains('DecryptException')) {
        // Fallback: try POST to delete endpoint with ID in body
        final altResponse = await post('accountants/salary/destroy', {'id': id});
        if (altResponse.statusCode == 200) return;

        // Try POST to parameterized URL
        final postResponse = await post('accountants/salary/destroy/$encodedId', {});
        if (postResponse.statusCode == 200) return;
      }
      
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete salary (Status: ${response.statusCode})');
    }
  }

  static Future<void> storeAccountantEmployeeSalary(String id, Map<String, dynamic> data) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await post('accountants/salary/store/$encodedId', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store salary');
  }

  static Future<teacher_library.BookPagination> getLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('teacher/library/books', query);
    if (response.statusCode == 200) return teacher_library.BookPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load books');
  }

  static Future<teacher_library.LendingPagination> getLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('teacher/library/lending', query);
    if (response.statusCode == 200) return teacher_library.LendingPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load lending books');
  }

  static Future<teacher_library.LendingPagination> getAccountantLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('accountants/library/lending', query);
    if (response.statusCode == 200) return teacher_library.LendingPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load lending data');
  }

  static Future<List<teacher_ticket.SupportTicket>> getMyTickets(Map<String, String> filters) async => _getTickets('teacher/tickets', filters);
  static Future<List<teacher_ticket.SupportTicket>> getAssignedTickets(Map<String, String> filters) async => _getTickets('teacher/tickets/assigned', filters);

  static Future<List<teacher_ticket.SupportTicket>> _getTickets(String endpoint, Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((key, value) => value.isEmpty || value == 'all');
    final response = await get(endpoint, query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tickets = data['data'] ?? data['tickets'];
      if (tickets is List) return tickets.map((json) => teacher_ticket.SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<void> createTicket(String title, String description, String priority, {String? category}) async {
    final response = await post('teacher/tickets', {'title': title, 'description': description, 'priority': priority, if (category != null) 'category': category});
    if (response.statusCode != 201) throw Exception('Failed to create ticket');
  }

  static Future<teacher_profile.VirtualIdCardData> getVirtualIdCard() async {
    final response = await get('teacher/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_profile.VirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Future<teacher_view_schedule.ViewSchedulePageData> getViewSchedulePageData() async {
    final response = await get('teacher/schedule');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_view_schedule.ViewSchedulePageData.fromJson(data);
    }
    throw Exception('Failed to load schedule');
  }

  static Future<teacher_profile.TeacherProfile> getTeacherProfile() async {
    final response = await get('teacher/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_profile.TeacherProfile.fromJson(data['data']);
    }
    throw Exception('Failed to load profile');
  }

  static Future<void> updateTeacherProfile(teacher_profile.TeacherProfile profile) async {
    final fields = profile.toApiData();
    final files = profile.photo != null ? {'photo': profile.photo!} : null;
    final response = await postMultipart('teacher/profile/update', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to update profile');
  }

  static Future<void> updateTeacherProfileFromBytes(teacher_profile.TeacherProfile profile, Uint8List? photoBytes, String? fileName) async {
    final fields = profile.toApiData();
    final files = photoBytes != null ? {'photo': photoBytes} : null;
    final fileNames = fileName != null ? {'photo': fileName} : null;
    final response = await postMultipartFromBytes('teacher/profile/update', fields, files: files, fileNames: fileNames);
    if (response.statusCode != 200) throw Exception('Failed to update profile');
  }

  static Future<teacher_my_class.MyClassData> getMyClassData() async {
    final response = await get('teacher/my-class');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_my_class.MyClassData.fromJson(data);
    }
    throw Exception('Failed to load class data');
  }

  static Future<teacher_study_material.StudyMaterialPageData> getStudyMaterialsData() async {
    final response = await get('teacher/notes');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_study_material.StudyMaterialPageData.fromJson(data);
    }
    throw Exception('Failed to load materials');
  }

  static Future<teacher_ticket_details.TicketDetails> getTicketDetails(int ticketId) async {
    final response = await get('teacher/tickets/$ticketId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_ticket_details.TicketDetails.fromJson(data);
    }
    throw Exception('Failed to load ticket details');
  }

  static Future<List<teacher_ticket_schedule.TeacherScheduleItem>> getMySchedule(String date) async {
    final response = await get('teacher/my-schedule', {'date': date});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return (data['schedules'] as List).map((item) => teacher_ticket_schedule.TeacherScheduleItem.fromJson(item)).toList();
    }
    throw Exception('Failed to load schedule');
  }

  static Future<void> updateTicketStatus(int ticketId, String status) async {
    final response = await post('teacher/tickets/$ticketId/status', {'status': status});
    if (response.statusCode != 200) throw Exception('Failed to update status');
  }

  static Future<void> addTicketReply(int ticketId, String message, {File? attachment, Uint8List? fileBytes, String? fileName}) async {
    final fields = {'message': message};
    if (kIsWeb && fileBytes != null && fileName != null) {
      final response = await postMultipartFromBytes('teacher/tickets/$ticketId/reply', fields, files: {'attachment': fileBytes}, fileNames: {'attachment': fileName});
      if (response.statusCode != 201) throw Exception('Failed to add reply');
    } else {
      final files = attachment != null ? {'attachment': attachment} : null;
      final response = await postMultipart('teacher/tickets/$ticketId/reply', fields, files: files);
      if (response.statusCode != 201) throw Exception('Failed to add reply');
    }
  }

  static Future<void> uploadStudyMaterial(int scheduleId, String title, String? description, File file) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, if (description != null) 'description': description};
    final response = await postMultipart('teacher/notes', fields, files: {'file_path': file});
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to upload: $body');
    }
  }

  static Future<void> uploadStudyMaterialFromBytes(int scheduleId, String title, String? description, Uint8List fileBytes, String fileName) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, if (description != null) 'description': description};
    final response = await postMultipartFromBytes('teacher/notes', fields, files: {'file_path': fileBytes}, fileNames: {'file_path': fileName});
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await response.stream.bytesToString();
      throw Exception('Failed to upload: $body');
    }
  }

  static Future<void> deleteStudyMaterial(int materialId) async {
    final response = await delete('teacher/notes/$materialId');
    if (response.statusCode != 200) throw Exception('Failed to delete material');
  }

  static Future<teacher_salary.SalaryPageData> getSalaryDetails() async {
    final response = await get('teacher/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_salary.SalaryPageData.fromJson(data);
    }
    throw Exception('Failed to load salary');
  }

  static Future<Map<String, dynamic>> getTeacherSalarySlip(String salaryId) async {
    final encodedId = Uri.encodeComponent(salaryId);
    try {
      final response = await get('teacher/salary/$encodedId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) return data['data'] ?? data;
      }
    } catch (_) {}

    // Fallback: Search in My Salaries list if specific fetch fails
    try {
      final response = await get('teacher/salary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['salaries'] ?? data['data']?['salaries'] ?? data['data'];
        if (list is List) {
          final record = list.firstWhere(
            (s) => s['id'].toString() == salaryId || s['encrypted_id']?.toString() == salaryId,
            orElse: () => null,
          );
          if (record != null) {
            return {'salary': record, 'amount_in_words': 'N/A', 'status': true};
          }
        }
      }
    } catch (_) {}

    throw Exception('Salary slip details are currently unavailable. (Status: 404)');
  }

  static Future<Map<String, dynamic>> getAccountantFees() async {
    // Adding a timestamp-based cache buster to ensure we get the latest data from the server
    final response = await get('accountants/fees', {'_': DateTime.now().millisecondsSinceEpoch.toString()});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (kDebugMode && data['data'] != null) {
        final instituteFees = data['data']['institute_fees'] as List?;
        if (instituteFees != null && instituteFees.isNotEmpty) {
          final first = instituteFees[0];
          print('🔍 API: Fee structure keys: ${first.keys.toList()}');
          print('🔍 API: ID: ${first['id']}, Encrypted: ${first['encrypted_id']}');
        }
      }

      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load fees');
  }

  static Future<List<accountant_model.UserDetail>> getEmployeesByRole(dynamic roleId) async {
    final encodedId = Uri.encodeComponent(roleId.toString());
    final response = await get('accountants/accounts/$encodedId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final payload = data['data'] ?? data;
        final usersData = payload['users'] ?? payload['employees'] ?? (payload is List ? payload : []);

        List usersList = [];
        if (usersData is List) {
          usersList = usersData;
        } else if (usersData is Map) {
          usersList = usersData.values.toList();
        }

        return usersList.map((e) => accountant_model.UserDetail.fromJson(e)).toList();
      }
    }

    // Handle specific encryption error from Laravel
    if (response.statusCode == 500 && response.body.contains("The payload is invalid")) {
      throw Exception('Backend decryption failed. The role ID "$roleId" might need to be encrypted.');
    }

    final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    final message = errorBody['message'] ?? 'Failed to load employees';
    throw Exception('$message (Status: ${response.statusCode})');
  }

  static Future<Map<String, String>> getAccountantRoles() async {
    final response = await get('accountants/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        final payload = data['data'] ?? data;

        // Try to extract dynamic roles from the dashboard data if available
        final rolesData = payload['roles'];
        if (rolesData is Map) {
          return Map<String, String>.from(rolesData.map((key, value) => MapEntry(key.toString(), value.toString())));
        }

        if (rolesData is List) {
          final Map<String, String> dynamicRoles = {};
          for (var role in rolesData) {
            final id = (role['id'] ?? role['encrypted_id'])?.toString();
            final name = role['name']?.toString();
            if (id != null && name != null) {
              dynamicRoles[id] = name;
            }
          }
          if (dynamicRoles.isNotEmpty) return dynamicRoles;
        }

        // Fallback to static map if the API doesn't provide dynamic roles
        return {
          '3': "Managers",
          '4': "Counselors",
          '5': "Teachers",
          '7': "Librarians",
          '8': "Accountants",
          '9': "Staff",
        };
      }
    }
    return {};
  }

  static Future<void> deleteAccountantFee(String feeId) async {
    final encodedId = Uri.encodeComponent(feeId);
    
    // Attempt 1: Standard DELETE with 'delete' endpoint
    var response = await delete('accountants/fees/delete/$encodedId');
    if (response.statusCode == 200) return;

    // Attempt 2: Standard DELETE with 'destroy' endpoint
    var respDestroy = await delete('accountants/fees/destroy/$encodedId');
    if (respDestroy.statusCode == 200) return;

    // Attempt 3: RESTful DELETE pattern
    var respRest = await delete('accountants/fees/$encodedId');
    if (respRest.statusCode == 200) return;

    // Attempt 4: Laravel Method Spoofing (POST with _method=DELETE)
    try {
      final respSpoof = await post('accountants/fees/delete/$encodedId', {'_method': 'DELETE'});
      if (respSpoof.statusCode == 200) return;

      final respSpoof2 = await post('accountants/fees/destroy/$encodedId', {'_method': 'DELETE'});
      if (respSpoof2.statusCode == 200) return;
    } catch (_) {}

    // Attempt 5: POST with ID in body (Bypasses DecryptException in URL parameter)
    try {
      final respBody = await post('accountants/fees/delete', {'id': feeId});
      if (respBody.statusCode == 200) return;

      final respBody2 = await post('accountants/fees/destroy', {'id': feeId});
      if (respBody2.statusCode == 200) return;
    } catch (_) {}

    // Attempt 6: Manager fallback if available
    try {
      final respMgr = await delete('manager/fees/$feeId');
      if (respMgr.statusCode == 200) return;
    } catch (_) {}

    // Final Attempt: Try removing prefix if it's a specific path pattern
    if (response.statusCode == 405 || response.statusCode == 404 || response.statusCode == 500) {
      print('🚨 API: Deletion failed with ${response.statusCode}. Best attempt exhausted.');
    }

    throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete fee');
  }

  static Future<List<dynamic>> getAccountantFeeCreateData() async {
    final response = await get('accountants/fees/create');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data']['classes'];
    }
    throw Exception('Failed to load classes');
  }

  static Future<Map<String, dynamic>> getAccountantFeeEditData(String feeId) async {
    final encodedId = Uri.encodeComponent(feeId);
    final response = await get('accountants/fees/edit/$encodedId');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true || data['status'] == 'success') {
        final feeData = data['data'] ?? data;
        // If we got valid data back, it might contain the encrypted_id we need.
        return feeData;
      }
    }
    
    if (response.statusCode == 500 && response.body.contains('DecryptException')) {
      print('⚠️ API: Decryption failed for fee edit data (ID: $feeId). Bypassing edit fetch.');
      return {}; 
    }
    
    // Fallback: if decryption fails (numeric ID sent to route expecting encrypted ID),
    // we return an empty map instead of throwing to allow the UI to use existing list data.
    return {};
  }

  static Future<void> storeAccountantFee(Map<String, dynamic> data) async {
    final response = await post('accountants/fees/store', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create fee');
  }

  static Future<void> updateAccountantFee(dynamic feeId, Map<String, dynamic> data) async {
    final String idString = feeId.toString();
    final bodyWithId = Map<String, dynamic>.from(data)..['id'] = feeId;

    // Attempt 1: Try a custom store-update route if it exists (numeric ID in body)
    try {
      var respStoreUpdate = await post('accountants/fees/store-update', bodyWithId);
      if (respStoreUpdate.statusCode == 200) return;
    } catch (_) {}
    
    // Attempt 2: Parameterized update with POST (Most common in this project)
    final encodedId = Uri.encodeComponent(idString);
    var respParam = await post('accountants/fees/update/$encodedId', data);
    if (respParam.statusCode == 200) return;

    // Attempt 3: Try without ID in URL
    var response = await post('accountants/fees/update', bodyWithId);
    if (response.statusCode == 200) return;

    // Attempt 3: Laravel Method Spoofing (POST with _method=PUT or PATCH)
    try {
      final spoofedData = Map<String, dynamic>.from(bodyWithId)..['_method'] = 'PUT';
      var respSpoof = await post('accountants/fees/update/$encodedId', spoofedData);
      if (respSpoof.statusCode == 200) return;
      
      final spoofedData2 = Map<String, dynamic>.from(bodyWithId)..['_method'] = 'PATCH';
      var respSpoof2 = await post('accountants/fees/$encodedId', spoofedData2);
      if (respSpoof2.statusCode == 200) return;
    } catch (_) {}

    // Attempt 4: Try store route as a fallback mechanism
    // If store route creates a duplicate, we clean up the old record to "simulate" an update.
    var respStore = await post('accountants/fees/store', bodyWithId);
    if (respStore.statusCode == 200 || respStore.statusCode == 201) {
      final responseData = jsonDecode(respStore.body);
      final dynamic returnedData = responseData['data'] ?? responseData;
      
      // Extract the new ID if returned
      String? returnedId;
      if (returnedData is Map) {
        returnedId = returnedData['id']?.toString() ?? returnedData['encrypted_id']?.toString();
      }
      
      // If a new record was created (different ID), try to remove the old one.
      // If deletion fails, we don't throw yet, as the data is saved, just duplicated.
      if (returnedId != null && returnedId != idString) {
        print('🚨 API: Update created duplicate ID $returnedId. Cleaning up old ID $idString...');
        try { 
          await deleteAccountantFee(idString); 
          return; 
        } catch (e) {
           print('⚠️ API: Failed to remove old record $idString after update-by-store: $e');
           // If cleanup fails, we still return success if the new record exists, 
           // but we warn the user or system about the duplication.
           return; 
        }
      }
      return;
    }

    // Choose the best error response to show
    final bestErrorResp = respParam.statusCode != 404 ? respParam : response;
    try {
      final errorData = jsonDecode(bestErrorResp.body);
      throw Exception(errorData['message'] ?? 'Failed to update fee (Status: ${bestErrorResp.statusCode})');
    } catch (_) {
      throw Exception('Failed to update fee (Status: ${bestErrorResp.statusCode})');
    }
  }

  static Future<staff_model.StaffDashboardData> getStaffDashboard() async {
    final response = await get('staff/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return staff_model.StaffDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load staff dashboard');
  }

  static Future<staff_model.UserDetail> getStaffProfile() async {
    final response = await get('staff/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return staff_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load staff profile');
  }

  static Future<void> updateStaffProfile(Map<String, String> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('staff/profile/update', data, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to update profile');
  }

  static Future<staff_model.StaffVirtualIdCardData> getStaffVirtualIdCard() async {
    final response = await get('staff/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return staff_model.StaffVirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Stream<staff_model.StaffVirtualIdCardData> getStaffVirtualIdCardStream() => Stream.fromFuture(getStaffVirtualIdCard());

  static Future<List<staff_model.Exam>> getStaffExams() async {
    final response = await get('staff/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => staff_model.Exam.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getStaffExamSchedule(String examId) async {
    final response = await get('staff/exams/schedule/$examId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<staff_model.SalaryPageData> getStaffSalaries() async {
    final response = await get('staff/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        return staff_model.SalaryPageData.fromJson(data['data'] ?? data);
      }
    }
    throw Exception('Failed to load salaries');
  }

  static Future<staff_model.SalaryDetailData> getStaffSalaryDetails(String salaryId) async {
    try {
      final response = await get('staff/salary/$salaryId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == true) {
          return staff_model.SalaryDetailData.fromJson(data['data'] ?? data);
        }
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ ApiService: getStaffSalaryDetails failed: $e');
    }

    // Fallback: Search in My Salaries list if specific fetch fails (e.g. 500 error due to missing php-intl)
    try {
      final response = await get('staff/salary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final listData = data['data'] ?? data;
        final list = listData['salaries'] ?? (listData is List ? listData : []);

        if (list is List) {
          final record = list.firstWhere(
                  (s) => s['id']?.toString() == salaryId || s['encrypted_id']?.toString() == salaryId,
              orElse: () => null
          );

          if (record != null) {
            return staff_model.SalaryDetailData(
              salary: staff_model.Salary.fromJson(record),
              amountInWords: 'Unavailable (Backend Error)',
            );
          }
        }
      }
    } catch (_) {}

    throw Exception('Failed to load salary details. The server might be missing the "php-intl" extension.');
  }

  static Future<List<teacher_ticket.SupportTicket>> getStaffTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<teacher_ticket.SupportTicket>> getStaffAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<void> createStaffTicket(Map<String, dynamic> data) async {
    final response = await post('staff/tickets', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  static Future<void> updateStaffTicketStatus(String ticketId, String status) async {
    final response = await post('staff/tickets/status/$ticketId', {'status': status});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update status');
  }

  static Future<teacher_ticket_details.TicketDetails> getStaffTicketDetails(String ticketId) async {
    final response = await get('staff/tickets/$ticketId/replies');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        // Handle both simple and nested data: { success: true, data: { ticket: ..., replies: ... } }
        final resultData = data['data'] ?? data;
        return teacher_ticket_details.TicketDetails.fromJson(resultData);
      }
    }
    throw Exception('Failed to load ticket details (Status: ${response.statusCode})');
  }

  static Future<void> replyStaffTicket(String ticketId, Map<String, String> fields, {File? attachment}) async {
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('staff/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to update profile');
  }

  static Future<List<librarian_model.IssuedBook>> getStaffIssuedBooks(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty);
    final response = await get('staff/library/lending', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        // Handle Laravel pagination: actual list is in data['data']['data']
        final nestedData = data['data'];
        if (nestedData is Map && nestedData.containsKey('data')) {
          final List list = nestedData['data'];
          return list.map((e) => librarian_model.IssuedBook.fromJson(e)).toList();
        } else if (nestedData is List) {
          return nestedData.map((e) => librarian_model.IssuedBook.fromJson(e)).toList();
        }
      }
    }
    throw Exception('Failed to load issued books');
  }

  static Future<teacher_library.BookPagination> getStaffLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('staff/library/books', query);
    if (response.statusCode == 200) return teacher_library.BookPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load books');
  }

  static Future<List<staff_model.Event>> getStaffEvents({String? status, String? type}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    final response = await get('staff/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => staff_model.Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<List<staff_model.EventRegistration>> getStaffRegisteredEvents() async {
    final response = await get('staff/events/registered');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => staff_model.EventRegistration.fromJson(e)).toList();
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> staffRegisterForEvent(String eventId) async {
    final response = await post('staff/events/register/$eventId', {});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
  }

  static Future<void> cancelStaffEventRegistration(String registrationId) async {
    final response = await post('staff/events/cancel/$registrationId', {});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to cancel');
  }

  static Future<List<staff_model.Fee>> getStaffFees() async {
    final response = await get('staff/fees');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        // Handle both simple lists and pagination/nested data
        var listData = data['data'];
        if (listData is Map && listData.containsKey('data')) {
          listData = listData['data'];
        }

        if (listData is List) {
          return listData.map((f) => staff_model.Fee.fromJson(f)).toList();
        }
      }
    }

    throw Exception('Failed to load fees (Status: ${response.statusCode})');
  }

  static Future<staff_model.StudentFeeDetail> getStaffStudentFeeDetail(String studentId) async {
    final response = await get('staff/student-fee/$studentId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return staff_model.StudentFeeDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load student fee detail');
  }

  static Future<staff_model.StudentFeeDetail> getTeacherStudentFeeDetail(String studentId) async {
    final response = await get('teacher/student-fee/$studentId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return staff_model.StudentFeeDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load student fee detail');
  }

  static Future<void> cancelEventRegistration(int registrationId) async {
    final response = await post('teacher/events/$registrationId/cancel', {});
    if (response.statusCode != 200) throw Exception('Failed to cancel registration');
  }

  static Future<teacher_exam.ExamPageData> getTeacherExams() async {
    final response = await get('teacher/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_exam.ExamPageData.fromJson(data);
    }
    throw Exception('Failed to load exams');
  }

  static Future<teacher_exam.ExamScheduleData> getExamSchedule(int examId) async {
    final response = await get('teacher/exams/$examId/schedule');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_exam.ExamScheduleData.fromJson(data);
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<List<teacher_exam.ExamPaper>> getExamPapers() async {
    final response = await get('teacher/exam-results');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return (data['papers'] as List).map((p) => teacher_exam.ExamPaper.fromJson(p)).toList();
    }
    throw Exception('Failed to load exam papers');
  }

  static Future<Map<String, dynamic>> getExamStudents(int paperId) async {
    final response = await get('teacher/exam-paper/$paperId/marks');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return {
          'paper': teacher_exam.ExamPaper.fromJson(data['paper']),
          'students': (data['students'] as List).map((s) => teacher_exam.ExamStudentRegistration.fromJson(s)).toList()
        };
      }
    }
    throw Exception('Failed to load students');
  }

  static Future<void> submitExamMarks(int paperId, Map<String, dynamic> marksData) async {
    final response = await post('teacher/exam-paper/$paperId/marks', marksData);
    if (response.statusCode != 200) throw Exception('Failed to submit marks');
  }

  static Future<Map<String, dynamic>> getStaffSalarySlip(String salaryId) async {
    final encodedId = Uri.encodeComponent(salaryId);

    // 1. Try staff specific endpoint
    try {
      final response = await get('staff/salary/$encodedId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['status'] == true) {
          final payload = data['data'] ?? data;
          if (payload is Map<String, dynamic> && payload.containsKey('salary')) {
            return payload;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback: Search in My Salaries list if specific fetch fails
    try {
      final response = await get('staff/salary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['salaries'] ?? data['data']?['salaries'] ?? data['data'];

        if (list is List) {
          final record = list.firstWhere(
                  (s) => s['id'].toString() == salaryId || s['encrypted_id']?.toString() == salaryId,
              orElse: () => null
          );

          if (record != null) {
            return {
              'salary': record,
              'amount_in_words': 'Unavailable (Detailed view fallback)',
              'status': true
            };
          }
        }
      }
    } catch (_) {}

    throw Exception('Salary slip details are currently unavailable. (Status: 404)');
  }

  // Accountant APIs
  static Future<accountant_model.AccountantDashboardData> getAccountantDashboard() async {
    final response = await get('accountants/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return accountant_model.AccountantDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load accountant dashboard');
  }

  static Future<List<accountant_model.Event>> getAccountantEvents({String? status, String? type}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    final response = await get('accountants/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => accountant_model.Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<List<accountant_model.EventRegistration>> getAccountantRegisteredEvents({String? status, String? type}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    final response = await get('accountants/events/registered', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => accountant_model.EventRegistration.fromJson(e)).toList();
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> accountantRegisterForEvent(String eventId, {String? paymentId}) async {
    final response = await post('accountants/events/register/$eventId', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
  }

  static Future<void> accountantCancelEvent(String registrationId, {String? reason}) async {
    final response = await post('accountants/events/cancel/$registrationId', {if (reason != null) 'reason': reason});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to cancel');
  }

  static Future<List<accountant_model.Exam>> getAccountantExams() async {
    final response = await get('accountants/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return (data['data'] as List).map((e) => accountant_model.Exam.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams (Status: ${response.statusCode})');
  }

  static Future<accountant_model.UserDetail> getAccountantProfile() async {
    final response = await get('accountants/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return accountant_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load profile');
  }

  static Future<void> updateAccountantProfile(Map<String, dynamic> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('accountants/profile/update', data, files: files);
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<accountant_model.AccountantVirtualIdCardData> getAccountantVirtualIdCard() async {
    final response = await get('accountants/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return accountant_model.AccountantVirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Stream<accountant_model.AccountantVirtualIdCardData> getAccountantVirtualIdCardStream() => Stream.fromFuture(getAccountantVirtualIdCard());

  static Future<Map<String, dynamic>> getAccountantExamSchedule(String id) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await get('accountants/exams/schedule/$encodedId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'] ?? data;
    }

    // Handle Laravel encryption/decryption crash (500) or validation error (400)
    if ((response.statusCode == 500 || response.statusCode == 400) && RegExp(r'^\d+$').hasMatch(id)) {
      throw Exception('The backend requires an ENCRYPTED exam ID. The raw ID "$id" cannot be decrypted.');
    }

    throw Exception('Failed to load exam schedule (Status: ${response.statusCode})');
  }

  static Future<teacher_library.BookPagination> getAccountantLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('accountants/library/books', query);
    if (response.statusCode == 200) return teacher_library.BookPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load books');
  }

  static Future<Map<String, dynamic>> getAccountantStudents(Map<String, String> filters) async {
    final response = await get('accountants/students', filters);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) {
        return data['data'] ?? data;
      }
    }
    throw Exception('Failed to load students');
  }

  static Future<Map<String, dynamic>> getAccountantStudentReceipt(String id) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await get('accountants/students/receipt/$encodedId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load receipt');
  }

  static Future<Map<String, dynamic>> getAccountantSalaryView(String id) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await get('accountants/salary/view/$encodedId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == true) return data['data'];
    }
    throw Exception('Failed to load salary details');
  }

  static Future<void> createAccountantTicket(Map<String, dynamic> data) async {
    final response = await post('accountants/tickets', data);
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  // Student APIs
  static Future<student_dashboard.StudentDashboardData> getStudentDashboard() async {
    final response = await get('student/dashboard');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return student_dashboard.StudentDashboardData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load student dashboard');
  }

  static Future<student_profile.StudentProfileData> getStudentProfile() async {
    final response = await get('student/profile');
    if (response.statusCode == 200) return student_profile.StudentProfileData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load student profile');
  }

  static Future<void> updateStudentProfile(Map<String, String> data, {File? profileImage}) async {
    final files = profileImage != null ? {'profile_image': profileImage} : null;
    final response = await postMultipart('student/profile/update', data, files: files);
    if (response.statusCode != 200) {
      final body = await http.Response.fromStream(response);
      throw Exception(errorMessage(body, 'Failed to update student profile'));
    }
  }

  static Future<student_id.StudentVirtualIdData> getStudentVirtualIdCard() async {
    final response = await get('student/virtual-id-card');
    if (response.statusCode == 200) return student_id.StudentVirtualIdData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load student virtual ID card');
  }

  static Future<List<Map<String, dynamic>>> getStudentRemarks() async {
    final response = await get('student/remarks');
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    throw Exception('Failed to load student remarks');
  }

  static Future<dynamic> getStudentAssignments() async {
    final response = await get('student/assignments');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load student assignments');
  }

  static Future<void> submitStudentAssignment(String id, {File? file, Uint8List? fileBytes, String? fileName, String? text, String? subjectId}) async {
    final Map<String, String> fields = {
      'submitted_text': text ?? '',
      if (subjectId != null) 'subject_id': subjectId,
      'assignment_id': id, // Also send in body as fallback
    };
    
    const String fileKey = 'submitted_file';

    // Routes to try
    final routes = [
      'student/assignment/submit/$id',
      'student/assignments/submit/$id',
      'student/assignment/$id/submit',
      'student/assignments/$id/submit',
    ];

    // If no file is provided, try a regular JSON POST first as it's more CORS-friendly on Web
    if (file == null && (fileBytes == null || fileBytes.isEmpty)) {
      for (var route in routes) {
        try {
          if (kDebugMode) print('🚀 API: Trying JSON submission: $route');
          final response = await post(route, fields);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            if (data['status'] == true || data['success'] == true) {
              if (kDebugMode) print('✅ API: JSON Submission successful via: $route');
              return;
            }
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ API: JSON route $route failed: $e');
        }
      }
    }

    // Fallback to Multipart (required if file is present, or if JSON POST failed)
    String? lastErrorBody;
    for (var route in routes) {
      try {
        if (kDebugMode) print('🚀 API: Trying Multipart submission: $route');
        
        http.StreamedResponse response;
        if (kIsWeb && fileBytes != null && fileBytes.isNotEmpty) {
          response = await postMultipartFromBytes(
            route,
            fields,
            files: {fileKey: fileBytes},
            fileNames: {fileKey: fileName ?? 'assignment.pdf'},
          );
        } else {
          final files = file != null ? {fileKey: file} : null;
          response = await postMultipart(route, fields, files: files);
        }

        final responseBody = await response.stream.bytesToString();
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(responseBody);
          if (data['status'] == true || data['success'] == true) {
            if (kDebugMode) print('✅ API: Multipart Submission successful via: $route');
            return;
          }
        }
        lastErrorBody = responseBody;
        if (kDebugMode) print('⚠️ API: Multipart route $route failed (${response.statusCode}): $responseBody');
      } catch (e) {
        if (kDebugMode) print('❌ API: Multipart route $route error: $e');
        lastErrorBody = e.toString();
      }
    }

    throw Exception('Failed to submit assignment. Please contact support. (Last error: $lastErrorBody)');
  }

  static Future<dynamic> getStudentNotes() async {
    final response = await get('student/notes');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load student notes');
  }

  static Future<Map<String, dynamic>> getStudentAttendance() async {
    final response = await get('student/attendance');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student attendance');
  }

  static Future<List<leave_model.StudentLeave>> getStudentLeaveList() async {
    final response = await get('student/leave');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return (data['data'] as List).map((i) => leave_model.StudentLeave.fromJson(i)).toList();
    }
    throw Exception('Failed to load student leaves');
  }

  static Future<void> applyStudentLeave({required String leaveType, required String fromDate, required String toDate, required String reason}) async {
    final response = await post('student/leave/store', {
      'leave_type': leaveType,
      'from_date': fromDate,
      'to_date': toDate,
      'reason': reason,
    });
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to apply for leave');
  }

  static Future<student_fee.StudentFeeData> getStudentFees() async {
    final response = await get('student/fees');
    if (response.statusCode == 200) return student_fee.StudentFeeData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load student fees');
  }

  static Future<Map<String, dynamic>> getStudentFeeReceipt(String id) async {
    final response = await get('student/fee/receipt/$id');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student fee receipt');
  }

  static Future<List<teacher_ticket.SupportTicket>> getStudentTickets(Map<String, String> filters) async {
    final response = await get('student/tickets', filters);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load student tickets');
  }

  static Future<void> createStudentTicket(String title, String description, String priority, {String? category}) async {
    final response = await post('student/ticket/create', {
      'title': title,
      'description': description,
      'priority': priority.toLowerCase(),
      if (category != null && category.isNotEmpty) 'category': category,
    });
    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to create student ticket');
    }
  }

  static Future<teacher_ticket_details.TicketDetails> getStudentTicketDetails(String ticketId) async {
    final response = await get('student/ticket/$ticketId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        // The API returns { "ticket": { ... }, "replies": [ ... ] } inside 'data'
        return teacher_ticket_details.TicketDetails.fromJson(data['data']);
      }
    }
    // Handle the case where the API returns the list directly (like in the index)
    // although for show() it should be an object.
    throw Exception('Failed to load student ticket details');
  }

  static Future<void> addStudentTicketReply(String ticketId, String message, {File? attachment, Uint8List? attachmentBytes, String? fileName}) async {
    final fields = {'message': message};
    http.StreamedResponse response;

    if (kIsWeb && attachmentBytes != null) {
      response = await postMultipartFromBytes(
        'student/ticket/reply/$ticketId',
        fields,
        files: {'attachment': attachmentBytes},
        fileNames: {'attachment': fileName ?? 'attachment.pdf'},
      );
    } else {
      final files = attachment != null ? {'attachment': attachment} : null;
      response = await postMultipart('student/ticket/reply/$ticketId', fields, files: files);
    }

    if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Failed to add student ticket reply');
  }

  static Future<List<dynamic>> getStudentAllEvents({String? status, String? type}) async {
    final query = <String, String>{if (status != null) 'status': status, if (type != null) 'type': type};
    final response = await get('student/events', query);
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student events');
  }

  static Future<List<dynamic>> getStudentRegisteredEvents({String? status, String? type}) async {
    final query = <String, String>{if (status != null) 'status': status, if (type != null) 'type': type};
    final response = await get('student/events/registered', query);
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student registered events');
  }

  static Future<void> registerForStudentEvent(int eventId, {String? paymentId}) async {
    final response = await post('student/events/register/$eventId', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception('Failed to register for student event');
  }

  static Future<void> cancelStudentEventRegistration(String registrationId, {String? reason}) async {
    final response = await post('student/events/cancel/$registrationId', {if (reason != null) 'reason_for_cancel': reason});
    if (response.statusCode != 200) throw Exception('Failed to cancel student event registration');
  }

  static Future<List<dynamic>> getAdmitCards() async {
    final response = await get('student/admit-cards');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student admit cards');
  }

  static Future<dynamic> getAdmitCardDetails(String id) async {
    final response = await get('student/admit-card/$id');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student admit card details');
  }

  static Future<List<dynamic>> getExamResults() async {
    final response = await get('student/results');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student exam results');
  }

  static Future<dynamic> getReportCard(String id) async {
    final response = await get('student/report/$id');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student report card');
  }

  static Future<Map<String, dynamic>> getStudentExams() async {
    final response = await get('student/exams');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student exams');
  }

  static Future<void> registerForExam(String id) async {
    final response = await post('student/exam/register/$id', {});
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to register for student exam');
    }
  }

  static Future<Map<String, dynamic>> getStudentLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('student/library/books', query);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load student library books');
  }

  static Future<Map<String, dynamic>> getStudentLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('student/library/lending', query);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load student lending books');
  }

  static Future<Map<String, dynamic>> getStudentRoutine() async {
    final response = await get('student/routine');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load routine');
  }

  static Future<Map<String, dynamic>> getStudentDateWiseRoutine(String date) async {
    final response = await get('student/routine/date-wise', {'date': date});
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load date-wise routine');
  }

  // Super Admin APIs
  static Future<Map<String, dynamic>> getSuperAdminDashboard() async {
    final response = await get('superadmin/dashboard');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load super admin dashboard');
  }

  static Future<Map<String, dynamic>> getSuperAdminProfile() async {
    final response = await get('superadmin/profile');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load super admin profile');
  }

  static Future<void> updateSuperAdminProfile(Map<String, dynamic> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('superadmin/update-profile', data, files: files);
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<List<moderator_institute.Institute>> getSuperAdminInstitutes() async {
    final response = await get('superadmin/institutes');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == true || data['success'] == true) return (data['data'] as List).map((json) => moderator_institute.Institute.fromJson(json)).toList();
    }
    throw Exception('Failed to load super admin institutes');
  }

  static Future<moderator_institute.Institute> getSuperAdminInstituteDetails(String id) async {
    final response = await get('superadmin/institutes/$id');
    if (response.statusCode == 200) return moderator_institute.Institute.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load institute details');
  }

  static Future<void> storeSuperAdminInstitute(Map<String, dynamic> data, {File? logo, Uint8List? logoBytes, String? fileName}) async {
    if (logoBytes != null && fileName != null) {
      final response = await postMultipartFromBytes('superadmin/institutes', data, files: {'logo': logoBytes}, fileNames: {'logo': fileName});
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to create institute'));
    } else if (logo != null) {
      final response = await postMultipart('superadmin/institutes', data, files: {'logo': logo});
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to create institute'));
    } else {
      final response = await post('superadmin/institutes', data);
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception(errorMessage(response, 'Failed to create institute'));
    }
  }

  static Future<void> updateSuperAdminInstitute(String id, Map<String, dynamic> data, {File? logo, Uint8List? logoBytes, String? fileName}) async {
    if (logoBytes != null && fileName != null) {
      final response = await postMultipartFromBytes('superadmin/institutes/update/$id', data, files: {'logo': logoBytes}, fileNames: {'logo': fileName});
      if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update institute'));
    } else if (logo != null) {
      final response = await postMultipart('superadmin/institutes/update/$id', data, files: {'logo': logo});
      if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update institute'));
    } else {
      final response = await post('superadmin/institutes/update/$id', data);
      if (response.statusCode != 200) throw Exception(errorMessage(response, 'Failed to update institute'));
    }
  }

  static Future<List<dynamic>> getModerates() async {
    final response = await get('superadmin/moderates');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load super admin moderators');
  }

  static Future<void> storeModerate(Map<String, String> fields, {Map<String, File>? files}) async {
    final response = await postMultipart('superadmin/moderates', fields, files: files);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await http.Response.fromStream(response);
      throw Exception(errorMessage(body, 'Failed to store moderator'));
    }
  }

  static Future<void> storeModerateFromBytes(Map<String, String> fields, {Map<String, Uint8List>? files, Map<String, String>? fileNames}) async {
    final response = await postMultipartFromBytes('superadmin/moderates', fields, files: files, fileNames: fileNames);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = await http.Response.fromStream(response);
      throw Exception(errorMessage(body, 'Failed to store moderator'));
    }
  }

  static Future<void> updateModerate(String id, Map<String, String> fields, {Map<String, File>? files}) async {
    final response = await postMultipart('superadmin/moderates/$id', fields, files: files);
    if (response.statusCode != 200) {
      final body = await http.Response.fromStream(response);
      throw Exception(errorMessage(body, 'Failed to update moderator'));
    }
  }

  static Future<void> updateModerateFromBytes(String id, Map<String, String> fields, {Map<String, Uint8List>? files, Map<String, String>? fileNames}) async {
    final response = await postMultipartFromBytes('superadmin/moderates/$id', fields, files: files, fileNames: fileNames);
    if (response.statusCode != 200) {
      final body = await http.Response.fromStream(response);
      throw Exception(errorMessage(body, 'Failed to update moderator'));
    }
  }

  static Future<void> deleteModerate(String id) async {
    final response = await delete('superadmin/moderates/$id');
    if (response.statusCode != 200) throw Exception('Failed to delete moderator');
  }

  static Future<List<dynamic>> getFaqs() async {
    final response = await get('superadmin/faqs');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load FAQs');
  }

  static Future<void> updateFaq(String id, Map<String, dynamic> data) async {
    final response = await post('superadmin/faqs/update/$id', data);
    if (response.statusCode != 200) {
      throw Exception(errorMessage(response, 'Failed to update FAQ'));
    }
  }

  static Future<void> storeFaq(Map<String, dynamic> data) async {
    final response = await post('superadmin/faqs', data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(errorMessage(response, 'Failed to store FAQ'));
    }
  }

  static Future<void> deleteFaq(String id) async {
    final response = await delete('superadmin/faqs/$id');
    if (response.statusCode != 200) throw Exception('Failed to delete FAQ');
  }

  static Future<List<dynamic>> getSuperAdminTestimonials() async {
    final response = await get('superadmin/testimonials');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load testimonials');
  }

  static Future<void> deleteTestimonial(String id) async {
    final response = await delete('superadmin/testimonials/$id');
    if (response.statusCode != 200) throw Exception('Failed to delete testimonial');
  }

  static Future<void> storeOrUpdateTestimonial(Map<String, String> fields, {File? image}) async {
    final files = image != null ? {'image': image} : null;
    final response = await postMultipart('superadmin/testimonials', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to save testimonial');
  }

  static Future<void> storeOrUpdateTestimonialFromBytes(Map<String, String> fields, {Uint8List? imageBytes, String? imageName}) async {
    final files = imageBytes != null ? {'image': imageBytes} : null;
    final fileNames = imageName != null ? {'image': imageName} : null;
    final response = await postMultipartFromBytes('superadmin/testimonials', fields, files: files, fileNames: fileNames);
    if (response.statusCode != 200) throw Exception('Failed to save testimonial');
  }

  static Future<Map<String, dynamic>> getPrivacyPolicy() async {
    final response = await get('superadmin/privacy-policy');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load privacy policy');
  }

  static Future<void> updatePrivacyPolicy(String content) async {
    final response = await post('superadmin/privacy-policy', {'content': content});
    if (response.statusCode != 200) throw Exception('Failed to update privacy policy');
  }

  static Future<Map<String, dynamic>> getCancellationPolicy() async {
    final response = await get('superadmin/cancellation-policy');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load cancellation policy');
  }

  static Future<void> updateCancellationPolicy(String content) async {
    final response = await post('superadmin/cancellation-policy', {'content': content});
    if (response.statusCode != 200) throw Exception('Failed to update cancellation policy');
  }

  // Helper for profile byte updates
  static Map<String, Uint8List> _wrapFile(Uint8List? bytes, String key) {
    return bytes != null ? {key: bytes} : {};
  }

  static Map<String, String> _wrapFileName(String? fileName, String key) {
    return fileName != null ? {key: fileName} : {};
  }

  // --- Profile Updates ---

  static Future<void> updateCounselorProfile(Map<String, dynamic> fields, {File? photo}) async {
    final response = await postMultipart('counselor/profile/update', fields, files: photo != null ? {'photo': photo} : null);
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateCounselorProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('counselor/profile/update', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<Map<String, dynamic>> getCounselorProfile() async {
    final response = await get('counselor/profile');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load profile');
  }

  static Future<Map<String, dynamic>> getCounselorVirtualIdCard() async {
    final response = await get('counselor/virtual-id-card');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load virtual ID card');
  }

  static Future<librarian_model.UserDetail> updateLibrarianProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('librarian/update-profile', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    final res = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return librarian_model.UserDetail.fromJson(decoded['data']);
    }
    throw Exception(errorMessage(res, 'Failed to update profile'));
  }

  static Future<Map<String, dynamic>> getManagerProfile() async {
    final response = await get('manager/profile');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load profile');
  }

  static Future<void> updateManagerProfile(Map<String, dynamic> fields, {File? photo}) async {
    final response = await postMultipart('manager/profile/update', fields, files: photo != null ? {'photo': photo} : null);
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateManagerProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('manager/profile/update', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateStudentProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('student/profile/update', fields, files: _wrapFile(bytes, 'profile_image'), fileNames: _wrapFileName(fileName, 'profile_image'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateStaffProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('staff/profile/update', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateSuperAdminProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('superadmin/update-profile', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateAccountantProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('accountants/profile/update', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateModeratorProfile(Map<String, dynamic> fields, {File? photo}) async {
    final response = await postMultipart('moderator/profile/update', fields, files: photo != null ? {'photo': photo} : null);
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<void> updateModeratorProfileFromBytes(Map<String, dynamic> fields, Uint8List? bytes, String? fileName) async {
    final response = await postMultipartFromBytes('moderator/profile/update', fields, files: _wrapFile(bytes, 'photo'), fileNames: _wrapFileName(fileName, 'photo'));
    if (response.statusCode != 200) throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to update profile'));
  }

  static Future<List<dynamic>> getModeratorEvents() async {
    final response = await get('moderator/events');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load events');
  }

  // --- Add Entities ---

  static Future<void> addStudent(global_student.NewStudent student) async {
    final fields = {
      'first_name': student.firstName,
      'middle_name': student.middleName,
      'last_name': student.lastName,
      'aadhar_number': student.aadhaarNumber,
      'student_roll_no': student.rollNo,
      'registration_no': student.registrationNo,
      'academic_session': student.academicSession,
      'academic_year': student.academicYear,
      'class_id': student.classId,
      'section_id': student.sectionId,
      'date_of_admission': student.admissionDate != null ? DateFormat('yyyy-MM-dd').format(student.admissionDate!) : null,
      'lateral_admission': (student.lateralAdmission?.trim() == 'Yes') ? 1 : 0,
      'admission_category': student.admissionCategory,
      'student_status': student.studentStatus?.toLowerCase(),
      'dob': student.dob != null ? DateFormat('yyyy-MM-dd').format(student.dob!) : null,
      'gender': student.gender?.toLowerCase(),
      'blood_group': student.bloodGroup,
      'nationality': student.nationality,
      'mobile': student.phone,
      'alternate_phone': student.altPhone,
      'email': student.email,
      'password': student.password,
      'address_line1': student.address,
      'city': student.city,
      'district': student.district,
      'state': student.state,
      'country': student.country,
      'pincode': student.pincode,
      'father_name': student.fatherName,
      'father_occupation': student.fatherOccupation,
      'father_phone': student.fatherPhone,
      'mother_name': student.motherName,
      'mother_occupation': student.motherOccupation,
      'mother_phone': student.motherPhone,
      'guardian_name': student.guardianName,
      'guardian_relation': student.guardianRelation,
      'guardian_phone': student.guardianPhone,
      'allergies': student.allergies,
      'medications': student.medications,
    };

    final files = <String, File>{};
    final byteFiles = <String, Uint8List>{};
    final byteFileNames = <String, String>{};

    void addFile(String key, global_student.AppFile? file) {
      if (file == null) return;
      if (file.path != null) {
        files[key] = File(file.path!);
      } else if (file.bytes != null) {
        byteFiles[key] = file.bytes!;
        byteFileNames[key] = file.name;
      }
    }

    addFile('profile_image', student.profileImage);
    addFile('aadhar_file', student.aadhaarFile);
    addFile('doc_10th_marksheet', student.marksheet10);
    addFile('doc_12th_marksheet', student.marksheet12);
    addFile('doc_transfer_certificate', student.transferCertificate);
    addFile('doc_id_proof', student.idProof);

    http.StreamedResponse response;
    if (byteFiles.isNotEmpty) {
      response = await postMultipartFromBytes('manager/students', fields, files: byteFiles, fileNames: byteFileNames);
    } else {
      response = await postMultipart('manager/students', fields, files: files);
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final res = await http.Response.fromStream(response);
      if (kDebugMode) {
        print('❌ [API FAILURE] Add Student (${response.statusCode})');
        print('📄 Response Body: ${res.body}');
      }
      throw Exception(errorMessage(res, 'Failed to add student'));
    }
  }

  static Future<void> addEmployeeUser(global_employee.NewEmployee employee) async {
    final fields = {
      'name': employee.name,
      'email': employee.email,
      'password': employee.password,
      'role_id': employee.roleId,
      'gender': {
        'male': 1,
        'female': 2,
        'other': 3,
      }[employee.gender?.toLowerCase().trim()] ?? 1,
      'dob': employee.dob != null ? DateFormat('yyyy-MM-dd').format(employee.dob!) : null,
      'relationship_status': {
        'single': 1,
        'married': 2,
        'divorced': 3,
        'widowed': 4,
      }[employee.relationshipStatus?.toLowerCase().trim()] ?? 1,
      'aadhar_number': employee.aadharNumber,
      'phone': employee.phone,
      'alternate_phone': employee.alternatePhone,
      'address': employee.address,
      'city': employee.city,
      'state': employee.state,
      'pincode': employee.pincode,
      'position': employee.position,
      'employment_type': employee.employmentType,
      'joining_date': employee.joiningDate != null ? DateFormat('yyyy-MM-dd').format(employee.joiningDate!) : null,
      'experience': employee.experience,
      'status': (employee.status?.toLowerCase().trim() == 'live') ? 1 : 0,
      'reference': employee.reference,
      'qualification': employee.qualification,
      'x_marks': employee.matricMarks,
      'xii_marks': employee.interMarks,
      'bank_account_number': employee.bankAccountNumber,
      'ifsc_code': employee.ifscCode,
      'bank_name': employee.bankName,
      'branch_name': employee.branch,
      'emergency_contact_name': employee.emergencyContactName,
      'emergency_contact_number': employee.emergencyContactNumber,
    };

    final files = <String, File>{};
    final byteFiles = <String, Uint8List>{};
    final byteFileNames = <String, String>{};

    void addFile(String key, global_student.AppFile? file) {
      if (file == null) return;
      if (file.path != null) {
        files[key] = File(file.path!);
      } else if (file.bytes != null) {
        byteFiles[key] = file.bytes!;
        byteFileNames[key] = file.name;
      }
    }

    addFile('photo', employee.photo);
    addFile('matriculation_marksheet', employee.matriculationMarksheet);
    addFile('intermediate_marksheet', employee.intermediateMarksheet);
    addFile('aadhar_photo', employee.aadharPhoto);
    addFile('resume', employee.resume);

    http.StreamedResponse response;
    if (byteFiles.isNotEmpty) {
      response = await postMultipartFromBytes('manager/users', fields, files: byteFiles, fileNames: byteFileNames);
    } else {
      response = await postMultipart('manager/users', fields, files: files);
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final res = await http.Response.fromStream(response);
      if (kDebugMode) {
        print('❌ [API FAILURE] Add Employee (${response.statusCode})');
        print('📄 Response Body: ${res.body}');
      }
      throw Exception(errorMessage(res, 'Failed to add employee'));
    }
  }

  static Future<void> addEvent(Map<String, dynamic> fields, {File? image, Uint8List? imageBytes, String? fileName, String? imageName}) async {
    http.StreamedResponse response;
    final finalFileName = fileName ?? imageName;

    // Convert audience array to Laravel format if needed
    if (fields['audience'] is List) {
      final audienceList = fields['audience'] as List;
      for (int i = 0; i < audienceList.length; i++) {
        fields['audience[$i]'] = audienceList[i];
      }
      fields.remove('audience');
    }

    if (imageBytes != null && finalFileName != null) {
      response = await postMultipartFromBytes('manager/events', fields, files: {'image': imageBytes}, fileNames: {'image': finalFileName});
    } else {
      response = await postMultipart('manager/events', fields, files: image != null ? {'image': image} : null);
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(errorMessage(await http.Response.fromStream(response), 'Failed to add event'));
    }
  }

  static Future<Map<String, dynamic>> getTermsOfService() async {
    final response = await get('superadmin/terms-of-service');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load terms of service');
  }

  static Future<void> updateTermsOfService(String content) async {
    final response = await post('superadmin/terms-of-service', {'content': content});
    if (response.statusCode != 200) throw Exception('Failed to update terms of service');
  }

  static Future<List<dynamic>> getSuperAdminContacts() async {
    final response = await get('superadmin/contacts');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load contacts');
  }

  static Future<List<dynamic>> getAuditLogs() async {
    final response = await get('superadmin/audit');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load audit logs');
  }

  static Future<List<dynamic>> getDatabaseLogs() async {
    final response = await get('superadmin/audit/database');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load database logs');
  }
}