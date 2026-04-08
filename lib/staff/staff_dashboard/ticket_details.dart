import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../teacher/dashboard/ticket_details_models.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color bgColor = Color(0xFF0F1630);
  static const Color cardColor = Color(0xFF1D2645);

  late Future<TicketDetails> _detailsFuture;
  final TextEditingController _replyController = TextEditingController();
  bool _isSending = false;
  File? _attachment;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = ApiService.getStaffTicketDetails(widget.ticketId);
    });
  }

  Future<void> _pickAttachment() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _attachment = File(pickedFile.path));
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ApiService.replyStaffTicket(
        widget.ticketId,
        {'message': _replyController.text.trim()},
        attachment: _attachment,
      );
      _replyController.clear();
      setState(() => _attachment = null);
      _loadDetails();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ApiService.updateStaffTicketStatus(widget.ticketId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${newStatus.replaceAll('_', ' ')}')));
        _loadDetails();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showStatusDialog(String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text("Update Ticket Status", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption("open", currentStatus),
            _buildStatusOption("in_progress", currentStatus),
            _buildStatusOption("resolved", currentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status, String currentStatus) {
    final bool isSelected = status == currentStatus;
    return ListTile(
      title: Text(status.toUpperCase().replaceAll('_', ' '), style: TextStyle(color: isSelected ? primaryColor : Colors.white70)),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) _updateStatus(status);
      },
      trailing: isSelected ? const Icon(Icons.check, color: primaryColor) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ticket #${widget.ticketId} - Details",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white38)));
          }

          final details = snapshot.data!;
          final ticket = details.ticket;
          final replies = details.replies;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildTag("BACK", Colors.white10, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    _buildTag(
                      ticket.status.toUpperCase().replaceAll('_', ' '),
                      (ticket.status.toLowerCase() == 'resolved' ? Colors.green : (ticket.status.toLowerCase() == 'in_progress' ? Colors.orange : Colors.grey)).withValues(alpha: 0.1),
                      onTap: () => _showStatusDialog(ticket.status.toLowerCase()),
                    ),
                    const SizedBox(width: 8),
                    _buildTag(ticket.priority.toUpperCase(), (ticket.priority.toLowerCase() == 'high' ? Colors.red : Colors.blue).withValues(alpha: 0.1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: replies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                              const SizedBox(height: 24),
                              const Text(
                                "No replies yet.",
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: replies.length,
                          itemBuilder: (context, index) {
                            final reply = replies[index];
                            final isMe = reply.userName == "You" || (ticket.user != null && reply.userName == ticket.user!.name);
                            return _buildReplyBubble(reply, isMe);
                          },
                        ),
                ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reply.userName ?? 'Unknown', style: TextStyle(color: isMe ? primaryColor : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(reply.message, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Text(reply.createdAt, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            if (reply.attachment != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {}, // Open attachment
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 14, color: primaryColor),
                    SizedBox(width: 4),
                    Text("View Attachment", style: TextStyle(color: primaryColor, fontSize: 12, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: cardColor,
      child: Column(
        children: [
          if (_attachment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_attachment!.path.split('/').last, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.redAccent), onPressed: () => setState(() => _attachment = null)),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white70), onPressed: _pickAttachment),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _replyController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Type your reply here...",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: primaryColor),
                      onPressed: _sendReply,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
