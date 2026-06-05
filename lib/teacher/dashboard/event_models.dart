import 'package:eduphin/manager_dashboard/events/event_model.dart';

class RegisteredEvent {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final Event event;

  RegisteredEvent({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.event,
  });

  factory RegisteredEvent.fromJson(Map<String, dynamic> json) {
    return RegisteredEvent(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? 'N/A',
      event: Event.fromJson(json['event'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status,
      'event': event.toJson(),
    };
  }
}
