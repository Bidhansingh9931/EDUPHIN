import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:eduphin/teacher/dashboard/class_models.dart';
import 'package:eduphin/teacher/dashboard/event_models.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:eduphin/teacher/dashboard/my_class_model.dart';
import 'package:eduphin/teacher/dashboard/salary_models.dart';
import 'package:eduphin/teacher/dashboard/schedule_models.dart';
import 'package:eduphin/teacher/dashboard/student_leave_model.dart';
import 'package:eduphin/teacher/dashboard/study_material_model.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart' hide StudentLeave;
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/new_employee_model.dart';
import 'package:eduphin/student/student_dashboard_model.dart' as student_model;
import 'package:eduphin/student/student_profile_model.dart' as student_profile;
import 'package:eduphin/student/student_virtual_id_model.dart' as student_id;
import 'package:eduphin/student/student_fee_model.dart' as student_fee;
import 'package:eduphin/accountant/dashboard/accountant_dashboard_model.dart' as accountant_model;
import 'package:eduphin/staff/staff_dashboard/staff_models.dart' as staff_model;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eduphin/manager_dashboard/events/event_model.dart';
import 'package:eduphin/moderator_dashboard/institute/institute_model.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/manage/employee_model.dart';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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

  static Future<List<Institute>> getInstitutes() async {
    final response = await get('moderator/institutes');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((json) => Institute.fromJson(json)).toList();
    }
    throw Exception('Failed to load institutes');
  }

  static Future<Institute> getInstituteDetails(String instituteId) async {
    final response = await get('moderator/institutes/$instituteId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) return Institute.fromJson(data['data']);
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
    if (response.statusCode != 200) throw Exception('Failed to delete assignment');
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

  static Future<List<StudentLeave>> getStudentLeaveDetails() async {
    final response = await get('teacher/leave-details');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['leaves'] != null) return (data['leaves'] as List).map((i) => StudentLeave.fromJson(i)).toList();
    }
    throw Exception('Failed to load leave details');
  }

  static Future<void> updateStudentLeaveStatus(int leaveId, String status, {String? remarks}) async {
    final response = await post('teacher/leave/$leaveId', {'status': status, if (remarks != null) 'remarks': remarks});
    if (response.statusCode != 200) throw Exception('Failed to update leave status');
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

  static Future<List<RegisteredEvent>> getRegisteredEvents({String? status, String? type}) async {
    final query = <String, String>{if (status != null) 'status': status, if (type != null) 'type': type};
    final response = await get('teacher/events/registered', query);
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return (jsonDecode(response.body)['registered_events'] as List).map((e) => RegisteredEvent.fromJson(e)).toList();
    throw Exception('Failed to load registered events');
  }

  static Future<void> registerForEvent(int eventId, {String? paymentId}) async {
    final response = await post('teacher/events/$eventId/register', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception('Failed to register');
  }

  static Future<void> cancelEventRegistration(int registrationId, {String? reason}) async {
    final response = await post('teacher/events/$registrationId/cancel', {if (reason != null) 'reason_for_cancel': reason});
    if (response.statusCode != 200) throw Exception('Failed to cancel');
  }

  static Future<ExamPageData> getTeacherExams() async {
    final response = await get('teacher/exams');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return ExamPageData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load exams');
  }

  static Future<ExamScheduleData> getExamSchedule(int examId) async {
    final response = await get('teacher/exams/$examId/schedule');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return ExamScheduleData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load exam schedule');
  }

  static Future<List<ExamPaper>> getExamPapers() async {
    final response = await get('teacher/exam-results');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return (jsonDecode(response.body)['papers'] as List).map((p) => ExamPaper.fromJson(p)).toList();
    throw Exception('Failed to load exam papers');
  }

  static Future<Map<String, dynamic>> getExamStudents(int paperId) async {
    final response = await get('teacher/exam-paper/$paperId/marks');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) {
      final data = jsonDecode(response.body);
      return {'paper': ExamPaper.fromJson(data['paper']), 'students': (data['students'] as List).map((s) => ExamStudentRegistration.fromJson(s)).toList()};
    }
    throw Exception('Failed to load students');
  }

  static Future<void> submitExamMarks(int paperId, Map<String, dynamic> marksData) async {
    final response = await post('teacher/exam-paper/$paperId/marks', marksData);
    if (response.statusCode != 200) throw Exception('Failed to submit marks');
  }

  static Future<BookPagination> getLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('teacher/library/books', query);
    if (response.statusCode == 200) return BookPagination.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load books');
  }

  static Future<LendingPagination> getLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('teacher/library/lending', query);
    if (response.statusCode == 200) return LendingPagination.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load lending data');
  }

  static Future<SalaryPageData> getSalaryDetails() async {
    final response = await get('teacher/salary');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return SalaryPageData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load salary');
  }

  static Future<List<TeacherScheduleItem>> getMySchedule(String date) async {
    final response = await get('teacher/my-schedule', {'date': date});
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return (jsonDecode(response.body)['schedules'] as List).map((item) => TeacherScheduleItem.fromJson(item)).toList();
    throw Exception('Failed to load schedule');
  }

  static Future<ViewSchedulePageData> getViewSchedulePageData() async {
    final response = await get('teacher/schedule');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return ViewSchedulePageData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load schedule');
  }

  static Future<List<SupportTicket>> getMyTickets(Map<String, String> filters) async => _getTickets('teacher/tickets', filters);
  static Future<List<SupportTicket>> getAssignedTickets(Map<String, String> filters) async => _getTickets('teacher/tickets/assigned', filters);

  static Future<List<SupportTicket>> _getTickets(String endpoint, Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((key, value) => value.isEmpty || value == 'all');
    final response = await get(endpoint, query);
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) {
      final data = jsonDecode(response.body);
      final tickets = data['data'] ?? data['tickets'];
      return (tickets as List).map((json) => SupportTicket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<void> createTicket(String title, String description, String priority, {String? category}) async {
    final response = await post('teacher/tickets', {'title': title, 'description': description, 'priority': priority, if (category != null) 'category': category});
    if (response.statusCode != 201) throw Exception('Failed to create ticket');
  }

  static Future<TicketDetails> getTicketDetails(int ticketId) async {
    final response = await get('teacher/tickets/$ticketId');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return TicketDetails.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load ticket details');
  }

  static Future<void> addTicketReply(int ticketId, String message, {File? attachment}) async {
    final fields = {'message': message};
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('teacher/tickets/$ticketId/reply', fields, files: files);
    if (response.statusCode != 201) throw Exception('Failed to add reply');
  }

  static Future<void> updateTicketStatus(int ticketId, String status) async {
    final response = await post('teacher/tickets/$ticketId/status', {'status': status});
    if (response.statusCode != 200) throw Exception('Failed to update status');
  }

  static Future<TeacherProfile> getTeacherProfile() async {
    final response = await get('teacher/profile');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return TeacherProfile.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load profile');
  }

  static Future<void> updateTeacherProfile(TeacherProfile profile) async {
    final fields = profile.toApiData();
    final files = profile.photo != null ? {'photo': profile.photo!} : null;
    final response = await postMultipart('teacher/profile/update', fields, files: files);
    if (response.statusCode != 200) throw Exception('Failed to update profile');
  }

  static Future<VirtualIdCardData> getVirtualIdCard() async {
    final response = await get('teacher/virtual-id-card');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return VirtualIdCardData.fromJson(jsonDecode(response.body)['data']);
    throw Exception('Failed to load virtual ID card');
  }

  static Future<MyClassData> getMyClassData() async {
    final response = await get('teacher/my-class');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return MyClassData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load class data');
  }

  static Future<StudyMaterialPageData> getStudyMaterialsData() async {
    final response = await get('teacher/notes');
    if (response.statusCode == 200 && jsonDecode(response.body)['status'] == true) return StudyMaterialPageData.fromJson(jsonDecode(response.body));
    throw Exception('Failed to load materials');
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

  static Future<student_model.StudentDashboardData> getStudentDashboard() async {
    final response = await get('student/dashboard');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return student_model.StudentDashboardData.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Server Error: ${response.statusCode}');
  }

  static Future<student_profile.StudentProfileData> getStudentProfile() async {
    final response = await get('student/profile');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return student_profile.StudentProfileData.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load profile');
  }

  static Future<void> updateStudentProfile(Map<String, String> data, {File? profileImage}) async {
    final files = profileImage != null ? {'profile_image': profileImage} : null;
    final response = await postMultipart('student/profile/update', data, files: files);
    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);
    if (response.statusCode != 200 || responseData['status'] != true) throw Exception(responseData['message'] ?? 'Failed to update profile');
  }

  static Future<student_id.StudentVirtualIdData> getStudentVirtualIdCard() async {
    final response = await get('student/virtual-id-card');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return student_id.StudentVirtualIdData.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load virtual ID card');
  }

  static Future<student_fee.StudentFeeData> getStudentFees() async {
    final response = await get('student/fees');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return student_fee.StudentFeeData.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load student fees');
  }

  static Future<Map<String, dynamic>> getStudentFeeReceipt(String feeId) async {
    final response = await get('student/fee/receipt/$feeId');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load receipt');
  }

  static Future<List<SupportTicket>> getStudentTickets(Map<String, String> filters) async {
    final queryParameters = Map<String, String>.from(filters)..removeWhere((key, value) => value.isEmpty || value == 'all');
    final response = await get('student/tickets', queryParameters);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return (data['data'] as List).map((j) => SupportTicket.fromJson(j)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load tickets');
  }

  static Future<void> createStudentTicket(String title, String description, String priority, {String? category}) async {
    final response = await post('student/ticket/create', {'title': title, 'description': description, 'priority': priority.toLowerCase(), if (category != null) 'category': category});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  static Future<TicketDetails> getStudentTicketDetails(String ticketId) async {
    final response = await get('student/ticket/$ticketId');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return TicketDetails.fromJson(data);
    throw Exception(data['message'] ?? 'Failed to load ticket details');
  }

  static Future<void> addStudentTicketReply(String ticketId, String message, {File? attachment}) async {
    final fields = {'message': message};
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('student/ticket/reply/$ticketId', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to add reply');
  }

  static Future<Map<String, dynamic>> getStudentAttendance() async {
    final response = await get('student/attendance');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load attendance');
  }

  static Future<List<StudentLeave>> getStudentLeaveList() async {
    final response = await get('student/leave');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) {
      return (data['data'] as List).map((e) => StudentLeave.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load leave applications');
  }

  static Future<void> applyStudentLeave({required String leaveType, required String fromDate, required String toDate, required String reason}) async {
    final response = await post('student/leave/store', {'leave_type': leaveType.toLowerCase(), 'from_date': fromDate, 'to_date': toDate, 'reason': reason});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to apply leave');
  }

  static Future<List<Map<String, dynamic>>> getStudentRemarks() async {
    final response = await get('student/remarks');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return List<Map<String, dynamic>>.from(data['data']);
    throw Exception(data['message'] ?? 'Failed to load remarks');
  }

  static Future<List<dynamic>> getStudentAllEvents({String? status, String? type}) async {
    final queryParams = <String, String>{};
    if (status != null && status != 'All Events') queryParams['status'] = status.toLowerCase();
    if (type != null && type != 'All Categories') queryParams['type'] = type.toLowerCase();
    final response = await get('student/events', queryParams);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load events');
  }

  static Future<List<dynamic>> getStudentRegisteredEvents({String? status, String? type}) async {
    final queryParams = <String, String>{};
    if (status != null && status != 'All Events') queryParams['status'] = status.toLowerCase();
    if (type != null && type != 'All Categories') queryParams['type'] = type.toLowerCase();
    final response = await get('student/events/registered', queryParams);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load registered events');
  }

  static Future<void> registerForStudentEvent(int eventId, {String? paymentId}) async {
    final response = await post('student/events/register/$eventId', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
  }

  static Future<void> cancelStudentEventRegistration(String registerId, {String? reason}) async {
    final response = await post('student/events/cancel/$registerId', {if (reason != null) 'reason_for_cancel': reason});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to cancel');
  }

  static Future<Map<String, dynamic>> getStudentExams() async {
    final response = await get('student/exams');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load exams');
  }

  static Future<void> registerForExam(String examId) async {
    final response = await post('student/exam/register/$examId', {});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
  }

  static Future<List<dynamic>> getAdmitCards() async {
    final response = await get('student/admit-cards');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load admit cards');
  }

  static Future<Map<String, dynamic>> getAdmitCardDetails(String registrationId) async {
    final response = await get('student/admit-card/$registrationId');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load admit card details');
  }

  static Future<List<dynamic>> getExamResults() async {
    final response = await get('student/results');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load results');
  }

  static Future<Map<String, dynamic>> getReportCard(String registrationId) async {
    final response = await get('student/report/$registrationId');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load report card');
  }

  static Future<dynamic> getStudentNotes() async {
    final response = await get('student/notes');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load notes');
  }

  static Future<dynamic> getStudentAssignments() async {
    final response = await get('student/assignments');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data['data'];
    throw Exception(data['message'] ?? 'Failed to load assignments');
  }

  static Future<void> submitStudentAssignment(String assignmentId, {File? file, String? text}) async {
    final fields = <String, String>{if (text != null) 'submitted_text': text};
    final files = file != null ? {'submitted_file': file} : null;
    final response = await postMultipart('student/assignment/submit/$assignmentId', fields, files: files);
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception(jsonDecode(responseBody)['message'] ?? 'Failed to submit assignment');
    }
  }

  static Future<Map<String, dynamic>> getStudentLibraryBooks(Map<String, String> filters, int page) async {
    final queryParams = Map<String, String>.from(filters)..removeWhere((k, v) => v == 'All' || v.isEmpty);
    queryParams['page'] = page.toString();
    final response = await get('student/library/books', queryParams);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data;
    throw Exception(data['message'] ?? 'Failed to load library books');
  }

  static Future<Map<String, dynamic>> getStudentLendingBooks(Map<String, String> filters, int page) async {
    final queryParams = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty);
    queryParams['page'] = page.toString();
    final response = await get('student/library/lending', queryParams);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == true) return data;
    throw Exception(data['message'] ?? 'Failed to load lending history');
  }

  static Future<accountant_model.AccountantDashboardData> getAccountantDashboard() async {
    final response = await get('accountants/dashboard');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return accountant_model.AccountantDashboardData.fromJson(data['data']);
    }
    throw Exception('Failed to load accountant dashboard');
  }

  static Future<accountant_model.UserDetail> getAccountantProfile() async {
    final response = await get('accountants/profile');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return accountant_model.UserDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load accountant profile');
  }

  static Future<void> updateAccountantProfile(Map<String, String> data, {File? photo}) async {
    final files = photo != null ? {'photo': photo} : null;
    final response = await postMultipart('accountants/profile/update', data, files: files);
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception(jsonDecode(responseBody)['message'] ?? 'Failed to update profile');
    }
  }

  static Future<List<accountant_model.UserDetail>> getAccountantEmployees(int roleId) async {
    final response = await get('accountants/accounts/$roleId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['data']['users'] as List).map((e) => accountant_model.UserDetail.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load employees');
  }

  static Future<List<accountant_model.Event>> getAccountantEvents({String? status, String? type}) async {
    final Map<String, String> query = {};
    if (status != null && status != 'All Events') query['status'] = status.toLowerCase();
    if (type != null && type != 'All types') query['type'] = type.toLowerCase();
    
    final response = await get('accountants/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => accountant_model.Event.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load events');
  }

  static Future<List<accountant_model.EventRegistration>> getAccountantRegisteredEvents({String? status, String? type}) async {
    final Map<String, String> query = {};
    if (status != null && status != 'All Status') query['status'] = status.toLowerCase();
    if (type != null && type != 'All types') query['type'] = type.toLowerCase();
    
    final response = await get('accountants/events/registered', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => accountant_model.EventRegistration.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> accountantRegisterForEvent(String eventId, {String? paymentId}) async {
    final response = await post('accountants/events/register/$eventId', {if (paymentId != null) 'payment_id': paymentId});
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
    }
  }

  static Future<void> accountantCancelEvent(String registrationId, {String? reason}) async {
    final response = await post('accountants/events/cancel/$registrationId', {if (reason != null) 'reason_for_cancel': reason});
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to cancel');
    }
  }

  static Future<Map<String, dynamic>> getAccountantFees() async {
    final response = await get('accountants/fees');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load fees');
  }

  static Future<List<dynamic>> getAccountantFeeCreateData() async {
    final response = await get('accountants/fees/create');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data']['classes'];
    }
    throw Exception('Failed to load classes');
  }

  static Future<void> storeAccountantFee(Map<String, dynamic> data) async {
    final response = await post('accountants/fees/store', data);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create fee');
    }
  }

  static Future<Map<String, dynamic>> getAccountantFeeEditData(String id) async {
    final response = await get('accountants/fees/edit/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load fee data');
  }

  static Future<void> updateAccountantFee(String id, Map<String, dynamic> data) async {
    final response = await post('accountants/fees/update/$id', data);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update fee');
    }
  }

  static Future<void> deleteAccountantFee(String id) async {
    final response = await delete('accountants/fees/delete/$id');
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete fee');
    }
  }

  static Future<BookPagination> getAccountantLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('accountants/library/books', query);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return BookPagination.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to load books');
  }

  static Future<LendingPagination> getAccountantLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('accountants/library/lending', query);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return LendingPagination.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to load lending data');
  }

  static Future<List<dynamic>> getAccountantStudents({String? classId}) async {
    final Map<String, String> query = {};
    if (classId != null) query['class_id'] = classId;
    final response = await get('accountants/students', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load students');
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
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store payment');
    }
  }

  static Future<void> storeOrUpdateFine(Map<String, dynamic> data) async {
    final response = await post('accountants/fines/store-update', data);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to save fine');
    }
  }

  static Future<void> deleteFine(String id) async {
    final response = await delete('accountants/fines/delete/$id');
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete fine');
    }
  }

  static Future<void> storeFeeOverride(String studentId, String feeId, Map<String, dynamic> data) async {
    final response = await post('accountants/fee-override/$studentId/$feeId', data);
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to store fee override');
    }
  }

  static Future<List<SupportTicket>> getAccountantTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('accountants/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<SupportTicket>> getAccountantAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('accountants/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => SupportTicket.fromJson(j)).toList();
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<void> createAccountantTicket(Map<String, dynamic> data) async {
    final response = await post('accountants/tickets', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  static Future<TicketDetails> getTicketDetailsAccountant(String id) async {
    final response = await get('accountants/tickets/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return TicketDetails.fromJson(data);
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

  static Future<List<dynamic>> getAccountantExams() async {
    final response = await get('accountants/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getAccountantExamSchedule(String id) async {
    final response = await get('accountants/exams/schedule/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<Map<String, dynamic>> getAccountantMySalaries() async {
    final response = await get('accountants/my-salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salaries');
  }

  static Future<Map<String, dynamic>> getAccountantSalarySlip(String id) async {
    final response = await get('accountants/salary/view/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load salary slip');
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

  static Future<void> deleteAccountantSalary(String id) async {
    final response = await delete('accountants/salary/delete/$id');
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete salary');
  }

  static Future<VirtualIdCardData> getAccountantVirtualIdCard() async {
    final response = await get('accountants/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return VirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  // Staff APIs
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
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception(jsonDecode(responseBody)['message'] ?? 'Failed to update profile');
    }
  }

  static Future<staff_model.StaffVirtualIdCardData> getStaffVirtualIdCard() async {
    final response = await get('staff/virtual-id-card');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.StaffVirtualIdCardData.fromJson(data['data']);
    }
    throw Exception('Failed to load virtual ID card');
  }

  static Future<List<staff_model.Event>> getStaffEvents({String? status, String? type}) async {
    final Map<String, String> query = {};
    if (status != null && status != 'All Events') query['status'] = status.toLowerCase();
    if (type != null && type != 'All types') query['type'] = type.toLowerCase();
    final response = await get('staff/events', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.Event.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<List<staff_model.EventRegistration>> getStaffRegisteredEvents({String? status, String? type}) async {
    final Map<String, String> query = {};
    if (status != null && status != 'All Events') query['status'] = status.toLowerCase();
    if (type != null && type != 'All types') query['type'] = type.toLowerCase();
    final response = await get('staff/events/registered', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.EventRegistration.fromJson(e)).toList();
    }
    throw Exception('Failed to load registered events');
  }

  static Future<void> staffRegisterForEvent(String id) async {
    final response = await post('staff/events/register/$id', {});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to register');
  }

  static Future<void> cancelStaffEventRegistration(String id) async {
    final response = await post('staff/events/cancel/$id', {});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to cancel');
  }

  static Future<List<staff_model.Exam>> getStaffExams() async {
    final response = await get('staff/exams');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((e) => staff_model.Exam.fromJson(e)).toList();
    }
    throw Exception('Failed to load exams');
  }

  static Future<Map<String, dynamic>> getStaffExamSchedule(String id) async {
    final response = await get('staff/exams/schedule/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return data['data'];
    }
    throw Exception('Failed to load exam schedule');
  }

  static Future<BookPagination> getStaffLibraryBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('staff/library/books', query);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return BookPagination.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to load books');
  }

  static Future<LendingPagination> getStaffLendingBooks(Map<String, String> filters, int page) async {
    final query = Map<String, String>.from(filters)..['page'] = page.toString();
    final response = await get('staff/library/lending', query);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return LendingPagination.fromJson(body['data'] ?? body);
    }
    throw Exception('Failed to load lending data');
  }

  static Future<staff_model.SalaryPageData> getStaffSalaries() async {
    final response = await get('staff/salary');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.SalaryPageData.fromJson(data['data']);
    }
    throw Exception('Failed to load salaries');
  }

  static Future<staff_model.SalaryDetailData> getStaffSalaryDetails(String id) async {
    final response = await get('staff/salary/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.SalaryDetailData.fromJson(data['data']);
    }
    throw Exception('Failed to load salary details');
  }

  static Future<List<staff_model.Ticket>> getStaffTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => staff_model.Ticket.fromJson(j)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  static Future<List<staff_model.Ticket>> getStaffAssignedTickets(Map<String, String> filters) async {
    final query = Map<String, String>.from(filters)..removeWhere((k, v) => v.isEmpty || v == 'all');
    final response = await get('staff/tickets/assigned', query);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((j) => staff_model.Ticket.fromJson(j)).toList();
    }
    throw Exception('Failed to load assigned tickets');
  }

  static Future<void> createStaffTicket(Map<String, dynamic> data) async {
    final response = await post('staff/tickets', data);
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create ticket');
  }

  static Future<void> updateStaffTicketStatus(String id, String status) async {
    final response = await post('staff/tickets/status/$id', {'status': status});
    if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update status');
  }

  static Future<TicketDetails> getStaffTicketDetails(String id) async {
    final response = await get('staff/tickets/$id/replies');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return TicketDetails.fromJson(data['data']);
    }
    throw Exception('Failed to load ticket details');
  }

  static Future<void> replyStaffTicket(String id, Map<String, String> fields, {File? attachment}) async {
    final files = attachment != null ? {'attachment': attachment} : null;
    final response = await postMultipart('staff/tickets/$id/reply', fields, files: files);
    if (response.statusCode != 200) throw Exception(jsonDecode(await response.stream.bytesToString())['message'] ?? 'Failed to reply');
  }

  static Future<List<staff_model.Fee>> getStaffFees() async {
    final response = await get('staff/fees'); // Assumption: staff/fees endpoint
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return (data['data'] as List).map((f) => staff_model.Fee.fromJson(f)).toList();
    }
    throw Exception('Failed to load fees');
  }

  static Future<staff_model.StudentFeeDetail> getStaffStudentFeeDetail(String studentId) async {
    final response = await get('staff/student-fee/$studentId'); // Assumption: staff/student-fee/{id} endpoint
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return staff_model.StudentFeeDetail.fromJson(data['data']);
    }
    throw Exception('Failed to load student fee detail');
  }
}
