import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:file_picker/file_picker.dart';
import 'common_widgets.dart';

class TicketDetailsPage extends StatefulWidget {
  final int ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late Future<TicketDetails> _detailsFuture;
  final TextEditingController _replyController = TextEditingController();
  File? _selectedFile;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = ApiService.getTicketDetails(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ApiService.addTicketReply(
        widget.ticketId, 
        _replyController.text, 
        attachment: _selectedFile
      );
      _replyController.clear();
      setState(() => _selectedFile = null);
      _loadDetails();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket Details"),
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
            ));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details found"));
          }

          final data = snapshot.data!;
          final ticket = data.ticket;

          return Column(
            children: [
              _buildHeader(ticket),
              Expanded(
                child: data.replies.isEmpty 
                  ? _buildEmptyConversation() 
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.replies.length,
                      itemBuilder: (context, index) => _buildReplyBubble(data.replies[index]),
                    ),
              ),
              _buildReplySection(ticket.status),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(SupportTicket ticket) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusBadge(ticket.status),
              const SizedBox(width: 8),
              _priorityBadge(ticket.priority),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description ?? 'No description provided.', 
            style: TextStyle(fontSize: 13, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _priorityBadge(String priority) {
    Color color = priority.toLowerCase() == 'high' ? Colors.red : priority.toLowerCase() == 'medium' ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildEmptyConversation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Theme.of(context).hintColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("No replies yet. Start the conversation!", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 48),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reply.message),
            if (reply.attachment != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {}, // Open attachment logic
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "View Attachment", 
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplySection(String status) {
    if (status.toLowerCase() == 'closed') {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        color: Colors.grey.withOpacity(0.1),
        child: const Text("This ticket is closed. No more replies allowed.", textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(hintText: "Type your reply...", border: InputBorder.none),
              maxLines: null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFile == null ? "Attach file" : _selectedFile!.path.split('/').last, 
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendReply,
                child: _isSending ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("SEND REPLY"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
