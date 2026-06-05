import 'dart:convert';

class SuperAdminDashboardData {
  final List<UserAccount> accounts;
  final List<Institute> institutes;
  final List<StudentDetail> students;
  final List<Section> classes;
  final List<Event> events;
  final List<ExamType> examTypes;
  final List<Testimonial> testimonials;
  final List<RoleInfo> roles;
  final bool dbStatus;
  final String dataUsage;
  final String uptime;
  final List<AuditLog> recentActivities;

  SuperAdminDashboardData({
    required this.accounts,
    required this.institutes,
    required this.students,
    required this.classes,
    required this.events,
    required this.examTypes,
    required this.testimonials,
    required this.roles,
    required this.dbStatus,
    required this.dataUsage,
    required this.uptime,
    required this.recentActivities,
  });

  factory SuperAdminDashboardData.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardData(
      accounts: (json['accounts'] as List? ?? []).map((e) => UserAccount.fromJson(e)).toList(),
      institutes: (json['institutes'] as List? ?? []).map((e) => Institute.fromJson(e)).toList(),
      students: (json['students'] as List? ?? []).map((e) => StudentDetail.fromJson(e)).toList(),
      classes: (json['classes'] as List? ?? []).map((e) => Section.fromJson(e)).toList(),
      events: (json['events'] as List? ?? []).map((e) => Event.fromJson(e)).toList(),
      examTypes: (json['examTypes'] as List? ?? []).map((e) => ExamType.fromJson(e)).toList(),
      testimonials: (json['testimonials'] as List? ?? []).map((e) => Testimonial.fromJson(e)).toList(),
      roles: (json['roles'] as List? ?? []).map((e) => RoleInfo.fromJson(e)).toList(),
      dbStatus: json['dbStatus'] ?? false,
      dataUsage: json['dataUsage']?.toString() ?? '',
      uptime: json['uptime']?.toString() ?? '',
      recentActivities: (json['recentActivities'] as List? ?? []).map((e) => AuditLog.fromJson(e)).toList(),
    );
  }
}

class UserAccount {
  final int id;
  final String name;
  final String email;
  final int roleId;

  UserAccount({required this.id, required this.name, required this.email, required this.roleId});

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
    );
  }
}

class Institute {
  final int id;
  final String name;
  final String? code;
  final String? status;

  Institute({required this.id, required this.name, this.code, this.status});

  factory Institute.fromJson(Map<String, dynamic> json) {
    return Institute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['institute_code'],
      status: json['status'],
    );
  }
}

class StudentDetail {
  final int id;
  final String? studentName;

  StudentDetail({required this.id, this.studentName});

  factory StudentDetail.fromJson(Map<String, dynamic> json) {
    return StudentDetail(
      id: json['id'] ?? 0,
      studentName: json['student_name'],
    );
  }
}

class Section {
  final int id;
  final String? sectionName;

  Section({required this.id, this.sectionName});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? 0,
      sectionName: json['section_name'],
    );
  }
}

class Event {
  final int id;
  final String title;

  Event({required this.id, required this.title});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class ExamType {
  final int id;
  final String name;

  ExamType({required this.id, required this.name});

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Testimonial {
  final int id;
  final String? name;
  final String? message;

  Testimonial({required this.id, this.name, this.message});

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? 0,
      name: json['name'],
      message: json['message'],
    );
  }
}

class RoleInfo {
  final int id;
  final String name;
  final int usersCount;

  RoleInfo({required this.id, required this.name, required this.usersCount});

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      usersCount: json['users_count'] ?? 0,
    );
  }
}

class AuditLog {
  final int id;
  final int? userId;
  final String? event;
  final String? model;
  final String? ipAddress;
  final String? createdAt;

  AuditLog({this.id = 0, this.userId, this.event, this.model, this.ipAddress, this.createdAt});

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      event: json['event'],
      model: json['model'],
      ipAddress: json['ip_address'],
      createdAt: json['created_at'],
    );
  }
}

class ContactMessage {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? subject;
  final String? message;
  final String? createdAt;

  ContactMessage({required this.id, this.name, this.email, this.phone, this.subject, this.message, this.createdAt});

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      subject: json['subject'],
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}
