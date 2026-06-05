
class ViewSchedulePageData {
  final List<ClassDropdownItem> classes;
  final List<SectionDropdownItem> sections;
  final List<ScheduleEntry> schedules;
  final List<SubjectInfo> subjects;
  final List<TeacherInfo> teachers;

  ViewSchedulePageData({
    required this.classes,
    required this.sections,
    required this.schedules,
    required this.subjects,
    required this.teachers,
  });

  factory ViewSchedulePageData.fromJson(Map<String, dynamic> json) {
    return ViewSchedulePageData(
      classes: ((json['classes'] ?? []) as List)
          .map((i) => ClassDropdownItem.fromJson(i))
          .toList(),
      sections: ((json['sections'] ?? []) as List)
          .map((i) => SectionDropdownItem.fromJson(i))
          .toList(),
      schedules: ((json['schedules'] ?? []) as List)
          .map((i) => ScheduleEntry.fromJson(i))
          .toList(),
      subjects: ((json['subjects'] ?? []) as List)
          .map((i) => SubjectInfo.fromJson(i))
          .toList(),
      teachers: ((json['teachers'] ?? []) as List)
          .map((i) => TeacherInfo.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes': classes.map((i) => i.toJson()).toList(),
      'sections': sections.map((i) => i.toJson()).toList(),
      'schedules': schedules.map((i) => i.toJson()).toList(),
      'subjects': subjects.map((i) => i.toJson()).toList(),
      'teachers': teachers.map((i) => i.toJson()).toList(),
    };
  }
}

class ClassDropdownItem {
  final int id;
  final String name;

  ClassDropdownItem({required this.id, required this.name});

  factory ClassDropdownItem.fromJson(Map<String, dynamic> json) {
    return ClassDropdownItem(
      id: json['id'] ?? 0, 
      name: json['name'] ?? json['class_name'] ?? 'Unknown Class'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SectionDropdownItem {
  final int id;
  final String name;
  final int classId;

  SectionDropdownItem({required this.id, required this.name, required this.classId});

  factory SectionDropdownItem.fromJson(Map<String, dynamic> json) {
    return SectionDropdownItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['section_name'] ?? 'Section ${json['id'] ?? ''}',
      classId: json['class_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_id': classId,
    };
  }
}

class ScheduleEntry {
  final int id;
  final int classId;
  final int sectionId;
  final int subjectId;
  final int? teacherId;
  final String weekday;
  final String startTime;
  final String endTime;

  ScheduleEntry({
    required this.id,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    this.teacherId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      teacherId: json['teacher_id'],
      weekday: json['weekday'] ?? 'N/A',
      startTime: json['start_time'] ?? 'N/A',
      endTime: json['end_time'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class SubjectInfo {
  final int id;
  final String name;

  SubjectInfo({required this.id, required this.name});

  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      id: json['id'] ?? 0, 
      name: json['name'] ?? json['subject_name'] ?? 'Unknown Subject'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TeacherInfo {
  final int id;
  final String name;

  TeacherInfo({required this.id, required this.name});

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    String name = 'Unknown Teacher';
    if (json['name'] != null) {
      name = json['name'];
    } else if (json['user'] != null && json['user']['name'] != null) {
      name = json['user']['name'];
    }
    return TeacherInfo(id: json['id'] ?? 0, name: name);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
