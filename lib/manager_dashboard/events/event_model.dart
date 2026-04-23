import 'dart:io';

class Event {
  final String title;
  final String description;
  final String venue;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final bool isTicketed;
  final String? ticketPrice;
  final String? maxParticipants;
  final List<String> audience;
  final File? image;

  Event({
    required this.title,
    required this.description,
    required this.venue,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.isTicketed,
    this.ticketPrice,
    this.maxParticipants,
    required this.audience,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      venue: json['venue'] ?? '',
      eventDate: DateTime.parse(json['event_date'] ?? '1970-01-01'),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isTicketed: json['is_ticketed'] == 1,
      ticketPrice: json['ticket_price'],
      maxParticipants: json['max_participants']?.toString(),
      audience: List<String>.from(json['audience'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'event_date': eventDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'is_ticketed': isTicketed ? 1 : 0,
      'ticket_price': ticketPrice,
      'max_participants': maxParticipants,
      'audience': audience,
    };
  }
}
