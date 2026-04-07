import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:eduphin/teacher/dashboard/class_models.dart';
import 'package:eduphin/teacher/dashboard/event_models.dart' as teacher_event;
import 'package:eduphin/teacher/dashboard/student_leave_model.dart' as leave_model;
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart' hide StudentLeave;
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/new_employee_model.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb;
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

import 'package:eduphin/superAdmin/superadmin_models.dart' as super_admin;

class ApiService {
  static const String _envUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get baseUrl {
    if (kIsWeb) {
      return _envUrl;
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return _envUrl;
    }
  }

  static String get baseImageUrl => baseUrl;

  static Uri _uri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('$baseUrl/api/$endpoint');
    if (queryParameters != null) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final famine = await SharedPreferences.getInstance();
    await famine.remove('auth_token');
    try {
      await post('logout', {});
    } catch (_) {}
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
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<http.Response> get(String endpoint, [Map<String, dynamic>? queryParameters]) async {
    try {
      return await http.get(_uri(endpoint, queryParameters), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('GET failed: $e');
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      return await http.post(_uri(endpoint), headers: await _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('POST failed: $e');
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      return await http.put(_uri(endpoint), headers: await _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('PUT failed: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      return await http.delete(_uri(endpoint), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('DELETE failed: $e');
    }
  }

  static Future<http.StreamedResponse> postMultipart(String endpoint, Map<String, String> fields, {Map<String, File>? files}) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
        }
      }
      return await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Multipart failed: $e');
    }
  }

  static Future<http.StreamedResponse> postMultipartFromBytes(String endpoint, Map<String, String> fields, {Map<String, Uint8List>? files, Map<String, String>? fileNames}) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(http.MultipartFile.fromBytes(entry.key, entry.value, filename: fileNames?[entry.key]));
        }
      }
      return await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Multipart failed: $e');
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
      return await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  static Future<List<moderator_institute.Institute>> getInstitutes() async {
    final response = await get('moderator/institutes');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((json) => moderator_institute.Institute.fromJson(json)).toList();
    }
    throw Exception('Failed to load institutes');
  }

  static Future<moderator_institute.Institute> getInstituteDetails(String instituteId) async {
    final response = await get('moderator/institutes/$instituteId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) return moderator_institute.Institute.fromJson(data['data']);
    }
    throw Exception('Failed to load institute details');
  }

  static Future<List<Employee>> getEmployees(String instituteId) async {
    final response = await get('moderator/institutes/$instituteId/accounts');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data['accounts'] != null) {
        return (data['accounts'] as List).map((json) => Employee.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load employees');
  }

  static Future<void> addEmployee(NewEmployee employee) async {
    final fields = employee.toApiData();
    final files = employee.profileImage != null ? {'profile_image': employee.profileImage!} : null;
    final response = await postMultipart('moderator/accounts', fields, files: files);
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(responseBody);
      if (data['success'] == true) return;
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
    if (response.statusCode != 200) throw Exception('Failed to create assignment');
  }

  static Future<void> createAssignmentFromBytes(int scheduleId, String title, String? description, String dueDate, Uint8List attachmentBytes, String fileName) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, 'due_date': dueDate, if (description != null) 'description': description};
    final response = await postMultipartFromBytes('teacher/assignments', fields, files: {'attachment': attachmentBytes}, fileNames: {'attachment': fileName});
    if (response.statusCode != 200) throw Exception('Failed to create assignment');
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
      if (data['success'] == true) return librarian_model.LibrarianDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load librarian dashboard');
  }

  static Future<List<librarian_model.ExamType>> getLibrarianExams() async {
    final response = await get('librarian/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.ExamType.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getLibrarianExamSchedule(String examId) async {
    final response = await get('librarian/exams/schedule/$examId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<List<librarian_model.IssuedBook>> getLibrarianMyIssuedBooks() async {
    final response = await get('librarian/my-issued-books');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.IssuedBook.fromJson(e)).toList();
    }
    throw Exception('Failed to load issued books');
  }

  static Future<List<librarian_model.IssuedBook>> getLibrarianIssuedBooks(Map<String, String> filters) async {
    final response = await get('librarian/issued-books', filters);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.IssuedBook.fromJson(e)).toList();
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
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load logs');
  }

  static Future<Map<String, dynamic>> getIssueBookCreateData() async {
    final response = await get('librarian/issued-books/create');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
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
      if (data['success'] == true) return data['data'];
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
      if (data['success'] == true) return librarian_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load profile');
  }

  static Future<void> updateLibrarianProfile(Map<String, String> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('librarian/profile/update', data, files: files);
    if (response.statusCode != 200) throw Exception('Failed to update profile');
  }

  static Future<Map<String, dynamic>> getLibrarianSalaries() async {
    final response = await get('librarian/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salaries');
  }

  static Future<Map<String, dynamic>> getLibrarianSalarySlip(String salaryId) async {
    final response = await get('librarian/salary/slip/$salaryId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salary slip');
  }

  static Future<teacher_library.BookPagination> getLibrarianBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('librarian/library/books', query);
    if (response.statusCode == 200) return teacher_library.BookPagination.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    throw Exception('Failed to load books');
  }

  static Future<void> createLibrarianBook(Map<String, dynamic> data) async {
    final response = await post('librarian/library/books', data);
    if (response.statusCode != 200) throw Exception('Failed to add book');
  }

  static Future<void> updateLibrarianBook(String bookId, Map<String, dynamic> data) async {
    final response = await post('librarian/library/books/$bookId/update', data);
    if (response.statusCode != 200) throw Exception('Failed to update book');
  }

  static Future<void> deleteLibrarianBook(String bookId) async {
    final response = await delete('librarian/library/books/$bookId');
    if (response.statusCode != 200) throw Exception('Failed to delete book');
  }

  static Future<List<librarian_model.Event>> getLibrarianEvents({String? status, String? type}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (type != null) query['type'] = type;
    final response = await get('librarian/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.Event.fromJson(e)).toList();
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
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.EventRegistration.fromJson(e)).toList();
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> cancelLibrarianEventRegistration(String registrationId) async {
    final response = await post('librarian/events/cancel/$registrationId', {});
    if (response.statusCode != 200) throw Exception('Failed to cancel');
  }

  static Future<teacher_ticket_details.TicketDetails> getTicketDetailsAccountant(String id) async {
    final response = await get('accountants/tickets/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return teacher_ticket_details.TicketDetails.fromJson(data['data']);
    }
    throw Exception('Failed to load ticket details');
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
      if (data['success'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<teacher_ticket.SupportTicket>> getAccountantAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('accountants/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<Map<String, dynamic>> getAccountantStudentFeeDetails(String studentId) async {
    final response = await get('accountants/students/$studentId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load student fee details');
  }

  static Future<void> storeAccountantPayment(Map<String, dynamic> data) async {
    final response = await post('accountants/students/payment', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store payment');
  }

  static Future<void> storeFeeOverride(String studentId, String feeId, Map<String, dynamic> data) async {
    final response = await post('accountants/fee-override/$studentId/$feeId', data);
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
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salaries');
  }

  static Future<Map<String, dynamic>> getAccountantEmployeeSalary(String id) async {
    final response = await get('accountants/account/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load employee salary');
  }

  static Future<void> storeAccountantEmployeeSalary(String id, Map<String, dynamic> data) async {
    final response = await post('accountants/salary/store/$id', data);
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

  static Future<void> addTicketReply(int ticketId, String message, {File? attachment}) async {
    final fields = {'message': message};
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('teacher/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 201) throw Exception('Failed to add reply');
  }

  static Future<void> uploadStudyMaterial(int scheduleId, String title, String? description, File file) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, if (description != null) 'description': description};
    final response = await postMultipart('teacher/notes', fields, files: {'file_path': file});
    if (response.statusCode != 201) throw Exception('Failed to upload');
  }

  static Future<void> uploadStudyMaterialFromBytes(int scheduleId, String title, String? description, Uint8List fileBytes, String fileName) async {
    final fields = {'schedule_id': scheduleId.toString(), 'title': title, if (description != null) 'description': description};
    final response = await postMultipartFromBytes('teacher/notes', fields, files: {'file_path': fileBytes}, fileNames: {'file_path': fileName});
    if (response.statusCode != 201) throw Exception('Failed to upload');
  }

  static Future<void> deleteStudyMaterial(int materialId) async {
    final response = await delete('teacher/notes/$materialId');
    if (response.statusCode != 200) throw Exception('Failed to delete material');
  }

  static Future<teacher_salary.SalaryPageData> getSalaryDetails() async {
    final response = await get('teacher/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_salary.SalaryPageData.fromJson(data['data']);
    }
    throw Exception('Failed to load salary');
  }

  static Future<Map<String, dynamic>> getAccountantFees() async {
    final response = await get('accountants/fees');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load fees');
  }

  static Future<void> deleteAccountantFee(String feeId) async {
    final response = await delete('accountants/fees/delete/$feeId');
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete fee');
  }

  static Future<List<dynamic>> getAccountantFeeCreateData() async {
    final response = await get('accountants/fees/create');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data']['classes'];
    }
    throw Exception('Failed to load classes');
  }

  static Future<Map<String, dynamic>> getAccountantFeeEditData(String feeId) async {
    final response = await get('accountants/fees/edit/$feeId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load fee data');
  }

  static Future<void> storeAccountantFee(Map<String, dynamic> data) async {
    final response = await post('accountants/fees/store', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create fee');
  }

  static Future<void> updateAccountantFee(String feeId, Map<String, dynamic> data) async {
    final response = await post('accountants/fees/update/$feeId', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update fee');
  }

  static Future<staff_model.StaffDashboardData> getStaffDashboard() async {
    final response = await get('staff/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.StaffDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load staff dashboard');
  }

  static Future<staff_model.UserDetail> getStaffProfile() async {
    final response = await get('staff/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.UserDetail.fromJson(data['data']);
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
      if (data['success'] == true) return staff_model.StaffVirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Future<List<staff_model.Exam>> getStaffExams() async {
    final response = await get('staff/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.Exam.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getStaffExamSchedule(String examId) async {
    final response = await get('staff/exams/schedule/$examId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<staff_model.SalaryPageData> getStaffSalaries() async {
    final response = await get('staff/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.SalaryPageData.fromJson(data['data']);
    }
    throw Exception('Failed to load salaries');
  }

  static Future<staff_model.StaffDashboardData> getStaffSalaryDetails(String salaryId) async {
    final response = await get('staff/salary/$salaryId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.StaffDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load salary details');
  }

  static Future<List<teacher_ticket.SupportTicket>> getStaffTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<teacher_ticket.SupportTicket>> getStaffAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => teacher_ticket.SupportTicket.fromJson(j)).toList();
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
      if (data['success'] == true) return teacher_ticket_details.TicketDetails.fromJson(data['data']);
    }
    throw Exception('Failed to load ticket details');
  }

  static Future<void> replyStaffTicket(String ticketId, Map<String, String> fields, {File? attachment}) async {
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('staff/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to reply');
  }

  static Future<List<librarian_model.IssuedBook>> getStaffIssuedBooks(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty);
    final response = await get('staff/library/lending', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => librarian_model.IssuedBook.fromJson(e)).toList();
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
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<List<staff_model.EventRegistration>> getStaffRegisteredEvents() async {
    final response = await get('staff/events/registered');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.EventRegistration.fromJson(e)).toList();
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
      if (data['success'] == true) return (data['data'] as List).map((f) => staff_model.Fee.fromJson(f)).toList();
    }
    throw Exception('Failed to load fees');
  }

  static Future<staff_model.StudentFeeDetail> getStaffStudentFeeDetail(String studentId) async {
    final response = await get('staff/student-fee/$studentId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.StudentFeeDetail.fromJson(data['data']);
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
    final response = await get('staff/salary/slip/$salaryId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salary slip');
  }

  // Accountant APIs
  static Future<accountant_model.AccountantDashboardData> getAccountantDashboard() async {
    final response = await get('accountants/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return accountant_model.AccountantDashboardData.fromJson(data['data']);
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
      if (data['success'] == true) return (data['data'] as List).map((e) => accountant_model.Event.fromJson(e)).toList();
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
      if (data['success'] == true) return (data['data'] as List).map((e) => accountant_model.EventRegistration.fromJson(e)).toList();
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
      if (data['success'] == true) return (data['data'] as List).map((e) => accountant_model.Exam.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams');
  }

  static Future<accountant_model.UserDetail> getAccountantProfile() async {
    final response = await get('accountants/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return accountant_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load profile');
  }

  static Future<void> updateAccountantProfile(Map<String, String> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('accountants/profile/update', data, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to update profile');
  }

  static Future<accountant_model.UserDetail> getAccountantVirtualIdCard() async {
    final response = await get('accountants/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return accountant_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
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
    if (response.statusCode != 200) throw Exception('Failed to update student profile');
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

  static Future<void> submitStudentAssignment(String idHash, {File? file, String? text}) async {
    final fields = {if (text != null) 'text_submission': text};
    final files = file != null ? {'attachment': file} : null;
    final response = await postMultipart('student/assignments/submit/$idHash', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to submit assignment');
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
    final response = await get('student/leaves');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return (data['data'] as List).map((i) => leave_model.StudentLeave.fromJson(i)).toList();
    }
    throw Exception('Failed to load student leaves');
  }

  static Future<void> applyStudentLeave({required String leaveType, required String fromDate, required String toDate, required String reason}) async {
    final response = await post('student/leaves/apply', {
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

  static Future<Map<String, dynamic>> getStudentFeeReceipt(String idHash) async {
    final response = await get('student/fees/receipt/$idHash');
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
    final response = await post('student/tickets/create', {
      'title': title,
      'description': description,
      'priority': priority,
      if (category != null) 'category': category,
    });
    if (response.statusCode != 201) throw Exception('Failed to create student ticket');
  }

  static Future<teacher_ticket_details.TicketDetails> getStudentTicketDetails(String ticketId) async {
    final response = await get('student/tickets/$ticketId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) return teacher_ticket_details.TicketDetails.fromJson(data['data']);
    }
    throw Exception('Failed to load student ticket details');
  }

  static Future<void> addStudentTicketReply(String ticketId, String message, {File? attachment}) async {
    final fields = {'message': message};
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('student/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 201) throw Exception('Failed to add student ticket reply');
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
    final response = await post('student/events/$eventId/register', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception('Failed to register for student event');
  }

  static Future<void> cancelStudentEventRegistration(String registrationId, {String? reason}) async {
    final response = await post('student/events/cancel/$registrationId', {if (reason != null) 'reason': reason});
    if (response.statusCode != 200) throw Exception('Failed to cancel student event registration');
  }

  static Future<List<dynamic>> getAdmitCards() async {
    final response = await get('student/exams/admit-cards');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student admit cards');
  }

  static Future<dynamic> getAdmitCardDetails(String id) async {
    final response = await get('student/exams/admit-cards/$id');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student admit card details');
  }

  static Future<List<dynamic>> getExamResults() async {
    final response = await get('student/exams/results');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student exam results');
  }

  static Future<dynamic> getReportCard(String idHash) async {
    final response = await get('student/exams/report-card/$idHash');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student report card');
  }

  static Future<Map<String, dynamic>> getStudentExams() async {
    final response = await get('student/exams');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load student exams');
  }

  static Future<void> registerForExam(String examId) async {
    final response = await post('student/exams/$examId/register', {});
    if (response.statusCode != 200) throw Exception('Failed to register for student exam');
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

  static Future<void> updateSuperAdminProfile(Map<String, String> data) async {
    final response = await post('superadmin/profile/update', data);
    if (response.statusCode != 200) throw Exception('Failed to update super admin profile');
  }

  static Future<List<moderator_institute.Institute>> getSuperAdminInstitutes() async {
    final response = await get('superadmin/institutes');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((json) => moderator_institute.Institute.fromJson(json)).toList();
    }
    throw Exception('Failed to load super admin institutes');
  }

  static Future<moderator_institute.Institute> getSuperAdminInstituteDetails(String id) async {
    final response = await get('superadmin/institutes/$id');
    if (response.statusCode == 200) return moderator_institute.Institute.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load institute details');
  }

  static Future<void> storeSuperAdminInstitute(Map<String, String> data, {File? logo}) async {
    final response = await postMultipart('superadmin/institutes/store', data, files: logo != null ? {'logo': logo} : null);
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Failed to create institute');
  }

  static Future<void> updateSuperAdminInstitute(String id, Map<String, String> data, {File? logo}) async {
    final response = await postMultipart('superadmin/institutes/update/$id', data, files: logo != null ? {'logo': logo} : null);
    if (response.statusCode != 200) throw Exception('Failed to update institute');
  }

  static Future<List<dynamic>> getModerates() async {
    final response = await get('superadmin/moderators');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load super admin moderators');
  }

  static Future<void> storeModerate(Map<String, String> fields, {Map<String, File>? files}) async {
    final response = await postMultipart('superadmin/moderators/store', fields, files: files);
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception('Failed to store moderator');
  }

  static Future<void> updateModerate(String id, Map<String, String> fields, {Map<String, File>? files}) async {
    final response = await postMultipart('superadmin/moderators/update/$id', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to update moderator');
  }

  static Future<void> deleteModerate(String id) async {
    final response = await delete('superadmin/moderators/$id');
    if (response.statusCode != 200) throw Exception('Failed to delete moderator');
  }

  static Future<List<dynamic>> getFaqs() async {
    final response = await get('superadmin/faqs');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load FAQs');
  }

  static Future<void> storeFaq(Map<String, dynamic> data) async {
    final response = await post('superadmin/faqs/store', data);
    if (response.statusCode != 200) throw Exception('Failed to store FAQ');
  }

  static Future<void> updateFaq(String id, Map<String, dynamic> data) async {
    final response = await post('superadmin/faqs/update/$id', data);
    if (response.statusCode != 200) throw Exception('Failed to update FAQ');
  }

  static Future<void> deleteFaq(String id) async {
    final response = await delete('superadmin/faqs/delete/$id');
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
    final response = await postMultipart('superadmin/testimonials/store-update', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to save testimonial');
  }

  static Future<Map<String, dynamic>> getPrivacyPolicy() async {
    final response = await get('superadmin/policies/privacy-policy');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load privacy policy');
  }

  static Future<void> updatePrivacyPolicy(String content) async {
    final response = await post('superadmin/policies/privacy-policy', {'content': content});
    if (response.statusCode != 200) throw Exception('Failed to update privacy policy');
  }

  static Future<Map<String, dynamic>> getCancellationPolicy() async {
    final response = await get('superadmin/policies/cancellation-policy');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load cancellation policy');
  }

  static Future<void> updateCancellationPolicy(String content) async {
    final response = await post('superadmin/policies/cancellation-policy', {'content': content});
    if (response.statusCode != 200) throw Exception('Failed to update cancellation policy');
  }

  static Future<List<dynamic>> getSuperAdminContacts() async {
    final response = await get('superadmin/contacts');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load contacts');
  }

  static Future<List<dynamic>> getAuditLogs() async {
    final response = await get('superadmin/logs/audit');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load audit logs');
  }

  static Future<List<dynamic>> getDatabaseLogs() async {
    final response = await get('superadmin/logs/database');
    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    throw Exception('Failed to load database logs');
  }
}
