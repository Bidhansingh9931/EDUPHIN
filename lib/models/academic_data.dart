import 'class.dart';

class AcademicData {
  final List<Class> classes;
  final List<String> lateralAdmissionOptions;
  final List<String> admissionCategories;
  final List<String> studentStatuses;

  AcademicData({
    this.classes = const [],
    this.lateralAdmissionOptions = const ['Yes', 'No'],
    this.admissionCategories = const ['General', 'OBC', 'SC', 'ST'],
    this.studentStatuses = const ['Active', 'Inactive'],
  });
}
