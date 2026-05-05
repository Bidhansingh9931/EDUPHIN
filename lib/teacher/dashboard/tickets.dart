import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart';
import 'teacher_cache_service.dart';

class TicketPage extends StatefulWidget {
  final int ticketId;
  const TicketPage({super.key, required this.ticketId});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  TicketDetails? _cachedDetails;
  bool _isLoading = true;
  File? _attachment;
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isSending = false;

  final TextEditingController _replyController = TextEditingController();

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
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _refreshTicketDetails() {
    _fetchDetails();
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply message cannot be empty.')));
      return;
    }

    setState(() => _isSending = true);
    try {
      await ApiService.addTicketReply(widget.ticketId, _replyController.text,
          attachment: _attachment, fileBytes: _fileBytes, fileName: _fileName);
      _replyController.clear();
      setState(() {
        _attachment = null;
        _fileBytes = null;
        _fileName = null;
      });
      _refreshTicketDetails(); // Refresh details
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Reply sent successfully!'),
            backgroundColor: Color(0xFF10B981)));
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Ticket Details", style: TextStyle(fontSize: context.font(20))),
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _cachedDetails != null,
        skeleton: _buildSkeleton(context),
        child: _cachedDetails == null
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(context.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: context.scale(48), color: theme.colorScheme.error),
                      SizedBox(height: context.md),
                      Text('Error loading ticket details', textAlign: TextAlign.center, style: TextStyle(fontSize: context.font(14))),
                      SizedBox(height: context.md),
                      ElevatedButton(onPressed: _refreshTicketDetails, child: const Text("Retry")),
                    ],
                  ),
                ),
              )
            : _buildContent(context, _cachedDetails!),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        // Header Skeleton
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.spacing),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: context.theme.dividerColor, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TeacherSkeleton(height: 24, width: 250),
              SizedBox(height: context.md),
              const Row(
                children: [
                  TeacherSkeleton(height: 24, width: 80),
                  SizedBox(width: 8),
                  TeacherSkeleton(height: 24, width: 80),
                ],
              ),
            ],
          ),
        ),
        // Replies Skeleton
        Expanded(
          child: ListView.builder(
            padding: context.pagePadding,
            itemCount: 5,
            itemBuilder: (context, index) {
              final isMe = index % 2 == 0;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: context.md),
                  padding: EdgeInsets.all(context.md),
                  constraints: BoxConstraints(maxWidth: context.screenWidth * (context.isTablet ? 0.6 : 0.8)),
                  decoration: BoxDecoration(
                    color: isMe ? context.theme.colorScheme.primaryContainer.withValues(alpha: 0.1) : context.theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.scale(16)),
                      topRight: Radius.circular(context.scale(16)),
                      bottomLeft: Radius.circular(isMe ? context.scale(16) : 0),
                      bottomRight: Radius.circular(isMe ? 0 : context.scale(16)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        const TeacherSkeleton(height: 12, width: 60),
                        SizedBox(height: context.xs),
                      ],
                      const TeacherSkeleton(height: 14, width: double.infinity),
                      const SizedBox(height: 4),
                      const TeacherSkeleton(height: 14, width: 150),
                      SizedBox(height: context.sm),
                      const TeacherSkeleton(height: 10, width: 80),
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
          child: const TeacherSkeleton(height: 60),
        ),
      ],
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
                    style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14))))
              : _buildRepliesList(context, details.replies),
        ),
        _buildReplySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, SupportTicket ticket) {
    final theme = context.theme;
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.spacing),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
            SizedBox(height: context.md),
            Wrap(spacing: context.sm, runSpacing: context.sm, children: [
              _buildStatusChip(context, ticket.status),
              _buildPriorityChip(context, ticket.priority),
            ]),
          ],
        ));
  }

  Widget _buildRepliesList(BuildContext context, List<TicketReply> replies) {
    final theme = context.theme;
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
            margin: EdgeInsets.only(bottom: context.md),
            padding: EdgeInsets.all(context.md),
            constraints: BoxConstraints(
                maxWidth: context.screenWidth * (context.isTablet ? 0.6 : 0.8)),
            decoration: BoxDecoration(
              color: isMe
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.scale(16)),
                topRight: Radius.circular(context.scale(16)),
                bottomLeft: Radius.circular(isMe ? context.scale(16) : 0),
                bottomRight: Radius.circular(isMe ? 0 : context.scale(16)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    reply.userName ?? 'User',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)),
                  ),
                if (!isMe) SizedBox(height: context.xs),
                Text(reply.message, style: TextStyle(fontSize: context.font(14))),
                if (reply.attachment != null)
                  Padding(
                    padding: EdgeInsets.only(top: context.sm),
                    child: InkWell(
                      onTap: () { /* Handle attachment tap */ },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attachment, size: context.scale(16), color: theme.colorScheme.primary),
                          SizedBox(width: context.xs),
                          Text("View Attachment", style: TextStyle(fontSize: context.font(12), decoration: TextDecoration.underline))
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: context.sm),
                Text(
                  DateFormat.yMMMd().add_jm().format(DateTime.parse(reply.createdAt)),
                  style: TextStyle(fontSize: context.font(10), color: theme.hintColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplySection(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachment != null || _fileBytes != null)
              Container(
                margin: EdgeInsets.only(bottom: context.sm),
                padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.scale(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, size: context.scale(18)),
                    SizedBox(width: context.sm),
                    Expanded(child: Text(_fileName ?? _attachment?.path.split('/').last ?? "File selected", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: context.font(13)))),
                    IconButton(onPressed: () => setState(() {
                      _attachment = null;
                      _fileBytes = null;
                      _fileName = null;
                    }), icon: Icon(Icons.close, size: context.scale(18))),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      if (kIsWeb) {
                        setState(() {
                          _fileBytes = result.files.single.bytes;
                          _fileName = result.files.single.name;
                        });
                      } else {
                        setState(() {
                          _attachment = File(result.files.single.path!);
                          _fileName = result.files.single.name;
                        });
                      }
                    }
                  },
                  icon: Icon(Icons.add_circle_outline, size: context.scale(24)),
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: 4,
                    minLines: 1,
                    style: TextStyle(fontSize: context.font(14)),
                    decoration: const InputDecoration(
                      hintText: "Type your reply...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending 
                    ? SizedBox(width: context.scale(24), height: context.scale(24), child: const CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.send_rounded, size: context.scale(24)),
                  color: theme.colorScheme.primary,
                  onPressed: _isSending ? null : _addReply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        color = const Color(0xFF3B82F6); // Standard Blue for info/open
        break;
      case 'in_progress':
        color = const Color(0xFFF59E0B); // Amber
        break;
      case 'resolved':
      case 'closed':
        color = const Color(0xFF10B981); // Emerald
        break;
      default:
        color = context.theme.colorScheme.outline;
    }
    return Chip(
      label: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = const Color(0xFFEF4444); // Red
        break;
      case 'medium':
        color = const Color(0xFFF59E0B); // Amber
        break;
      case 'low':
      default:
        color = const Color(0xFF3B82F6); // Blue for low priority
    }
    return Chip(
      label: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
    );
  }
}
