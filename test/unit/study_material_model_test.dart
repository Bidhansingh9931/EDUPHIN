import 'package:flutter_test/flutter_test.dart';
import 'package:eduphin/teacher/dashboard/study_material_model.dart';

void main() {
  group('StudyMaterialPageData Model Tests', () {
    test('fromJson should create a valid object', () {
      final json = {
        'schedules': [
          {
            'id': 1,
            'subject_id': 101,
            'class_id': 201,
            'section_id': 301,
            'displayText': 'Maths (10 - A)'
          }
        ],
        'study_materials': [
          {
            'id': 1,
            'title': 'Test Material',
            'description': 'Test Description',
            'file_path': 'path/to/file.pdf',
            'subject_id': 101,
            'class_id': 201,
            'section_id': 301
          }
        ]
      };

      final data = StudyMaterialPageData.fromJson(json);

      expect(data.schedules.length, 1);
      expect(data.schedules[0].id, 1);
      expect(data.schedules[0].displayText, 'Maths (10 - A)');
      
      expect(data.studyMaterials.length, 1);
      expect(data.studyMaterials[0].title, 'Test Material');
      expect(data.studyMaterials[0].description, 'Test Description');
    });

    test('fromJson should handle empty lists', () {
      final json = {
        'schedules': [],
        'study_materials': []
      };

      final data = StudyMaterialPageData.fromJson(json);

      expect(data.schedules, isEmpty);
      expect(data.studyMaterials, isEmpty);
    });

    test('toJson should return valid map', () {
      final schedule = ScheduleInfo(
        id: 1,
        displayText: 'Maths',
        subjectId: 101,
        classId: 201,
        sectionId: 301
      );
      final material = StudyMaterialInfo(
        id: 1,
        title: 'Title',
        filePath: 'path',
        subjectId: 101,
        classId: 201,
        sectionId: 301
      );
      final data = StudyMaterialPageData(
        schedules: [schedule],
        studyMaterials: [material]
      );

      final json = data.toJson();

      expect(json['schedules'][0]['id'], 1);
      expect(json['study_materials'][0]['title'], 'Title');
    });
  });
}
