class Employee {
  final String id;
  final String name;
  final String role;

  Employee({required this.id, required this.name, required this.role});

  factory Employee.fromJson(Map<String, dynamic> json) {
    String roleName = 'Unassigned';
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      roleName = json['roles'][0]['name'] ?? 'Unassigned';
    }

    return Employee(
      id: (json['encrypted_id'] ?? json['id']).toString(),
      name: json['name'] ?? 'N/A',
      role: roleName,
    );
  }
}
