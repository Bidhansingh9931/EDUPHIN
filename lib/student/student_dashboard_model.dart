import 'dart:convert';

class StudentDashboardData {
  final User? user;
  final Student? student;
  final double attendancePercentage;
  final List<Event> events;
  final List<Exam> availableExams;
  final List<int> registeredExamIds;
  final List<Ticket> tickets;
  final dynamic totalPaid;
  final dynamic totalPayable;
  final dynamic due;
  final List<StudyMaterial> studyMaterials;
  final List<Assignment> assignments;

  StudentDashboardData({
    this.user,
    this.student,
    required this.attendancePercentage,
    required this.events,
    required this.availableExams,
    required this.registeredExamIds,
    required this.tickets,
    required this.totalPaid,
    required this.totalPayable,
    required this.due,
    required this.studyMaterials,
    required this.assignments,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      attendancePercentage: _toDouble(json['attendance_percentage']),
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e)).toList(),
      availableExams: (json['available_exams'] as List? ?? []).map((e) => Exam.fromJson(e)).toList(),
      registeredExamIds: (json['registered_exam_ids'] as List? ?? [])
          .map((e) => _toInt(e))
          .toList(),
      tickets: (json['tickets'] as List? ?? []).map((e) => Ticket.fromJson(e)).toList(),
      totalPaid: json['total_paid'],
      totalPayable: json['total_payable'],
      due: json['due'],
      studyMaterials: (json['study_materials'] as List? ?? []).map((e) => StudyMaterial.fromJson(e)).toList(),
      assignments: (json['assignments'] as List? ?? []).map((e) => Assignment.fromJson(e)).toList(),
    );
  }
}

// Helper functions for safe type conversion
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class User {
  final int id;
  final String name;
  final String email;
  final String? status;
  final int? roleId;
  final int? instituteId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.status,
    this.roleId,
    this.instituteId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'],
      roleId: _toInt(json['role_id']),
      instituteId: _toInt(json['institute_id']),
    );
  }
}

class Student {
  final int id;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String? studentRollNo;
  final String? registrationNo;
  final String? academicSession;
  final int? classId;
  final int? sectionId;

  Student({
    required this.id,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.studentRollNo,
    this.registrationNo,
    this.academicSession,
    this.classId,
    this.sectionId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: _toInt(json['id']),
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'],
      studentRollNo: json['student_roll_no'],
      registrationNo: json['registration_no'],
      academicSession: json['academic_session'],
      classId: json['class_id'] != null ? _toInt(json['class_id']) : null,
      sectionId: json['section_id'] != null ? _toInt(json['section_id']) : null,
    );
  }
}

class Event {
  final int id;
  final String title;
  final String? description;
  final String? venue;
  final String? eventDate;
  final String? startTime;
  final String? endTime;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.venue,
    this.eventDate,
    this.startTime,
    this.endTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      venue: json['venue'],
      eventDate: json['event_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class Exam {
  final int id;
  final String name;
  final String? type;
  final String? code;
  final String? startDate;
  final String? endDate;

  Exam({
    required this.id,
    required this.name,
    this.type,
    this.code,
    this.startDate,
    this.endDate,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      type: json['type'],
      code: json['code'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class Ticket {
  final int id;
  final String title;
  final String? description;
  final String? priority;
  final String? status;

  Ticket({
    required this.id,
    required this.title,
    this.description,
    this.priority,
    this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
    );
  }
}

class StudyMaterial {
  final int id;
  final String title;
  final String? description;

  StudyMaterial({
    required this.id,
    required this.title,
    this.description,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
    );
  }
}

class Assignment {
  final int id;
  final String title;
  final String? description;
  final String? dueDate;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: _toInt(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['due_date'],
    );
  }
}
