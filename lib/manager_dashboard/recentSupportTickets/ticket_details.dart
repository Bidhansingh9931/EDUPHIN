import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Ticket Details", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: context.scale(48), color: context.theme.colorScheme.error),
            SizedBox(height: context.sm),
            Text(_error!, textAlign: TextAlign.center, style: context.theme.textTheme.titleMedium),
            SizedBox(height: context.md),
            ElevatedButton.icon(
              onPressed: _fetchTicketDetails,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ]),
        ),
      );
    }
    if (_ticketDetails == null) {
      return Center(
        child: Text("No details available.", style: context.theme.textTheme.titleMedium),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: context.pagePadding.copyWith(bottom: 100),
            itemCount: _sessionMessages.length + 1, // +1 for the header card
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: context.md),
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
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.spacing,
        context.sm,
        context.spacing,
        context.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "Type your reply...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: context.font(14),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(24)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(24)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(24)),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.md,
                  vertical: context.sm,
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(width: context.sm),
          Material(
            color: theme.colorScheme.primary,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: theme.colorScheme.onPrimary,
                size: context.scale(20),
              ),
              onPressed: _isSavingMessage ? null : _sendMessage,
            ),
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

  Color _getPriorityColor(TicketPriority priority, ColorScheme colorScheme) {
    switch (priority) {
      case TicketPriority.high:
        return colorScheme.error;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.low:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: context.lg,
              runSpacing: context.md,
              children: [
                _buildDetailColumn(context, "Requester", ticket.name),
                _buildDetailColumn(context, "Category", ticket.category),
                _buildDetailColumn(context, "Ticket ID", ticket.ticketId),
                _buildStatusColumn(context, ticket.status),
                _buildPriorityStatus(context, ticket.priority),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: context.md),
              child: Divider(color: colorScheme.outlineVariant, thickness: 0.5),
            ),
            Text(
              "Conversation Log",
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(BuildContext context, String title, String value) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: context.xs),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusColumn(BuildContext context, TicketStatus status) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "STATUS",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: context.xs),
        Text(
          status.displayName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityStatus(BuildContext context, TicketPriority priority) {
    final colorScheme = context.theme.colorScheme;
    final priorityColor = _getPriorityColor(priority, colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "PRIORITY",
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: context.font(11),
          ),
        ),
        SizedBox(height: context.xs),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.xs),
            border: Border.all(color: priorityColor.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Text(
            priority.displayName.toUpperCase(),
            style: context.theme.textTheme.labelSmall?.copyWith(
              color: priorityColor,
              fontWeight: FontWeight.bold,
              fontSize: context.font(10),
            ),
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
    final theme = context.theme;
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.md,
          vertical: context.sm,
        ),
        margin: EdgeInsets.only(
          top: context.xs,
          bottom: context.xs,
          left: isUser ? context.xl : 0,
          right: isUser ? 0 : context.xl,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.scale(12)),
            topRight: Radius.circular(context.scale(12)),
            bottomLeft: Radius.circular(isUser ? context.scale(12) : 0),
            bottomRight: Radius.circular(isUser ? 0 : context.scale(12)),
          ),
          border: Border.all(
            color: isUser 
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
