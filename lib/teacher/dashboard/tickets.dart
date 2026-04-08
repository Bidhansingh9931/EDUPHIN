import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class TicketPage extends StatefulWidget {
  final int ticketId;
  const TicketPage({super.key, required this.ticketId});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late Future<TicketDetails> _detailsFuture;
  File? _attachment;

  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detailsFuture = ApiService.getTicketDetails(widget.ticketId);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _refreshTicketDetails() {
    setState(() {
      _detailsFuture = ApiService.getTicketDetails(widget.ticketId);
    });
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply message cannot be empty.')));
      return;
    }

    try {
      await ApiService.addTicketReply(widget.ticketId, _replyController.text,
          attachment: _attachment);
      _replyController.clear();
      setState(() {
        _attachment = null;
      });
      _refreshTicketDetails(); // Refresh details
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Reply sent successfully!'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to send reply: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _refreshTicketDetails, child: const Text("Retry")),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Ticket not found."));
          } else {
            return _buildContent(context, snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TicketDetails details) {
    return Column(
      children: [
        _buildHeader(context, details.ticket),
        Expanded(
          child: details.replies.isEmpty
              ? Center(
                  child: Text("No replies yet. Start the conversation!", 
                    style: TextStyle(color: Theme.of(context).hintColor)))
              : _buildRepliesList(context, details.replies),
        ),
        _buildReplySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, SupportTicket ticket) {
    final theme = Theme.of(context);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _buildStatusChip(context, ticket.status),
              _buildPriorityChip(context, ticket.priority),
            ]),
          ],
        ));
  }

  Widget _buildRepliesList(BuildContext context, List<TicketReply> replies) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: replies.length,
      itemBuilder: (context, index) {
        final reply = replies[index];
        // Note: Replace with actual current user logic if available
        final isMe = reply.userName?.toLowerCase() == 'you' || index % 2 == 0; 

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
                maxWidth: context.screenWidth * (context.isTablet ? 0.6 : 0.8)),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    reply.userName ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                if (!isMe) const SizedBox(height: 4),
                Text(reply.message),
                if (reply.attachment != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () { /* Handle attachment tap */ },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attachment, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          const Text("View Attachment", style: TextStyle(fontSize: 12, decoration: TextDecoration.underline))
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  DateFormat.yMMMd().add_jm().format(DateTime.parse(reply.createdAt)),
                  style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplySection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachment != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_attachment!.path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(onPressed: () => setState(() => _attachment = null), icon: const Icon(Icons.close, size: 18)),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() => _attachment = File(result.files.single.path!));
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: "Type your reply...",
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: theme.colorScheme.primary,
                  onPressed: _addReply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    Color color;
    switch (status.toLowerCase()) {
      case 'open': color = Colors.blue; break;
      case 'in_progress': color = Colors.orange; break;
      case 'resolved':
      case 'closed': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Chip(
        label: Text(status.replaceAll('_', ' ').toUpperCase(), 
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.red; break;
      case 'medium': color = Colors.amber; break;
      case 'low':
      default: color = Colors.grey;
    }
    return Chip(
        label: Text(priority.toUpperCase(), 
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
