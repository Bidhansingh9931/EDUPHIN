import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:file_picker/file_picker.dart';
import 'common_widgets.dart';
import 'teacher_cache_service.dart';

class TicketDetailsPage extends StatefulWidget {
  final int ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  TicketDetails? _cachedDetails;
  bool _isLoading = true;
  final TextEditingController _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await TeacherCacheService.load('ticket_details_${widget.ticketId}');
    if (cachedData != null && mounted) {
      setState(() {
        _cachedDetails = TicketDetails.fromJson(cachedData);
        _isLoading = false;
      });
    }
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_cachedDetails == null) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getTicketDetails(widget.ticketId);
      if (mounted) {
        setState(() {
          _cachedDetails = data;
          _isLoading = false;
        });
        await TeacherCacheService.save('ticket_details_${widget.ticketId}', data.toJson());
      }
    } catch (e) {
      debugPrint("Error fetching ticket details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ApiService.addTicketReply(
        widget.ticketId, 
        _replyController.text,
      );
      _replyController.clear();
      _fetchDetails();
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
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _cachedDetails != null,
        skeleton: _buildSkeleton(context),
        child: _cachedDetails == null
            ? const Center(child: Text("No details found"))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      _buildHeader(_cachedDetails!.ticket),
                      Expanded(
                        child: _cachedDetails!.replies.isEmpty 
                          ? _buildEmptyConversation() 
                          : ListView.builder(
                              padding: EdgeInsets.all(context.scale(16)),
                              itemCount: _cachedDetails!.replies.length,
                              itemBuilder: (context, index) => _buildReplyBubble(_cachedDetails!.replies[index]),
                            ),
                      ),
                      _buildReplySection(_cachedDetails!.ticket.status),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            // Header Skeleton
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.spacing),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                border: Border(bottom: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      TeacherSkeleton(width: 80, height: 24),
                      SizedBox(width: 8),
                      TeacherSkeleton(width: 80, height: 24),
                    ],
                  ),
                  SizedBox(height: context.scale(16)),
                  const TeacherSkeleton(height: 24, width: 300),
                  SizedBox(height: context.scale(8)),
                  const TeacherSkeleton(height: 16, width: double.infinity),
                  const SizedBox(height: 4),
                  const TeacherSkeleton(height: 16, width: 250),
                ],
              ),
            ),
            // Replies Skeleton
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(context.scale(16)),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final isMe = index % 2 == 0;
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
                        color: isMe 
                            ? context.theme.colorScheme.primaryContainer.withValues(alpha: 0.1) 
                            : context.theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(context.scale(20)),
                          topRight: Radius.circular(context.scale(20)),
                          bottomLeft: Radius.circular(isMe ? context.scale(20) : 0),
                          bottomRight: Radius.circular(isMe ? 0 : context.scale(20)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            const TeacherSkeleton(height: 12, width: 80),
                            SizedBox(height: context.scale(4)),
                          ],
                          TeacherSkeleton(height: 14, width: isMe ? 150 : 200),
                          const SizedBox(height: 4),
                          TeacherSkeleton(height: 14, width: isMe ? 100 : 150),
                          SizedBox(height: context.scale(8)),
                          const TeacherSkeleton(height: 10, width: 60),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input Section Skeleton
            Container(
              padding: EdgeInsets.all(context.spacing),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                border: Border(top: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
              ),
              child: Column(
                children: [
                  const TeacherSkeleton(height: 48),
                  SizedBox(height: context.scale(16)),
                  const TeacherSkeleton(height: 52),
                ],
              ),
            ),
          ],
        ),
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
