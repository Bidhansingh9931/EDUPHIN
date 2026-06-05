
class StudyMaterialPageData {
  final List<ScheduleInfo> schedules;
  final List<StudyMaterialInfo> studyMaterials;

  StudyMaterialPageData({required this.schedules, required this.studyMaterials});

  factory StudyMaterialPageData.fromJson(Map<String, dynamic> json) {
    return StudyMaterialPageData(
      schedules: (json['schedules'] as List?)
              ?.map((e) => ScheduleInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studyMaterials: (json['study_materials'] as List?)
              ?.map((e) => StudyMaterialInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedules': schedules.map((e) => e.toJson()).toList(),
      'study_materials': studyMaterials.map((e) => e.toJson()).toList(),
    };
  }
}

class ScheduleInfo {
  final int id;
  final String displayText;
  final int subjectId;
  final int classId;
  final int sectionId;

  ScheduleInfo(
      {required this.id, required this.displayText, required this.subjectId, required this.classId, required this.sectionId});

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      id: json['id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      displayText: json['displayText'] ?? '${json['subject']?['name'] ?? 'N/A'} (${json['class']?['name'] ?? 'N/A'} - ${json['section']?['name'] ?? 'N/A'})',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'class_id': classId,
      'section_id': sectionId,
      'displayText': displayText,
    };
  }
}

class StudyMaterialInfo {
  final int id;
  final String title;
  final String? description;
  final String filePath;
  final int subjectId;
  final int classId;
  final int sectionId;

  StudyMaterialInfo({
    required this.id,
    required this.title,
    this.description,
    required this.filePath,
    required this.subjectId,
    required this.classId,
    required this.sectionId,
  });

  factory StudyMaterialInfo.fromJson(Map<String, dynamic> json) {
    return StudyMaterialInfo(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'],
      filePath: json['file_path'] ?? '',
      subjectId: json['subject_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_path': filePath,
      'subject_id': subjectId,
      'class_id': classId,
      'section_id': sectionId,
    };
  }
}
