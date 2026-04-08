
class TeacherScheduleItem {
  final int id;
  final String? startTime;
  final String? endTime;
  final Map<String, dynamic>? subject;
  final Map<String, dynamic>? classInfo;
  final Map<String, dynamic>? section;
  final bool isOverride;
  final String? overrideType;
  final String? note;
  final Map<String, dynamic>? newTeacher;

  TeacherScheduleItem({
    required this.id,
    this.startTime,
    this.endTime,
    this.subject,
    this.classInfo,
    this.section,
    this.isOverride = false,
    this.overrideType,
    this.note,
    this.newTeacher,
  });

  factory TeacherScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleItem(
      id: json['id'] ?? 0,
      startTime: json['start_time'],
      endTime: json['end_time'],
      subject: json['subject'] as Map<String, dynamic>?,
      classInfo: json['class'] as Map<String, dynamic>?,
      section: json['section'] as Map<String, dynamic>?,
      isOverride: json['is_override'] ?? false,
      overrideType: json['override_type'],
      note: json['note'],
      newTeacher: json['new_teacher'] as Map<String, dynamic>?,
    );
  }
}
