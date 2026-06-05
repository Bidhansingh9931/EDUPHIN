class SupportTicket {
  final int id;
  final String? encryptedId;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String? category;
  final int? userId; // The ID of the creator
  final TicketUser? user; // The user object of the creator
  final String? assignedTo; // Name of the assigned person
  final String createdAt;

  SupportTicket({
    required this.id,
    this.encryptedId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.category,
    this.userId,
    this.user,
    this.assignedTo,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'encrypted_id': encryptedId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'category': category,
      'user_id': userId,
      'user': user?.toJson(),
      'assigned_to': assignedTo,
      'created_at': createdAt,
    };
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      encryptedId: json['encrypted_id']?.toString(),
      title: json['title']?.toString() ?? 'N/A',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      category: json['category']?.toString(),
      userId: int.tryParse(json['created_by']?.toString() ?? json['user_id']?.toString() ?? '') ?? 0,
      user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
      assignedTo: (json['assigned_to'] is Map ? json['assigned_to']['name']?.toString() : json['assigned_to']?.toString()) ?? 'Unassigned',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class TicketUser {
  final int id;
  final String name;
  final String? email;

  TicketUser({required this.id, required this.name, this.email});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'N/A',
      email: json['email']?.toString(),
    );
  }
}
