import 'dart:io';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'add_review_model.dart';

class AddReviewProvider {
  Future<void> submitReview(ReviewSubmission submission) async {
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));

      // For now, we'll just print the data to the console.
      debugPrint('Submitting review: ${submission.toJson()}');

      // Example of throwing an error for testing (uncomment to test)
      // throw ApiException('Failed to submit review', statusCode: 500);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
