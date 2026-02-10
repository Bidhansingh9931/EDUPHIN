import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- ENUMS (Consistent with ticket_info.dart) ---

enum TicketStatus {
  open,
  inProgress,
  onHold,
  resolved,
  closed;

  String get displayName => toBeginningOfSentenceCase(name.replaceAll('InProgress', 'In Progress'))!;
}

enum TicketPriority {
  low,
  medium,
  high;

  String get displayName => toBeginningOfSentenceCase(name)!;
}

extension on String {
  TicketPriority toTicketPriority() {
    return TicketPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }

  TicketStatus toTicketStatus() {
    final formattedString = toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    return TicketStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == formattedString.toLowerCase(),
      orElse: () => TicketStatus.open,
    );
  }
}

// --- DATA MODELS (Made Robust) ---

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return ChatMessage(
      text: json['message']?.toString() ?? '', // Safe parsing
      isUser: (json['user_id'] ?? -1) == currentUserId, // Safe comparison
    );
  }
}

class TicketDetails {
  final String name;
  final String category;
  final String ticketId;
  final TicketPriority priority;
  final TicketStatus status;
  final List<ChatMessage> messages;

  TicketDetails({
    required this.name,
    required this.category,
    required this.ticketId,
    required this.priority,
    required this.status,
    required this.messages,
  });

  factory TicketDetails.fromJson(Map<String, dynamic> json, int currentUserId) {
    final ticketData = json['ticket'] is Map<String, dynamic> ? json['ticket'] : {};
    final repliesData = json['replies'] as List? ?? [];

    final messages = repliesData
        .whereType<Map<String, dynamic>>()
        .map((reply) => ChatMessage.fromJson(reply, currentUserId))
        .toList();

    final userData = ticketData['user'] is Map<String, dynamic> ? ticketData['user'] : {};
    final categoryData = ticketData['category'] is Map<String, dynamic> ? ticketData['category'] : {};

    return TicketDetails(
      name: userData['name']?.toString() ?? 'Unknown User',
      category: categoryData['name']?.toString() ?? 'Uncategorized',
      ticketId: ticketData['serial']?.toString() ?? 'N/A',
      priority: (ticketData['priority']?.toString() ?? 'medium').toTicketPriority(),
      status: (ticketData['status']?.toString() ?? 'open').toTicketStatus(),
      messages: messages,
    );
  }
}

// --- MAIN WIDGET ---

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<StatefulWidget> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String? _error;
  TicketDetails? _ticketDetails;
  final List<ChatMessage> _sessionMessages = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Pre-flight check for a valid ticket ID
      if (widget.ticketId == 'N/A' || widget.ticketId.isEmpty) {
        throw Exception('Invalid Ticket ID provided.');
      }
      
      final results = await Future.wait([
        ApiService.get('manager/tickets/${widget.ticketId}/replies'),
        ApiService.get('manager/profile'),
      ]);

      if (!mounted) return;

      final repliesResponse = results[0];
      final profileResponse = results[1];

      if (repliesResponse.statusCode != 200) {
        throw Exception('Failed to load ticket details: ${repliesResponse.body}');
      }
      if (profileResponse.statusCode != 200) {
        throw Exception('Failed to load user profile: ${profileResponse.body}');
      }

      final repliesData = jsonDecode(repliesResponse.body);
      final profileData = jsonDecode(profileResponse.body);

      final dynamic userIdDynamic = profileData['data']?['id'];
      final currentUserId = int.tryParse(userIdDynamic.toString()) ?? 0;

      if (currentUserId == 0) {
        throw Exception('Could not determine the current user ID.');
      }

      final details = TicketDetails.fromJson(repliesData, currentUserId);

      setState(() {
        _currentUserId = currentUserId;
        _ticketDetails = details;
        _sessionMessages.clear();
        _sessionMessages.addAll(details.messages);
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isSavingMessage) return;

    final userMessage = ChatMessage(text: _controller.text, isUser: true);

    setState(() {
      _isSavingMessage = true;
      _sessionMessages.add(userMessage);
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await ApiService.post('manager/tickets/${widget.ticketId}/reply', {
        'message': userMessage.text,
      });

      if (!mounted) return;

      if (response.statusCode != 201) {
        throw Exception('Failed to send message.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sessionMessages.remove(userMessage);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMessage = false;
        });
      }
    }
  }

  bool _isSavingMessage = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ticket Details"),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _fetchTicketDetails, child: const Text("Retry")),
        ]),
      );
    }
    if (_ticketDetails == null) {
      return const Center(child: Text("No details available."));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            itemCount: _sessionMessages.length + 1, // +1 for the header card
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomTicketDetailsBox(
                    ticket: _ticketDetails!,
                  ),
                );
              }
              final message = _sessionMessages[index - 1];
              return ChatBubble(message: message);
            },
          ),
        ),
        _buildInputArea(theme),
      ],
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
            icon: Icon(Icons.send, color: _isSavingMessage ? Colors.grey : theme.colorScheme.primary),
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

  Color _getPriorityColor(TicketPriority priority, ThemeData theme) {
    switch (priority) {
      case TicketPriority.high:
        return theme.colorScheme.error;
      case TicketPriority.medium:
        return Colors.amber.shade700;
      case TicketPriority.low:
        return Colors.lightBlueAccent;
    }
  }

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
          Wrap(
            spacing: 16.0, 
            runSpacing: 16.0, 
            children: [
              _buildDetailColumn(theme, "Name", ticket.name),
              _buildDetailColumn(theme, "Category", ticket.category),
              _buildDetailColumn(theme, "Ticket ID", ticket.ticketId),
              _buildDetailColumn(theme, "Status", ticket.status.displayName, valueColor: theme.colorScheme.secondary),
              _buildPriorityStatus(theme, ticket.priority),
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
        Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
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

  Widget _buildPriorityStatus(ThemeData theme, TicketPriority priority) {
    final priorityColor = _getPriorityColor(priority, theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Priority",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(180))),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withAlpha(55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            priority.displayName,
            style: theme.textTheme.labelMedium?.copyWith(color: priorityColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

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
