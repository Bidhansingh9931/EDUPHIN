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

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'student': student?.toJson(),
      'attendance_percentage': attendancePercentage,
      'events': events.map((e) => e.toJson()).toList(),
      'available_exams': availableExams.map((e) => e.toJson()).toList(),
      'registered_exam_ids': registeredExamIds,
      'tickets': tickets.map((e) => e.toJson()).toList(),
      'total_paid': totalPaid,
      'total_payable': totalPayable,
      'due': due,
      'study_materials': studyMaterials.map((e) => e.toJson()).toList(),
      'assignments': assignments.map((e) => e.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'role_id': roleId,
      'institute_id': instituteId,
    };
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
  final String? profileImage;

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
    this.profileImage,
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
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'student_roll_no': studentRollNo,
      'registration_no': registrationNo,
      'academic_session': academicSession,
      'class_id': classId,
      'section_id': sectionId,
      'profile_image': profileImage,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'venue': venue,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'code': code,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class Ticket {
  final int id;
  final String? encryptedId;
  final String title;
  final String? description;
  final String? priority;
  final String? status;

  Ticket({
    required this.id,
    this.encryptedId,
    required this.title,
    this.description,
    this.priority,
    this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: _toInt(json['id']),
      encryptedId: json['encrypted_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encrypted_id': encryptedId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
    };
  }
}
