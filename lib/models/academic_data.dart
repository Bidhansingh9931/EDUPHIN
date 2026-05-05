import 'class.dart';

class AcademicData {
  final List<Class> classes;
  final List<String> lateralAdmissionOptions;
  final List<String> admissionCategories;
  final List<String> studentStatuses;
  final List<String> academicSessions;
  final List<String> academicYears;

  AcademicData({
    this.classes = const [],
    this.lateralAdmissionOptions = const ['Yes', 'No'],
    this.admissionCategories = const ['General', 'OBC', 'SC', 'ST'],
    this.studentStatuses = const ['Active', 'Inactive'],
    this.academicSessions = const ['2023-24', '2024-25', '2025-26'],
    this.academicYears = const ['2023', '2024', '2025', '2026'],
  });
}
