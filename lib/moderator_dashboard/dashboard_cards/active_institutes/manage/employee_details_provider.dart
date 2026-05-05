import 'package:eduphin/services/error_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eduphin/services/api_service.dart';
import 'employee_details.dart';

class EmployeeDetailsProvider {
  static const String _cacheKeyPrefix = 'employee_details_';

  Future<EmployeeDetails?> getCachedEmployeeDetails(String employeeId) async {
    final cached = await CacheHelper.load(_cacheKeyPrefix + employeeId);
    if (cached != null) {
      return EmployeeDetails.fromJson(cached);
    }
    return null;
  }

  Future<EmployeeDetails?> fetchEmployeeDetails(String employeeId, {bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await getCachedEmployeeDetails(employeeId);
        if (cached != null) {
          debugPrint('DEBUG: Using cached details for $employeeId');
          return cached;
        }
      }
      final url = 'moderator/accounts/$employeeId';
      debugPrint('DEBUG: Calling API: $url');
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('DEBUG: API Response for $employeeId: ${response.body}');
        final data = responseData['account'] ?? responseData['data'];
        if (data != null && data is Map<String, dynamic>) {
          await CacheHelper.save(_cacheKeyPrefix + employeeId, data);
          return EmployeeDetails.fromJson(data);
        } else {
          return null;
        }
      } else {
        throw ApiException('Failed to load employee details', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> saveEmployeeDetails(EmployeeDetails details) async {
    try {
      final fields = details.toApiData();

      http.StreamedResponse response;
      if (details.webImage != null) {
        // Web flow
        Map<String, Uint8List> files = {
          'photo': details.webImage!,
        };
        response = await ApiService.postMultipartFromBytes(
          'moderator/accounts/${details.id}/update',
          fields,
          files: files,
          fileNames: {'photo': details.imageName ?? 'profile.jpg'},
        );
      } else if (details.profileImage != null) {
        // Mobile flow
        Map<String, File> files = {
          'photo': details.profileImage!,
        };
        response = await ApiService.postMultipart(
          'moderator/accounts/${details.id}/update',
          fields,
          files: files,
        );
      } else {
        // No new image, but still use postMultipart with forceMultipart: true
        // to ensure Laravel method spoofing (_method: PUT) works correctly.
        response = await ApiService.postMultipart(
          'moderator/accounts/${details.id}/update',
          fields,
          forceMultipart: true,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Failed to save changes', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
