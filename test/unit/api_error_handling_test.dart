import 'package:flutter_test/flutter_test.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ApiService Error Message Parsing Tests', () {
    test('errorMessage should parse Laravel style validation errors', () {
      final response = http.Response('{"errors": {"email": ["The email field is required."], "password": ["The password must be at least 8 characters."]}}', 422);
      
      final message = ApiService.errorMessage(response, 'Default error');
      
      expect(message, contains('The email field is required.'));
      expect(message, contains('The password must be at least 8 characters.'));
    });

    test('errorMessage should return message field if present', () {
      final response = http.Response('{"message": "Unauthorized access"}', 401);
      
      final message = ApiService.errorMessage(response, 'Default error');
      
      expect(message, 'Unauthorized access');
    });

    test('errorMessage should return default message if json is invalid', () {
      final response = http.Response('Internal Server Error', 500);
      
      final message = ApiService.errorMessage(response, 'Default error');
      
      expect(message, 'Default error');
    });
  });
}
