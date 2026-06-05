class Employee {
  final String id;
  final String name;
  final String role;
  final String? email; // Added email field
  final String? instituteId;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.instituteId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    String roleName = 'Unassigned';
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      roleName = json['roles'][0]['name'] ?? 'Unassigned';
    }

    return Employee(
      id: (json['encrypted_id'] ?? json['id']).toString(),
      name: json['name'] ?? 'N/A',
      role: roleName,
      email: json['email'], // Extract email from JSON
      instituteId: json['institute_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'institute_id': instituteId,
    };
  }
}
