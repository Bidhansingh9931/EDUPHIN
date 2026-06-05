import 'package:eduphin/services/error_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'profile_model.dart';
import 'cache_helper.dart';

class ProfileProvider {
  static const String _cacheKey = 'profile_data';

  Future<ProfileData?> getCachedProfileData() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null) {
      return ProfileData.fromMap(cached);
    }
    return null;
  }

  Future<ProfileData> fetchProfileData({bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await getCachedProfileData();
        if (cached != null) return cached;
      }
      final response = await ApiService.get('moderator/profile');

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

          // Save to cache
          await CacheHelper.save(_cacheKey, combinedData);

          return ProfileData.fromMap(combinedData);
        } else {
          throw ApiException("Received invalid data from server.");
        }
      } else {
        throw ApiException("Failed to load profile data", statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      debugPrint("An error occurred fetching profile: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> saveProfileData(Map<String, String> fields, {File? photo, Uint8List? webImage, String? fileName}) async {
    try {
      if (photo != null || webImage != null) {
        if (webImage != null) {
          await ApiService.updateModeratorProfileFromBytes(fields, webImage, fileName);
        } else {
          await ApiService.updateModeratorProfile(fields, photo: photo);
        }
      } else {
        final response = await ApiService.post('moderator/profile/update', fields);
        if (response.statusCode != 200) {
          String errorMessage = "Failed to save profile.";
          try {
            final responseBody = jsonDecode(response.body);
            if (response.statusCode == 422 && responseBody['errors'] != null) {
              final errors = responseBody['errors'] as Map<String, dynamic>;
              final errorDetails = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n');
              errorMessage = '${responseBody['message']}\n$errorDetails';
            } else {
              errorMessage = responseBody['message'] ?? errorMessage;
            }
          } catch (_) {}
          throw ApiException(errorMessage, statusCode: response.statusCode);
        }
      }
      // Invalidate cache on success so the next fetch gets fresh data
      await CacheHelper.clear(_cacheKey);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      debugPrint("An error occurred saving profile: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> downloadProfileData() async {
    try {
      // Permission.storage is removed for Play Store compliance.
      // On modern Android, the app may not need this for internal storage 
      // or can use the Photo Picker for media.

      final profileData = await fetchProfileData();
      const jsonEncoder = JsonEncoder.withIndent('  ');
      final jsonData = jsonEncoder.convert(profileData.toMap());

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not get downloads directory.");
      }

      final filePath = '${directory.path}/profile_data.json';
      final file = File(filePath);
      await file.writeAsString(jsonData);

      return filePath;
    } catch (e) {
      debugPrint("An error occurred during download: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    await CacheHelper.clearAll();
  }
}
