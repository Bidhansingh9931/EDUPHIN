import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'new_employee_model.dart';

class AddEmployeeProvider {
  Future<void> addEmployee(NewEmployee employee) async {
    try {
      final response = await ApiService.post('moderator/accounts', employee.toJson());

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Handle error response
        print('Failed to add employee: ${response.body}');
        throw Exception(
            'Failed to add employee. Status code: ${response.statusCode}\nBody: ${response.body}');
      }

      // Handle success response
      print('Employee added successfully: ${response.body}');
    } catch (e) {
      print('Error adding employee: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }
}
