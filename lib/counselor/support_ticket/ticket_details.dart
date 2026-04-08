import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
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
    final theme = Theme.of(context);
    final isClosed = _currentStatus == 'closed';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket Conversation"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'open', child: Text("Open")),
              const PopupMenuItem(value: 'in_progress', child: Text("In Progress")),
              const PopupMenuItem(value: 'resolved', child: Text("Resolved")),
              const PopupMenuItem(value: 'closed', child: Text("Closed")),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text(_currentStatus.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTicketInfo(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _replies.length,
                    itemBuilder: (context, index) {
                      final reply = _replies[index];
                      return _buildReplyBubble(reply);
                    },
                  ),
          ),
          if (!isClosed) _buildReplyInput() else Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: const Center(child: Text("This ticket is closed and cannot be replied to.")),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.ticket.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(widget.ticket.description ?? "No description", style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(reply.userName ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(reply.createdAt?.split('T')[0] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(reply.message),
          if (reply.attachment != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {}, // View attachment logic
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network("${ApiService.baseImageUrl}/${reply.attachment}", height: 100, fit: BoxFit.cover),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          IconButton(onPressed: _pickAttachment, icon: Icon(Icons.attach_file, color: _attachment != null ? Colors.green : null)),
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(hintText: "Type your message...", border: InputBorder.none),
            ),
          ),
          _isSending
              ? const CircularProgressIndicator()
              : IconButton(onPressed: _sendReply, icon: const Icon(Icons.send, color: Colors.blue)),
        ],
      ),
    );
  }
}
