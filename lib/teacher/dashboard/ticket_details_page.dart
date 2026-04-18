import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
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
        title: Text("Ticket Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Padding(
              padding: EdgeInsets.all(context.scale(24.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: context.scale(48), color: context.theme.colorScheme.error),
                  SizedBox(height: context.scale(16)),
                  Text("Error loading ticket details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                  Text("${snapshot.error}", textAlign: TextAlign.center, style: TextStyle(fontSize: context.font(12))),
                  SizedBox(height: context.scale(24)),
                  ElevatedButton(onPressed: _loadDetails, child: const Text("Retry")),
                ],
              ),
            ));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details found"));
          }

          final data = snapshot.data!;
          final ticket = data.ticket;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  _buildHeader(ticket),
                  Expanded(
                    child: data.replies.isEmpty 
                      ? _buildEmptyConversation() 
                      : ListView.builder(
                          padding: EdgeInsets.all(context.scale(16)),
                          itemCount: data.replies.length,
                          itemBuilder: (context, index) => _buildReplyBubble(data.replies[index]),
                        ),
                  ),
                  _buildReplySection(ticket.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SupportTicket ticket) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusBadge(ticket.status ?? 'open'),
              SizedBox(width: context.scale(8)),
              _priorityBadge(ticket.priority),
            ],
          ),
          SizedBox(height: context.scale(16)),
          Text(
            ticket.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.font(18),
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (ticket.description != null) ...[
            SizedBox(height: context.scale(8)),
            Text(
              ticket.description!,
              style: TextStyle(
                fontSize: context.font(14),
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final theme = context.theme;
    Color color = theme.colorScheme.primary;
    if (status.toLowerCase() == 'closed') color = theme.colorScheme.outline;
    if (status.toLowerCase() == 'resolved') color = const Color(0xFF10B981);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          fontSize: context.font(10),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    final theme = context.theme;
    Color color = theme.colorScheme.outline;
    if (priority.toLowerCase() == 'high') color = theme.colorScheme.error;
    else if (priority.toLowerCase() == 'medium') color = const Color(0xFFF59E0B);
    else if (priority.toLowerCase() == 'low') color = Colors.blue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: context.font(10),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyConversation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: context.scale(64), color: context.theme.hintColor.withValues(alpha: 0.2)),
          SizedBox(height: context.scale(16)),
          Text("No replies yet. Start the conversation!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    final theme = context.theme;
    final isMe = reply.userRole?.toLowerCase() == 'teacher' || reply.userName?.toLowerCase() == 'you';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.scale(16),
          left: isMe ? context.scale(64) : 0,
          right: isMe ? 0 : context.scale(64),
        ),
        padding: EdgeInsets.all(context.scale(16)),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.scale(20)),
            topRight: Radius.circular(context.scale(20)),
            bottomLeft: Radius.circular(isMe ? context.scale(20) : 0),
            bottomRight: Radius.circular(isMe ? 0 : context.scale(20)),
          ),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(reply.userName ?? "User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: theme.colorScheme.primary)),
              SizedBox(height: context.scale(4)),
            ],
            Text(
              reply.message,
              style: TextStyle(
                fontSize: context.font(14),
                color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            if (reply.attachment != null) ...[
              SizedBox(height: context.scale(12)),
              InkWell(
                onTap: () {}, // Open attachment logic
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, size: context.scale(14), color: theme.colorScheme.primary),
                      SizedBox(width: context.scale(8)),
                      Flexible(
                        child: Text(
                          "View Attachment",
                          style: TextStyle(
                            fontSize: context.font(12),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
            SizedBox(height: context.scale(8)),
            Text(
              reply.createdAt,
              style: TextStyle(
                fontSize: context.font(10),
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplySection(String status) {
    final theme = context.theme;
    if (status.toLowerCase() == 'closed') {
      return Container(
        padding: EdgeInsets.all(context.scale(20)),
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        child: Text("This ticket is closed. No more replies allowed.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: context.font(14),
              color: theme.colorScheme.onSurfaceVariant,
            )),
      );
    }

    return Container(
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
              ),
              padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: "Type your reply...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant),
                ),
                style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurface),
                maxLines: null,
              ),
            ),
            SizedBox(height: context.scale(12)),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(context.scale(12)),
              child: Container(
                padding: EdgeInsets.all(context.scale(12)),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: context.scale(20), color: theme.colorScheme.primary),
                    SizedBox(width: context.scale(12)),
                    Expanded(
                      child: Text(
                        _selectedFile == null ? "Attach file" : _selectedFile!.path.split('/').last,
                        style: TextStyle(fontSize: context.font(13), color: _selectedFile != null ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.scale(16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, context.scale(52)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  elevation: 0,
                ),
                child: _isSending
                    ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                    : Text("SEND REPLY", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
