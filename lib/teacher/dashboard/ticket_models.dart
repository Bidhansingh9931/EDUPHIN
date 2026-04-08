class SupportTicket {
  final int id;
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

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      title: json['title'] ?? 'N/A',
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      category: json['category'],
      userId: json['created_by'] ?? json['user_id'],
      user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
      assignedTo: (json['assigned_to'] is Map ? json['assigned_to']['name'] : null) ?? 'Unassigned',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TicketUser {
  final int id;
  final String name;
  final String? email;

  TicketUser({required this.id, required this.name, this.email});

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: json['id'],
      name: json['name'] ?? 'N/A',
      email: json['email'],
    );
  }
}
