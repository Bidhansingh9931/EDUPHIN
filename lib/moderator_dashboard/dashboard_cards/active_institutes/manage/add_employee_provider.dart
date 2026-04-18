import 'dart:io';
import 'dart:typed_data';
import 'package:eduphin/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'new_employee_model.dart';

class AddEmployeeProvider {
  Future<void> addEmployee(NewEmployee employee) async {
    try {
      final fields = employee.toApiData();
      http.StreamedResponse streamedResponse;

      if (kIsWeb && employee.webImage != null) {
        streamedResponse = await ApiService.postMultipartFromBytes(
          'moderator/accounts',
          fields,
          files: {'profile_image': employee.webImage!},
          fileNames: {'profile_image': employee.imageName ?? 'profile.jpg'},
        );
      } else {
        final files = employee.profileImage != null ? {'profile_image': employee.profileImage!} : null;
        streamedResponse = await ApiService.postMultipart('moderator/accounts', fields, files: files);
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'Failed to add employee. Status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
