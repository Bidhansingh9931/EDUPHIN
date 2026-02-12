import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'employee_details.dart';

class EmployeeDetailsProvider {
  Future<EmployeeDetails> fetchEmployeeDetails(String employeeId) async {
    try {
      final response = await ApiService.get('moderator/accounts/$employeeId');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return EmployeeDetails.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to load employee details. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching employee details: $e');
    }
  }

  Future<void> saveEmployeeDetails(EmployeeDetails details) async {
    try {
      final response = await ApiService.post('moderator/accounts/${details.id}', details.toJson());

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save employee details. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while saving employee details: $e');
    }
  }
}
