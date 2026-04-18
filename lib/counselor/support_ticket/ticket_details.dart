import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import '../counselor_models.dart';

class TicketDetailsPage extends StatefulWidget {
  final SupportTicket ticket;
  const TicketDetailsPage({super.key, required this.ticket});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  bool _isLoading = true;
  List<TicketReply> _replies = [];
  final TextEditingController _replyController = TextEditingController();
  File? _attachment;
  bool _isSending = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket.status ?? 'open';
    _fetchReplies();
  }

  Future<void> _fetchReplies() async {
    try {
      final response = await ApiService.get('counselor/tickets/${widget.ticket.id}/replies');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List repliesData = data['data'] ?? [];
          _replies = repliesData.map((e) => TicketReply.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final response = await ApiService.patch('counselor/tickets/${widget.ticket.id}/status', {
        'status': newStatus.toLowerCase(),
      });
      if (response.statusCode == 200) {
        setState(() => _currentStatus = newStatus.toLowerCase());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status updated to $newStatus")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update status")));
    }
  }

  Future<void> _pickAttachment() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _attachment = File(picked.path));
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final fields = {'message': _replyController.text};
      final files = _attachment != null ? {'attachment': _attachment!} : null;

      final response = await ApiService.postMultipart(
        'counselor/tickets/${widget.ticket.id}/replies',
        fields,
        files: files,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _replyController.clear();
        setState(() => _attachment = null);
        _fetchReplies();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending reply")));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isClosed = _currentStatus == 'closed';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Ticket Conversation", style: TextStyle(fontSize: context.font(20))),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'open', child: Text("Open")),
              const PopupMenuItem(value: 'in_progress', child: Text("In Progress")),
              const PopupMenuItem(value: 'resolved', child: Text("Resolved")),
              const PopupMenuItem(value: 'closed', child: Text("Closed")),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.scale(4)),
                  ),
                  child: Text(
                    _currentStatus.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(12),
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildTicketInfo(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: context.pagePadding,
                        itemCount: _replies.length,
                        itemBuilder: (context, index) {
                          final reply = _replies[index];
                          return _buildReplyBubble(reply);
                        },
                      ),
              ),
              if (!isClosed)
                _buildReplyInput()
              else
                Container(
                  padding: EdgeInsets.all(context.spacing),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  width: double.infinity,
                  child: const Center(child: Text("This ticket is closed and cannot be replied to.")),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
    final colorScheme = context.theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.ticket.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(18))),
          SizedBox(height: context.scale(8)),
          Text(widget.ticket.description ?? "No description",
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14))),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    final colorScheme = context.theme.colorScheme;
    final isUser = reply.userName != null; // Ideally check against current user ID

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing),
      padding: EdgeInsets.all(context.scale(12)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(reply.userName ?? "User",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: colorScheme.primary)),
              Text(reply.createdAt?.split('T')[0] ?? "",
                  style: TextStyle(fontSize: context.font(10), color: colorScheme.onSurfaceVariant)),
            ],
          ),
          SizedBox(height: context.scale(8)),
          Text(reply.message, style: TextStyle(fontSize: context.font(14))),
          if (reply.attachment != null) ...[
            SizedBox(height: context.scale(8)),
            InkWell(
              onTap: () {}, // View attachment logic
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.scale(8)),
                child: Image.network(
                  "${ApiService.baseImageUrl}/${reply.attachment}",
                  height: context.scale(150),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: context.scale(100),
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.scale(8)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _pickAttachment,
              icon: Icon(Icons.attach_file, color: _attachment != null ? colorScheme.primary : colorScheme.onSurfaceVariant),
            ),
            Expanded(
              child: TextField(
                controller: _replyController,
                style: TextStyle(fontSize: context.font(14)),
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12)),
                ),
              ),
            ),
            _isSending
                ? SizedBox(
                    width: context.scale(24),
                    height: context.scale(24),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _sendReply,
                    icon: Icon(Icons.send, color: colorScheme.primary),
                  ),
          ],
        ),
      ),
    );
  }
}
