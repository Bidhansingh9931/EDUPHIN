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
}
