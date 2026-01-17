import 'package:flutter/material.dart';

// --- DATA MODELS ---

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
    );
  }
}

class TicketDetails {
  final String name;
  final String category;
  final String ticketId;
  final String priority;
  final String status;
  final List<ChatMessage> messages;

  TicketDetails({
    required this.name,
    required this.category,
    required this.ticketId,
    required this.priority,
    required this.status,
    required this.messages,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<ChatMessage> messages = messagesList.map((i) => ChatMessage.fromJson(i as Map<String, dynamic>)).toList();

    return TicketDetails(
      name: json['name'] as String,
      category: json['category'] as String,
      ticketId: json['ticketId'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      messages: messages,
    );
  }
}

// --- MAIN WIDGET ---

class TicketDetailsPage extends StatefulWidget {
  // TODO: In a real app, you would pass the ticket ID to this page
  // final String ticketId;
  const TicketDetailsPage({super.key /*, required this.ticketId */});

  @override
  State<StatefulWidget> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  TicketDetails? _ticketDetails;
  final List<ChatMessage> _sessionMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  // TODO: Replace this with your actual API call using widget.ticketId
  Future<void> _fetchTicketDetails() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy data for demonstration
    final dummyData = {
      "name": "Ananya Sharma",
      "category": "IT Support",
      "ticketId": "#001245",
      "priority": "High",
      "status": "In Progress",
      "messages": [
        {"text": "Hello, I'm having trouble with the Wi-Fi in the library.", "isUser": true},
        {"text": "Hi Ananya, we are looking into the issue. Can you provide more details?", "isUser": false},
      ]
    };

    if (mounted) {
      final details = TicketDetails.fromJson(dummyData);
      setState(() {
        _ticketDetails = details;
        _sessionMessages.addAll(details.messages);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String userMessageText = _controller.text;
    final userMessage = ChatMessage(text: userMessageText, isUser: true);

    setState(() {
      _sessionMessages.add(userMessage);
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate bot reply
    Future.delayed(const Duration(seconds: 1), () {
      final botReply = ChatMessage(text: _getBotReply(userMessageText), isUser: false);
      setState(() {
        _sessionMessages.add(botReply);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getBotReply(String message) {
    message = message.toLowerCase();
    if (message.contains("hello")) {
      return "Hi! How can I help you?";
    } else if (message.contains("flutter")) {
      return "Flutter is awesome for app development!";
    } else if (message.contains("bye")) {
      return "Goodbye! Have a great day 😊";
    } else if (message.contains("hi")) {
      return "Hi! How May I Help You?";
    } else if (message.contains("how are you")) {
      return "I'm fine, thank you!";
    } else if (message.contains("what can you do")) {
      return "I can help you 😊";
    } else if (message.contains("how can you help me")) {
      return "I can help you by answering questions and providing support.";
    }else if (message.contains("thank you")) {
      return "I am here to help. If you have any more questions, feel free to ask!";
    }
    else if (message.contains("your name")) {
      return "I am a chatBot created by Bidhan Kumar Singh";
    }
    else {
      return "Sorry, I didn't understand that.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ticket Details"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticketDetails == null
          ? const Center(child: Text("Failed to load ticket details."))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: CustomTicketDetailsBox(
                ticket: _ticketDetails!,
                messages: _sessionMessages, // Pass the live session messages
              ),
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask something...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            )
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

class CustomTicketDetailsBox extends StatelessWidget {
  final TicketDetails ticket;
  final List<ChatMessage> messages;

  const CustomTicketDetailsBox({
    super.key,
    required this.ticket,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = ticket.priority == "High";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn(theme, "Name", ticket.name),
                _buildDetailColumn(theme, "Category", ticket.category),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn(theme, "Ticket ID", ticket.ticketId),
                _buildPriorityStatus(theme, ticket.priority, isHigh),
              ],
            ),
            const SizedBox(height: 5),
            _buildDetailColumn(theme, "Status", ticket.status, valueColor: Colors.blue),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.onPrimary.withAlpha(180), thickness: 1),
            const SizedBox(height: 8),
            ChatMessagesList(messages: messages),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(ThemeData theme, String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(150), fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor ?? theme.colorScheme.onPrimary, fontSize: 14)),
      ],
    );
  }

  Widget _buildPriorityStatus(ThemeData theme, String priority, bool isHigh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Priority", style: TextStyle(color: theme.colorScheme.onPrimary.withAlpha(150), fontSize: 14)),
        Container(
            decoration: BoxDecoration(
              color: isHigh ? Colors.red.withAlpha(100) : Colors.blue.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                priority,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )),
      ],
    );
  }
}

class ChatMessagesList extends StatelessWidget {
  final List<ChatMessage> messages;

  const ChatMessagesList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text("No messages yet. Start a conversation!", style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.isUser;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: isUser ? Colors.white : Colors.black),
            ),
          ),
        );
      },
    );
  }
}
