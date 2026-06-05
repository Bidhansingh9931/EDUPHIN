import 'package:flutter_test/flutter_test.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';

void main() {
  group('TeacherDashboardData Model Tests', () {
    test('UserDetail.fromJson should handle different JSON structures', () {
      // Case 1: Simple name
      final json1 = {'id': 1, 'name': 'John Doe'};
      final user1 = UserDetail.fromJson(json1);
      expect(user1.name, 'John Doe');

      // Case 2: Nested user object
      final json2 = {
        'id': 2,
        'user': {'name': 'Jane Doe', 'photo': 'jane.png'}
      };
      final user2 = UserDetail.fromJson(json2);
      expect(user2.name, 'Jane Doe');
      expect(user2.photo, 'jane.png');
    });

    test('TeacherDashboardData.fromJson should parse full response', () {
      final json = {
        'user_detail': {'id': 1, 'name': 'Teacher'},
        'last_salary': {'net_salary': '50000', 'status': 'Paid'},
        'events': [],
        'active_exams': [{'name': 'Mid Term', 'status': 'Upcoming'}],
        'created_tickets': [],
        'assigned_tickets': [],
        'assignments': [],
        'leaves': [],
        'mentor_sections': [],
        'today_schedule': [],
        'study_materials': []
      };

      final data = TeacherDashboardData.fromJson(json);

      expect(data.userDetail.name, 'Teacher');
      expect(data.lastSalary?.amount, 50000.0);
      expect(data.activeExams.length, 1);
      expect(data.activeExams[0].name, 'Mid Term');
    });
  });
}
