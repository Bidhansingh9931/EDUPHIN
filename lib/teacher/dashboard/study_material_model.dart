
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
    final subject = json['subject']?['name'] ?? 'N/A';
    final className = json['class']?['name'] ?? 'N/A';
    final section = json['section']?['name'] ?? 'N/A';
    return ScheduleInfo(
      id: json['id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      displayText: '$subject ($className - $section)',
    );
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
}
