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
    List<ChatMessage> messages =
        messagesList.map((i) => ChatMessage.fromJson(i as Map<String, dynamic>)).toList();

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
  const TicketDetailsPage({super.key});

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

  Future<void> _fetchTicketDetails() async {
    await Future.delayed(const Duration(seconds: 1));

    final dummyData = {
      "name": "Ananya Sharma",
      "category": "IT Support",
      "ticketId": "#001245",
      "priority": "High",
      "status": "In Progress",
      "messages": [
        {"text": "Hello, I'm having trouble with the Wi-Fi in the library.", "isUser": true},
        {
          "text": "Hi Ananya, we are looking into the issue. Can you provide more details?",
          "isUser": false
        },
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
    if (message.contains("hello") || message.contains("hi")) {
      return "Hi! How can I help you?";
    } else if (message.contains("flutter")) {
      return "Flutter is awesome for app development!";
    } else if (message.contains("bye")) {
      return "Goodbye! Have a great day 😊";
    } else if (message.contains("how are you")) {
      return "I'm fine, thank you!";
    } else if (message.contains("what can you do") ||
        message.contains("how can you help me")) {
      return "I can help you by answering questions and providing support.";
    } else if (message.contains("thank you")) {
      return "I am here to help. If you have any more questions, feel free to ask!";
    } else if (message.contains("your name")) {
      return "I am a chatBot created by Bidhan Kumar Singh";
    } else {
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
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
                        itemCount: _sessionMessages.length + 1, // +1 for the header card
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // The first item is the details box
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CustomTicketDetailsBox(
                                ticket: _ticketDetails!,
                              ),
                            );
                          }
                          // Subsequent items are chat messages
                          final message = _sessionMessages[index - 1];
                          return ChatBubble(message: message);
                        },
                      ),
                    ),
                    _buildInputArea(theme),
                  ],
                ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask something...",
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: theme.colorScheme.primary),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

class CustomTicketDetailsBox extends StatelessWidget {
  final TicketDetails ticket;

  const CustomTicketDetailsBox({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.primaryColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using a Wrap widget for responsive details
          Wrap(
            spacing: 16.0, // Horizontal space between items
            runSpacing: 16.0, // Vertical space between lines
            children: [
              _buildDetailColumn(theme, "Name", ticket.name),
              _buildDetailColumn(theme, "Category", ticket.category),
              _buildDetailColumn(theme, "Ticket ID", ticket.ticketId),
              _buildDetailColumn(theme, "Status", ticket.status, valueColor: theme.colorScheme.secondary),
              _buildPriorityStatus(theme, ticket.priority, ticket.priority == "High"),
            ],
          ),
          const Divider(height: 32, thickness: 1),
          Text(
            "Conversation",
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(ThemeData theme, String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
              color: valueColor ?? theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPriorityStatus(ThemeData theme, String priority, bool isHigh) {
    final priorityColor = isHigh ? theme.colorScheme.error : theme.colorScheme.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Priority",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withAlpha(35),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            priority,
            style: theme.textTheme.labelMedium?.copyWith(color: priorityColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// New, reusable widget for displaying chat messages
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          // Using theme colors for a consistent look
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
