import 'all_review_model.dart';

class AllReviewProvider {
  Future<List<ReviewDetail>> fetchAllReviews() async {
    // Simulate a network call to fetch data.
    // Replace this with your actual API call when it's ready.
    await Future.delayed(const Duration(seconds: 2));

    // Mock data for demonstration purposes.
    return [
      ReviewDetail(
        name: 'Jane Doe',
        designation: 'Parent, Grade 8',
        reviewText: 'This is a sample review. The school is great and the teachers are very supportive.',
        avatarAsset: 'assets/images/women_image.png',
      ),
      ReviewDetail(
        name: 'John Smith',
        designation: 'Parent, Grade 10',
        reviewText: 'Excellent platform, very easy to use and navigate. Highly recommended!',
        avatarAsset: 'assets/images/men_image.png',
      ),
       ReviewDetail(
        name: 'Jane Doe',
        designation: 'Parent, Grade 8',
        reviewText: 'This is a sample review. The school is great and the teachers are very supportive.',
        avatarAsset: 'assets/images/women_image.png',
      ),
      ReviewDetail(
        name: 'John Smith',
        designation: 'Parent, Grade 10',
        reviewText: 'Excellent platform, very easy to use and navigate. Highly recommended!',
        avatarAsset: 'assets/images/men_image.png',
      ),
       ReviewDetail(
        name: 'Jane Doe',
        designation: 'Parent, Grade 8',
        reviewText: 'This is a sample review. The school is great and the teachers are very supportive.',
        avatarAsset: 'assets/images/women_image.png',
      ),
      ReviewDetail(
        name: 'John Smith',
        designation: 'Parent, Grade 10',
        reviewText: 'Excellent platform, very easy to use and navigate. Highly recommended!',
        avatarAsset: 'assets/images/men_image.png',
      ),
    ];
  }
}
