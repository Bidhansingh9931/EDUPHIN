import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  late Stream<TicketDetails> _detailsStream;
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
      _detailsStream = ApiService.getStaffTicketDetailsStream(widget.ticketId);
    });
  }

  Future<void> _pickAttachment() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _attachment = File(pickedFile.path));
    }
  }

  Future<void> _sendReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty && _attachment == null) return;

    setState(() => _isSending = true);
    try {
      await ApiService.replyStaffTicket(
        widget.ticketId,
        {'message': message},
        attachment: _attachment,
      );
      _replyController.clear();
      setState(() => _attachment = null);
      _loadDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ApiService.updateStaffTicketStatus(widget.ticketId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.replaceAll('_', ' ')}')),
        );
        _loadDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showStatusDialog(String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Ticket Status"),
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
    final theme = context.theme;
    return ListTile(
      title: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) _updateStatus(status);
      },
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Ticket #${widget.ticketId}"),
        centerTitle: true,
      ),
      body: StreamBuilder<TicketDetails>(
        stream: _detailsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<TicketDetails>(
            snapshot: snapshot,
            skeleton: _buildSkeleton(context),
            onRetry: _loadDetails,
            builder: (details) {
              final ticket = details.ticket;
              final replies = details.replies;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Padding(
                        padding: context.pagePadding,
                        child: Row(
                          children: [
                            _buildTag(
                              ticket.status.toUpperCase().replaceAll('_', ' '),
                              _getStatusColor(ticket.status),
                              onTap: () => _showStatusDialog(ticket.status.toLowerCase()),
                            ),
                            SizedBox(width: context.scale(12)),
                            _buildTag(
                              ticket.priority.toUpperCase(),
                              _getPriorityColor(ticket.priority),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: context.spacing),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: replies.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.forum_outlined, 
                                        size: context.scale(64), 
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                      SizedBox(height: context.scale(16)),
                                      Text("No replies yet.", 
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurfaceVariant, 
                                          fontWeight: FontWeight.bold, 
                                          fontSize: context.font(16)
                                        )),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(context.spacing),
                                  itemCount: replies.length,
                                  itemBuilder: (context, index) {
                                    final reply = replies[index];
                                    // Check if the reply's author is the user themselves (You) or matches the ticket's creator ID
                                    final isMe = reply.userName == "You" || (reply.userId != 0 && reply.userId == ticket.userId);
                                    return _buildReplyBubble(reply, isMe);
                                  },
                                ),
                        ),
                      ),
                      _buildInputArea(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scale(12)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scale(10)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.scale(12)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.font(12)),
              ),
              if (onTap != null) ...[
                SizedBox(width: context.scale(4)),
                Icon(Icons.edit_outlined, size: context.scale(14), color: color),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply, bool isMe) {
    final theme = context.theme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: context.scale(16)),
        padding: EdgeInsets.all(context.scale(16)),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(context.scale(20)).copyWith(
            bottomRight: isMe ? Radius.zero : Radius.circular(context.scale(20)),
            bottomLeft: isMe ? Radius.circular(context.scale(20)) : Radius.zero,
          ),
          border: Border.all(
            color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        constraints: BoxConstraints(maxWidth: context.responsive(context.screenWidth * 0.85, tablet: 600)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reply.userName ?? 'Unknown',
                  style: TextStyle(
                    color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(12),
                  ),
                ),
                if (reply.userRole != null) ...[
                  SizedBox(width: context.scale(4)),
                  Text(
                    "(${reply.userRole})",
                    style: TextStyle(
                      color: (isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant).withValues(alpha: 0.7),
                      fontSize: context.font(10),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: context.scale(6)),
            Text(
              reply.message,
              style: TextStyle(
                color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                fontSize: context.font(14),
                height: 1.4,
              ),
            ),
            SizedBox(height: context.scale(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: context.scale(10), color: (isMe ? theme.colorScheme.onPrimaryContainer : theme.hintColor).withValues(alpha: 0.6)),
                SizedBox(width: context.scale(4)),
                Text(
                  reply.createdAt,
                  style: TextStyle(
                    color: (isMe ? theme.colorScheme.onPrimaryContainer : theme.hintColor).withValues(alpha: 0.6),
                    fontSize: context.font(10)
                  ),
                ),
              ],
            ),
            if (reply.attachment != null) ...[
              SizedBox(height: context.scale(12)),
              InkWell(
                onTap: () {}, // Open attachment logic
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, size: context.scale(18), color: theme.colorScheme.primary),
                      SizedBox(width: context.scale(8)),
                      Text(
                        "View Attachment",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: context.font(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.spacing,
        context.scale(12),
        context.spacing,
        context.spacing + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachment != null)
            Container(
              margin: EdgeInsets.only(bottom: context.scale(12)),
              padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.image, size: context.scale(20), color: theme.colorScheme.primary),
                  SizedBox(width: context.scale(12)),
                  Expanded(
                    child: Text(
                      _attachment!.path.split('/').last,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(12), fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, size: context.scale(20), color: theme.colorScheme.error),
                    onPressed: () => setState(() => _attachment = null),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.primary,
                ),
                icon: Icon(Icons.add_photo_alternate_outlined, size: context.scale(24)),
                onPressed: _pickAttachment,
                tooltip: "Add Image",
              ),
              SizedBox(width: context.scale(8)),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: TextStyle(fontSize: context.font(14)),
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Type your reply here...",
                    contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
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
                  ),
                ),
              ),
              SizedBox(width: context.scale(8)),
              _isSending
                  ? Padding(
                      padding: EdgeInsets.all(context.scale(8)),
                      child: SizedBox(
                        width: context.scale(24),
                        height: context.scale(24),
                        child: const CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: _sendReply,
                      icon: Icon(Icons.send_rounded, size: context.scale(22)),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: context.pagePadding,
          child: Row(
            children: [
              Expanded(child: Skeleton(height: context.scale(40), borderRadius: context.scale(12))),
              SizedBox(width: context.scale(12)),
              Expanded(child: Skeleton(height: context.scale(40), borderRadius: context.scale(12))),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: context.spacing),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.scale(20)),
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(context.spacing),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isMe = index % 2 == 0;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: context.scale(16)),
                    padding: EdgeInsets.all(context.scale(16)),
                    width: context.screenWidth * 0.7,
                    decoration: BoxDecoration(
                      color: isMe ? context.theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : context.theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(context.scale(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: context.scale(80), height: context.scale(12)),
                        SizedBox(height: context.scale(8)),
                        Skeleton(width: double.infinity, height: context.scale(14)),
                        SizedBox(height: context.scale(4)),
                        Skeleton(width: context.screenWidth * 0.4, height: context.scale(14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(context.spacing),
          child: Row(
            children: [
              Skeleton(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
              SizedBox(width: context.scale(8)),
              Expanded(child: Skeleton(height: context.scale(48), borderRadius: context.scale(24))),
              SizedBox(width: context.scale(8)),
              Skeleton(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Semantic Red
      case 'medium':
        return const Color(0xFFF59E0B); // Semantic Amber
      case 'low':
        return const Color(0xFF10B981); // Semantic Emerald
      default:
        return const Color(0xFF3B82F6); // Semantic Blue
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF10B981); // Semantic Emerald
      case 'in_progress':
        return const Color(0xFFF59E0B); // Semantic Amber
      case 'open':
        return const Color(0xFF3B82F6); // Semantic Blue
      default:
        return Colors.grey;
    }
  }
}
