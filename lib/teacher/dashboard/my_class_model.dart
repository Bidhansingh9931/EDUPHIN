import 'package:eduphin/teacher/dashboard/class_models.dart';

class MyClassData {
  final List<Section> sections;
  final List<Schedule> schedules;
  final List<Student> students;

  MyClassData({
    required this.sections,
    required this.schedules,
    required this.students,
  });

  factory MyClassData.fromJson(Map<String, dynamic> json) {
    return MyClassData(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schedules: (json['schedules'] as List<dynamic>?)
              ?.map((e) => Schedule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      students: (json['students'] as List<dynamic>?)
              ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((e) => e.toJson()).toList(),
      'schedules': schedules.map((e) => e.toJson()).toList(),
      'students': students.map((e) => e.toJson()).toList(),
    };
  }
}

class Section {
  final int id;
  final String name;

  Section({required this.id, required this.name});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Section',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Schedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final Subject? subject;
  final TeacherClass? classInfo;
  final TeacherSection? sectionInfo;

  Schedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.classInfo,
    this.sectionInfo,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['weekday'] ?? 'Unknown Day',
      startTime: json['start_time'] ?? 'N/A',
      endTime: json['end_time'] ?? 'N/A',
      subject:
          json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      classInfo:
          json['class'] != null ? TeacherClass.fromJson(json['class']) : null,
      sectionInfo: json['section'] != null
          ? TeacherSection.fromJson(json['section'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'subject': subject?.toJson(),
      'class': classInfo?.toJson(),
      'section': sectionInfo?.toJson(),
    };
  }
}

class Subject {
  final String name;

  Subject({required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(name: json['name'] ?? 'Unnamed Subject');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Student {
  final int id;
  final String name;
  final String? rollNumber;
  final String? photo;

  Student({required this.id, required this.name, this.rollNumber, this.photo});

  factory Student.fromJson(Map<String, dynamic> json) {
    // Try to get name from user relation first, then from direct fields
    String studentName = json['user']?['name'] ?? 
                         json['full_name'] ?? 
                         (json['first_name'] != null ? "${json['first_name']} ${json['last_name'] ?? ''}" : null) ??
                         json['name'] ?? 
                         'Unnamed Student';

    return Student(
      id: json['id'] ?? 0,
      name: studentName.trim(),
      rollNumber: (json['roll_no'] ?? json['roll_number'] ?? json['roll'])?.toString(),
      photo: json['user']?['photo'] ?? json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roll_no': rollNumber,
      'photo': photo,
    };
  }
}
