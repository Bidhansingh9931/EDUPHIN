
class ReviewSubmission {
  final String fullName;
  final String designation;
  final String message;

  ReviewSubmission({
    required this.fullName,
    required this.designation,
    required this.message,
  });

  // This method will be useful for converting your data to JSON for the API call.
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'designation': designation,
      'message': message,
    };
  }
}
