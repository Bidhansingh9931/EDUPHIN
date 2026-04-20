
import 'package:eduphin/teacher/dashboard/ticket_models.dart';

class TicketDetails {
  final SupportTicket ticket;
  final List<TicketReply> replies;

  TicketDetails({required this.ticket, required this.replies});

  Map<String, dynamic> toJson() {
    return {
      'ticket': ticket.toJson(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory TicketDetails.fromJson(Map<String, dynamic> json) {
    return TicketDetails(
      ticket: SupportTicket.fromJson(json['ticket'] ?? {}),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((r) => TicketReply.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TicketReply {
  final int id;
  final int userId;
  final String message;
  final String? attachment;
  final String createdAt;
  final String? userName;
  final String? userRole;

  TicketReply({
    required this.id,
    required this.userId,
    required this.message,
    this.attachment,
    required this.createdAt,
    this.userName,
    this.userRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'attachment': attachment,
      'created_at': createdAt,
      'user': {
        'name': userName,
        'role': userRole,
      },
    };
  }

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return TicketReply(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      userName: user['name']?.toString(),
      userRole: user['role'] is Map ? user['role']['name']?.toString() : user['role']?.toString(),
    );
  }
}
