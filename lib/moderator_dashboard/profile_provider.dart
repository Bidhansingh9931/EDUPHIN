import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'profile_model.dart';

class ProfileProvider {
  final String _profileApiUrl = "${ApiService.baseUrl}/api/moderator/profile";

  Future<ProfileData> fetchProfileData() async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      debugPrint("Fetching profile data from: $_profileApiUrl");
      final response = await http.get(
        Uri.parse(_profileApiUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        debugPrint("Profile API Response received.");
        final jsonData = jsonDecode(response.body);

        if (jsonData['user'] is Map<String, dynamic> &&
            jsonData['details'] is Map<String, dynamic>) {
          final Map<String, dynamic> userMap = jsonData['user'];
          final Map<String, dynamic> detailsMap = jsonData['details'];

          if (detailsMap.containsKey('id')) {
            detailsMap['details_id'] = detailsMap.remove('id');
          }

          final Map<String, dynamic> combinedData = {}
            ..addAll(userMap)
            ..addAll(detailsMap);

          return ProfileData.fromMap(combinedData);
        } else {
          throw Exception("Profile data from server has an unexpected format.");
        }
      } else {
        debugPrint(
            "Failed to load profile. Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception(
            "Failed to load profile data. Check the URL and server logs.");
      }
    } on TimeoutException {
      throw Exception("Connection timed out. Please check your network.");
    } catch (e) {
      debugPrint("An error occurred fetching profile: $e");
      throw Exception("An error occurred: $e");
    }
  }

  Future<void> saveProfileData(ProfileData data) async {
    final String? token = await ApiService.getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    // Correct endpoint for updating the profile
    final String updateUrl = "$_profileApiUrl/update";

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      debugPrint("Saving profile data to: $updateUrl using POST (multipart/form-data).");

      final request = http.MultipartRequest('POST', Uri.parse(updateUrl));
      request.headers.addAll(headers);

      // No method spoofing needed if the backend route is POST
      // request.fields['_method'] = 'PUT';

      final Map<String, dynamic> fields = data.toMap();

      fields.forEach((key, value) {
        request.fields[key] = value?.toString() ?? '';
      });

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 422) { // Handle validation errors specifically
        final responseBody = jsonDecode(response.body);
        final errors = responseBody['errors'] as Map<String, dynamic>;
        String errorMessage = responseBody['message'] ?? "Validation failed!";
        // Extract and format error messages
        final errorDetails = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n');
        throw Exception('$errorMessage\n$errorDetails');
      } else if (response.statusCode != 200) {
        debugPrint("Failed to save profile. Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to save profile. Server responded with status ${response.statusCode}");
      }

      debugPrint("Profile saved successfully. Response: ${response.body}");

    } on TimeoutException {
      throw Exception("Connection timed out. Please check your network.");
    } catch (e) {
      debugPrint("An error occurred saving profile: $e");
      // Re-throw the original exception to preserve its type and message
      rethrow;
    }
  }

    Future<String> downloadProfileData() async {
    try {
      debugPrint("Starting profile download...");
      if (Platform.isAndroid) {
        debugPrint("Requesting storage permission...");
        final status = await Permission.storage.request();
        debugPrint("Permission status: $status");
        if (status != PermissionStatus.granted) {
          throw Exception("Storage permission not granted. Status was $status");
        }
      }

      debugPrint("Fetching profile data for download...");
      final profileData = await fetchProfileData();
      debugPrint("Profile data fetched successfully.");
      
      debugPrint("Encoding data to JSON...");
      const jsonEncoder = JsonEncoder.withIndent('  ');
      final jsonData = jsonEncoder.convert(profileData.toMap());
      debugPrint("JSON data encoded successfully.");

      debugPrint("Getting downloads directory...");
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not get downloads directory.");
      }
      debugPrint("Downloads directory: ${directory.path}");

      final filePath = '${directory.path}/profile_data.json';
      debugPrint("File path will be: $filePath");

      final file = File(filePath);
      debugPrint("Writing to file...");
      await file.writeAsString(jsonData);
      debugPrint("File written successfully.");

      return filePath;
    } catch (e, s) {
      debugPrint("An error occurred during download: $e");
      debugPrint("Stack trace: $s");
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
  }
}
