import 'package:eduphin/manager_dashboard/events/event_model.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';

class AssignmentPageData {
  final List<AssignmentSchedule> schedules;
  final List<Assignment> assignments;

  AssignmentPageData({required this.schedules, required this.assignments});

  factory AssignmentPageData.fromJson(Map<String, dynamic> json) {
    return AssignmentPageData(
      schedules: (json['schedules'] as List? ?? [])
          .map((item) => AssignmentSchedule.fromJson(item))
          .toList(),
      assignments: (json['assignments'] as List? ?? [])
          .map((item) => Assignment.fromJson(item))
          .toList(),
    );
  }
}

class TeacherDashboardData {
  final UserDetail userDetail;
  final Salary? lastSalary;
  final List<Event> events;
  final List<ExamType> activeExams;
  final List<SupportTicket> createdTickets;
  final List<SupportTicket> assignedTickets;
  final List<Assignment> assignments;
  final List<StudentLeave> leaves;
  final List<Section> mentorSections;
  final List<ClassSchedule> todaySchedule;
  final List<StudyMaterial> studyMaterials;

  TeacherDashboardData({
    required this.userDetail,
    this.lastSalary,
    required this.events,
    required this.activeExams,
    required this.createdTickets,
    required this.assignedTickets,
    required this.assignments,
    required this.leaves,
    required this.mentorSections,
    required this.todaySchedule,
    required this.studyMaterials,
  });

  factory TeacherDashboardData.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardData(
      userDetail: UserDetail.fromJson(json['user_detail'] ?? {}),
      lastSalary: json['last_salary'] != null ? Salary.fromJson(json['last_salary']) : null,
      events: (json['events'] as List? ?? []).map((x) => Event.fromJson(x)).toList(),
      activeExams: (json['active_exams'] as List? ?? []).map((i) => ExamType.fromJson(i)).toList(),
      createdTickets: (json['created_tickets'] as List? ?? []).map((i) => SupportTicket.fromJson(i)).toList(),
      assignedTickets: (json['assigned_tickets'] as List? ?? []).map((i) => SupportTicket.fromJson(i)).toList(),
      assignments: (json['assignments'] as List? ?? []).map((i) => Assignment.fromJson(i)).toList(),
      leaves: (json['leaves'] as List? ?? []).map((i) => StudentLeave.fromJson(i)).toList(),
      mentorSections: (json['mentor_sections'] as List? ?? []).map((i) => Section.fromJson(i)).toList(),
      todaySchedule: (json['today_schedule'] as List? ?? []).map((i) => ClassSchedule.fromJson(i)).toList(),
      studyMaterials: (json['study_materials'] as List? ?? []).map((i) => StudyMaterial.fromJson(i)).toList(),
    );
  }
}

class UserDetail {
  final int id;
  final String name;
  final String? photo;
  final String? roleName;
  final String? employeeId;
  final String? phone;


  UserDetail({required this.id, required this.name, this.photo, this.roleName, this.employeeId, this.phone});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    // Robust name detection: check top level, then inside 'user' object
    String detectedName = 'Unknown';
    if (json['name'] != null) {
      detectedName = json['name'].toString();
    } else if (json['user'] != null && json['user'] is Map && json['user']['name'] != null) {
      detectedName = json['user']['name'].toString();
    }

    return UserDetail(
      id: json['id'] ?? 0,
      name: detectedName,
      photo: json['photo'],
      roleName: json['role_name'] ?? (json['role'] is Map ? json['role']['name'] : 'Teacher'),
      employeeId: json['employee_id']?.toString() ?? json['id']?.toString() ?? 'N/A',
      phone: json['phone']?.toString() ?? 'N/A',
    );
  }
}

class Salary {
  final double amount;
  final String status;
  final String? paymentDate;

  Salary({required this.amount, required this.status, this.paymentDate});

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      amount: double.tryParse(json['net_salary']?.toString() ?? json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'N/A',
      paymentDate: json['payment_date'],
    );
  }
}

class ExamType {
    final String name;
    final String status;
    ExamType({required this.name, required this.status});
    factory ExamType.fromJson(Map<String, dynamic> json) {
        return ExamType(name: json['name'] ?? '', status: json['status'] ?? '');
    }
}

class Assignment {
  final int id;
  final int subjectId;
  final int classId;
  final int sectionId;
  final String title;
  final String? description;
  final String attachment;
  final String dueDate;
  final String status;

  Assignment({
    required this.id,
    required this.subjectId,
    required this.classId,
    required this.sectionId,
    required this.title,
    this.description,
    required this.attachment,
    required this.dueDate,
    this.status = 'Active',
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      attachment: json['attachment'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }
}

class StudentLeave {
    final String reason;
    final String status;
    final Map<String, dynamic>? student;
    StudentLeave({required this.reason, required this.status, this.student});
    factory StudentLeave.fromJson(Map<String, dynamic> json) {
        return StudentLeave(
          reason: json['reason'] ?? '',
          status: json['status'] ?? '',
          student: json['student'] is Map<String, dynamic> ? json['student'] : null,
        );
    }
}

class Section {
    final String name;
    Section({required this.name});
    factory Section.fromJson(Map<String, dynamic> json) {
        return Section(name: json['name'] ?? '');
    }
}

class ClassSchedule {
    final int id;
    final String startTime;
    final String endTime;
    final Map<String, dynamic>? subject;
    final Map<String, dynamic>? classModel;
    final Map<String, dynamic>? section;
    final int subjectId;
    final int classId;
    final int sectionId;

    ClassSchedule({
      required this.id,
      required this.startTime,
      required this.endTime,
      this.subject,
      this.classModel,
      this.section,
      required this.subjectId,
      required this.classId,
      required this.sectionId,
    });

    factory ClassSchedule.fromJson(Map<String, dynamic> json) {
        return ClassSchedule(
            id: json['id'] ?? 0,
            startTime: json['start_time'] ?? '',
            endTime: json['end_time'] ?? '',
            subject: json['subject'] is Map<String, dynamic> ? json['subject'] : null,
            classModel: json['class'] is Map<String, dynamic> ? json['class'] : null,
            section: json['section'] is Map<String, dynamic> ? json['section'] : null,
            subjectId: json['subject_id'] ?? 0,
            classId: json['class_id'] ?? 0,
            sectionId: json['section_id'] ?? 0,
        );
    }
}

class StudyMaterial {
    final String title;
    StudyMaterial({required this.title});
    factory StudyMaterial.fromJson(Map<String, dynamic> json) {
        return StudyMaterial(title: json['title'] ?? '');
    }
}

class AssignmentSchedule {
  final int id;
  final String subjectName;
  final String className;
  final String sectionName;
  final int subjectId;
  final int classId;
  final int sectionId;

  AssignmentSchedule({
    required this.id,
    required this.subjectName,
    required this.className,
    required this.sectionName,
    required this.subjectId,
    required this.classId,
    required this.sectionId,
  });

  factory AssignmentSchedule.fromJson(Map<String, dynamic> json) {
    return AssignmentSchedule(
      id: json['id'] ?? 0,
      subjectName: (json['subject'] is Map ? json['subject']['name'] : null) ?? 'N/A',
      className: (json['class'] is Map ? json['class']['name'] : null) ?? 'N/A',
      sectionName: (json['section'] is Map ? json['section']['name'] : null) ?? 'N/A',
      subjectId: json['subject_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
    );
  }
}
