import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'cache_helper.dart';
import 'all_review_model.dart';

class AllReviewProvider {
  static const String _cacheKey = 'all_reviews';

  Future<List<ReviewDetail>?> getCachedReviews() async {
    final cached = await CacheHelper.load(_cacheKey);
    if (cached != null) {
      return (cached as List).map((json) => ReviewDetail.fromJson(json)).toList();
    }
    return null;
  }

  Future<List<ReviewDetail>> fetchAllReviews({bool bypassCache = false}) async {
    try {
      final response = await ApiService.get('moderator/dashboard');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final reviewsJson = data['testimonials'] as List? ?? [];
        
        await CacheHelper.save(_cacheKey, reviewsJson);

        return reviewsJson.map((json) => ReviewDetail.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load reviews', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

