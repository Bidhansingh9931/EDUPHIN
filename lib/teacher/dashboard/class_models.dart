
class ClassesAndSectionsData {
  final List<TeacherClass> classes;
  final List<TeacherSection> sections;

  ClassesAndSectionsData({required this.classes, required this.sections});

  factory ClassesAndSectionsData.fromJson(Map<String, dynamic> json) {
    return ClassesAndSectionsData(
      classes: (json['classes'] as List?)
              ?.map((e) => TeacherClass.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sections: (json['sections'] as List?)
              ?.map((e) => TeacherSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TeacherClass {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? level;

  TeacherClass({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.level,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    return TeacherClass(
      id: json['id'],
      name: json['name'] ?? 'N/A',
      code: json['code'] ?? 'N/A',
      description: json['description'],
      level: json['level'],
    );
  }
}

class TeacherSection {
  final int id;
  final String name;
  final int classId;
  final int? capacity;


  TeacherSection({
    required this.id,
    required this.name,
    required this.classId,
    this.capacity,
  });

  factory TeacherSection.fromJson(Map<String, dynamic> json) {
    return TeacherSection(
      id: json['id'],
      name: json['name'] ?? 'N/A',
      classId: json['class_id'],
      capacity: json['capacity'],
    );
  }
}

class TeacherSchedule {
  final int id;
  final TeacherClass classModel;
  final TeacherSection section;
  final TeacherSubject subject;

  TeacherSchedule({
    required this.id,
    required this.classModel,
    required this.section,
    required this.subject,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      id: json['id'],
      classModel: TeacherClass.fromJson(json['class']),
      section: TeacherSection.fromJson(json['section']),
      subject: TeacherSubject.fromJson(json['subject']),
    );
  }
}

class TeacherSubject {
  final int id;
  final String name;

  TeacherSubject({
    required this.id,
    required this.name,
  });

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      id: json['id'],
      name: json['name'] ?? 'N/A',
    );
  }
}

class TeacherStudent {
  final int id;
  final String name;

  TeacherStudent({
    required this.id,
    required this.name,
  });

  factory TeacherStudent.fromJson(Map<String, dynamic> json) {
    // Assuming the student's name is in a nested 'user' object.
    // This may need adjustment based on the actual API response.
    final userName = json['user'] != null && json['user']['name'] != null
        ? json['user']['name']
        : 'N/A';
    return TeacherStudent(
      id: json['id'],
      name: userName,
    );
  }
}

class MyClassDetails {
  final List<TeacherSection> sections;
  final List<TeacherSchedule> schedules;
  final List<TeacherStudent> students;

  MyClassDetails({
    required this.sections,
    required this.schedules,
    required this.students,
  });

  factory MyClassDetails.fromJson(Map<String, dynamic> json) {
    return MyClassDetails(
      sections: (json['sections'] as List)
          .map((sectionJson) => TeacherSection.fromJson(sectionJson))
          .toList(),
      schedules: (json['schedules'] as List)
          .map((scheduleJson) => TeacherSchedule.fromJson(scheduleJson))
          .toList(),
      students: (json['students'] as List)
          .map((studentJson) => TeacherStudent.fromJson(studentJson))
          .toList(),
    );
  }
}
