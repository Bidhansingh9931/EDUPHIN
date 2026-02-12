class Section {
  final int id;
  final String name;
  final String mentor;
  final int limit;

  const Section({
    required this.id,
    required this.name,
    required this.mentor,
    required this.limit,
  });

  // Factory to create a Section from API data
  factory Section.fromJson(Map<String, dynamic> json) {
    String mentorName = 'Not Assigned';
    if (json['mentor'] is Map<String, dynamic>) {
      mentorName = json['mentor']?['name'] ?? 'Not Assigned';
    } else if (json['mentor'] is String) {
      mentorName = json['mentor'];
    }

    return Section(
      id: json['id'] ?? 0,
      name: json['section_name'] ?? 'Unnamed Section',
      mentor: mentorName,
      limit: json['section_limit'] ?? 0,
    );
  }
}