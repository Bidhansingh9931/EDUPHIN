
import 'package:eduphin/teacher/dashboard/ticket_models.dart';

class TicketDetails {
  final SupportTicket ticket;
  final List<TicketReply> replies;

  TicketDetails({required this.ticket, required this.replies});

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

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return TicketReply(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      attachment: json['attachment'],
      createdAt: json['created_at'] ?? '',
      userName: user['name'],
      userRole: user['role']?['name'],
    );
  }
}
