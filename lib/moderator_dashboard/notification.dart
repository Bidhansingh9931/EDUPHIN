import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Message>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _fetchMessages();
  }

  Future<List<Message>> _fetchMessages() async {
    // Simulate network delay to mimic fetching data from an API
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this data would be fetched from a server
    return [
      Message(
        name: "Liam Johnson",
        title: "Inquiry about school admissions",
        preview: "Hello, I would like to inquire about the a...",
        time: "10:45 AM",
      ),
      Message(
        name: "Sophia Martinez",
        title: "Feedback on recent parent-teacher me...",
        preview: "I wanted to provide some feedback reg...",
        time: "Yesterday",
      ),
      Message(
        name: "Noah Brown",
        title: "Question about the sports event",
        preview: "Could you please provide the schedule ...",
        time: "3 days ago",
      ),
      Message(
        name: "Emma Wilson",
        title: "Regarding bus transportation fee",
        preview: "I have a query regarding the new fee st...",
        time: "12/05/2024",
      ),
      Message(
        name: "Olivia Garcia",
        title: "Suggestion for the annual day",
        preview: "I have a few suggestions for the upcomi...",
        time: "10/05/2024",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Top Bar ----------------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- Messages List ----------------
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final messageList = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        return MessageCard(messageList[index]);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No messages found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------------- Message Model ----------------
//
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
}

//
// ---------------- Message Card Widget ----------------
//
class MessageCard extends StatelessWidget {
  final Message msg;

  const MessageCard(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------- First row: icon + name + time -----------
          Row(
            children: [
              // Profile Initial
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue,
                child: Text(
                  msg.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),

              const SizedBox(width: 14),

              // Name & Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time
              Text(
                msg.time,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------- Preview Text -----------
          Text(
            msg.preview,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
