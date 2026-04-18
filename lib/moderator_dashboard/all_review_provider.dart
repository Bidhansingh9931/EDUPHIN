import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'all_review_model.dart';

class AllReviewProvider {
  Future<List<ReviewDetail>> fetchAllReviews() async {
    final response = await ApiService.get('moderator/dashboard');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return (data['testimonials'] as List? ?? []).map((json) => ReviewDetail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
