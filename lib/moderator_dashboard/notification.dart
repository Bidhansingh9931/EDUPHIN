import 'package:flutter/material.dart';

import 'notification_model.dart';
import 'notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Message>> _messagesFuture;
  final NotificationProvider _provider = NotificationProvider();

  @override
  void initState() {
    super.initState();
    _messagesFuture = _provider.fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseFontSize) {
      // Adjust font size based on screen width
      if (screenWidth > 600) {
        return baseFontSize * 1.2; // Larger screens
      } else if (screenWidth < 360) {
        return baseFontSize * 0.9; // Smaller screens
      }
      return baseFontSize;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Top Bar ----------------
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFontSize(22),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04), // Responsive padding
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
// ---------------- Message Card Widget ----------------
//
class MessageCard extends StatelessWidget {
  final Message msg;

  const MessageCard(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveFontSize(double baseFontSize) {
      if (screenWidth > 600) {
        return baseFontSize * 1.2;
      } else if (screenWidth < 360) {
        return baseFontSize * 0.9;
      }
      return baseFontSize;
    }

    return Container(
      margin: EdgeInsets.only(
          bottom: screenWidth * 0.04), // Responsive margin
      padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
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
                radius: screenWidth * 0.06, // Responsive radius
                backgroundColor: Colors.blue,
                child: Text(
                  msg.name.isNotEmpty ? msg.name[0].toUpperCase() : '',
                  style: TextStyle(
                      color: Colors.white, fontSize: responsiveFontSize(20)),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: responsiveFontSize(13),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time
              Text(
                msg.time,
                style: TextStyle(
                    color: Colors.white54, fontSize: responsiveFontSize(12)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------- Preview Text -----------
          Text(
            msg.preview,
            style: TextStyle(
              color: Colors.white54,
              fontSize: responsiveFontSize(13),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}