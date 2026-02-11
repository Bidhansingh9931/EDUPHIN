import 'dart:convert';
import 'package:http/http.dart' as http;
import 'new_employee_model.dart';

class AddEmployeeProvider {
  // TODO: Replace with your actual API base URL
  final String _baseUrl = 'http://192.168.1.69/eduphin/api/moderator';

  Future<void> addEmployee(NewEmployee employee) async {
    final url = Uri.parse('$_baseUrl/accounts');

    // TODO: Replace with your actual authentication token
    const String authToken = 'YOUR_AUTH_TOKEN';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken', // Add your auth token here
        },
        body: json.encode(employee.toJson()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Handle error response
        print('Failed to add employee: ${response.body}');
        throw Exception('Failed to add employee. Status code: ${response.statusCode}\nBody: ${response.body}');
      }

      // Handle success response
      print('Employee added successfully: ${response.body}');

    } catch (e) {
      print('Error adding employee: $e');
      throw Exception('Error connecting to the server: $e');
    }
  }
}
