import 'dart:convert';
import 'package:http/http.dart' as http;
import 'employee_details.dart';

class EmployeeDetailsProvider {
  // Base URL for the API
  final String _baseUrl = 'https://your-api-base-url.com/api'; // TODO: Replace with your actual API base URL

  // Method to fetch employee details
  Future<EmployeeDetails> fetchEmployeeDetails(String employeeId) async {
    // TODO: Replace with your actual API endpoint and authentication
    // final response = await http.get(
    //   Uri.parse('$_baseUrl/employees/$employeeId'),
    //   headers: {
    //     'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Add your auth token here
    //   },
    // );
    //
    // if (response.statusCode == 200) {
    //   return EmployeeDetails.fromJson(json.decode(response.body));
    // } else {
    //   throw Exception('Failed to load employee details');
    // }

    // Mock data for demonstration purposes
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return EmployeeDetails(
        id: employeeId,
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        role: 'Developer',
        gender: 'Male',
        dateOfBirth: '1990-01-15',
        relationshipStatus: 'Single',
        phoneNumber: '123-456-7890',
        alternateNumber: '098-765-4321',
        address: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        pinCode: '12345',
        position: 'Senior Developer',
        employmentType: 'Full-time',
        joiningDate: '2022-01-01',
        experience: '5',
        status: 'Active',
        reference: 'Jane Smith',
        qualification: 'B.Sc. in Computer Science',
        matriculationMarks: '85%',
        intermediateMarks: '88%',
        bankAccountNumber: '123456789012',
        ifscCode: 'ABCD0001234',
        bankName: 'Example Bank',
        branch: 'Main Branch',
        emergencyContactName: 'Jane Doe',
        emergencyContactNumber: '111-222-3333',
    );
  }

  // Method to save employee details
  Future<void> saveEmployeeDetails(EmployeeDetails details) async {
    // TODO: Replace with your actual API endpoint for updating details
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/employees/${details.id}'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Add your auth token here
    //   },
    //   body: json.encode(details.toJson()),
    // );
    //
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to save employee details');
    // }

    // Simulate a network delay for saving
    await Future.delayed(const Duration(seconds: 1));
    print('Saved details: ${json.encode(details.toJson())}');
    // In a real app, you would handle the response or potential errors here.
  }
}
