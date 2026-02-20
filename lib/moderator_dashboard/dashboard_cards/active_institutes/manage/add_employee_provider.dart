import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'new_employee_model.dart';

class AddEmployeeProvider {
  Future<void> addEmployee(NewEmployee employee) async {
    try {
      // THE FIX:
      // The error you are seeing is because a File (the image) cannot be sent as text (JSON).
      // To upload a file, you MUST use a 'multipart' request, which sends the file and text data separately.
      // The previous code used `ApiService.post` which is only for text and will always fail with a file.

      // 1. Prepare the text fields for the multipart request.
      final fields = employee.toApiData();

      // 2. Prepare the image file for the multipart request.
      final files = <String, File>{};
      if (employee.profileImage != null) {
        files['profile_image'] = employee.profileImage!;
      }

      // 3. Send the request using the correct ApiService function for file uploads.
      final streamedResponse = await ApiService.postMultipart('moderator/accounts', fields, files: files);

      // 4. Handle the server's response.
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'Failed to add employee. Status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      // Rethrow the error to the UI to make it visible.
      throw Exception('An error occurred: $e');
    }
  }
}
