import 'package:eduphin/services/api_service.dart';

class ReviewDetail {
  final String name;
  final String designation;
  final String reviewText;
  final String? imageUrl;

  ReviewDetail({
    required this.name,
    required this.designation,
    required this.reviewText,
    this.imageUrl,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      name: json['name'] ?? 'Anonymous',
      designation: json['designation'] ?? 'N/A',
      reviewText: json['message'] ?? '',
      imageUrl: json['image'] != null ? ApiService.getStorageUrl(json['image']) : null,
    );
  }
}
