
class ExamPageData {
  final List<TeacherExam> exams;

  ExamPageData({required this.exams});

  factory ExamPageData.fromJson(Map<String, dynamic> json) {
    return ExamPageData(
      exams: (json['exams'] as List<dynamic>? ?? [])
          .map((e) => TeacherExam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exams': exams.map((e) => e.toJson()).toList(),
    };
  }
}

class TeacherExam {
  final int id;
  final String name;
  final String code;
  final String type;
  final String startDate;
  final String endDate;
  final String? description;

  TeacherExam({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  factory TeacherExam.fromJson(Map<String, dynamic> json) {
    return TeacherExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      code: json['code'] ?? 'N/A',
      type: json['type'] ?? 'N/A',
      startDate: json['start_date'] ?? DateTime.now().toIso8601String(),
      endDate: json['end_date'] ?? DateTime.now().toIso8601String(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
    };
  }
}

class ExamScheduleData {
  final TeacherExam exam;
  final List<ExamSchedule> schedules;

  ExamScheduleData({required this.exam, required this.schedules});

  factory ExamScheduleData.fromJson(Map<String, dynamic> json) {
    return ExamScheduleData(
      exam: TeacherExam.fromJson(json['exam'] ?? {}),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((s) => ExamSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam': exam.toJson(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }
}

class ExamSchedule {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String? roomNo;
  final String subjectName;
  final String className;
  final String sectionName;

  ExamSchedule({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.roomNo,
    required this.subjectName,
    required this.className,
    required this.sectionName,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      id: json['id'] ?? 0,
      date: json['date'] ?? 'N/A',
      startTime: json['start_time'] ?? 'N/A',
      endTime: json['end_time'] ?? 'N/A',
      roomNo: json['room_no'],
      subjectName: json['subject']?['name'] ?? 'N/A',
      className: json['class']?['name'] ?? 'N/A',
      sectionName: json['section']?['name'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'room_no': roomNo,
      'subject': {'name': subjectName},
      'class': {'name': className},
      'section': {'name': sectionName},
    };
  }
}

class ExamPaper {
  final int id;
  final String examName;
  final String subjectName;
  final String className;
  final String sectionName;
  final String date;

  ExamPaper({
    required this.id,
    required this.examName,
    required this.subjectName,
    required this.className,
    required this.sectionName,
    required this.date,
  });

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: json['id'] ?? 0,
      examName: json['exam']?['name'] ?? 'N/A',
      subjectName: json['subject']?['name'] ?? 'N/A',
      className: json['class']?['name'] ?? 'N/A',
      sectionName: json['section']?['name'] ?? 'N/A',
      date: json['date'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam': {'name': examName},
      'subject': {'name': subjectName},
      'class': {'name': className},
      'section': {'name': sectionName},
      'date': date,
    };
  }
}

class ExamStudentRegistration {
  final int id;
  final int studentId;
  final String studentName;
  final String? rollNo;
  String? marksObtained;
  String? maxMarks;
  String? gradeName;
  String? remarks;

  ExamStudentRegistration({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.rollNo,
    this.marksObtained,
    this.maxMarks,
    this.gradeName,
    this.remarks,
  });

  factory ExamStudentRegistration.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    final user = student['user'] ?? {};
    final result = json['exam_result'] != null ? (json['exam_result'] as List).firstOrNull : null;

    return ExamStudentRegistration(
      id: json['id'] ?? 0,
      studentId: student['id'] ?? 0,
      studentName: user['name'] ?? 'N/A',
      rollNo: student['roll_no']?.toString(),
      marksObtained: result?['marks_obtained']?.toString(),
      maxMarks: result?['max_marks']?.toString(),
      gradeName: result?['grade_name'],
      remarks: result?['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': {
        'id': studentId,
        'roll_no': rollNo,
        'user': {'name': studentName},
      },
      'exam_result': [
        {
          'marks_obtained': marksObtained,
          'max_marks': maxMarks,
          'grade_name': gradeName,
          'remarks': remarks,
        }
      ],
    };
  }
}
