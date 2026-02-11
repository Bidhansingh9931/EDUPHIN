class Message {
  final String name;
  final String title;
  final String preview;
  final String time;

  Message({
    required this.name,
    required this.title,
    required this.preview,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      name: json['sender_name'] ?? 'Unknown Sender',
      title: json['title'] ?? 'No Title',
      preview: json['preview'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
