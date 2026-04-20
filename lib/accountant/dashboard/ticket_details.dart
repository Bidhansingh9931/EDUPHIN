import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  bool _isActionLoading = false;
  late Stream<TicketDetails> _detailsStream;
  final TextEditingController _replyController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    _detailsStream = ApiService.getTicketDetailsAccountantStream(widget.ticketId);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedFile = File(pickedFile.path));
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;
    
    // Validation for special characters to prevent backend decryption/parsing issues
    if (!RegExp(r'^[a-zA-Z0-9\s,.\-/#()]+$').hasMatch(_replyController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Special characters not allowed in reply")),
        );
      }
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await ApiService.replyAccountantTicket(
        widget.ticketId,
        {'message': _replyController.text},
        attachment: _selectedFile,
      );
      _replyController.clear();
      _selectedFile = null;
      setState(() => _updateStream());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isActionLoading = true);
    try {
      await ApiService.updateAccountantTicketStatus(widget.ticketId, status);
      setState(() => _updateStream());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<TicketDetails>(
          stream: _detailsStream,
          builder: (context, snapshot) => Text(snapshot.hasData ? "Ticket #${snapshot.data!.ticket.id}" : "Ticket Details"),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<TicketDetails>(
            stream: _detailsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.ticket.status != 'resolved' && snapshot.data!.ticket.status != 'closed') {
                return _buildStatusMenu(context);
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _updateStream())),
        ],
      ),
      body: StreamBuilder<TicketDetails>(
        stream: _detailsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<TicketDetails>(
            snapshot: snapshot,
            skeleton: _buildSkeleton(context),
            onRetry: () => setState(() => _updateStream()),
            builder: (details) => Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(context, details),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: context.scale(1000)),
                          child: ListView.builder(
                            padding: context.pagePadding,
                            itemCount: details.replies.length,
                            itemBuilder: (context, index) {
                              final reply = details.replies[index];
                              final isRightAligned = reply.userId == details.ticket.userId;
                              return _buildReplyBubble(context, reply, isRightAligned);
                            },
                          ),
                        ),
                      ),
                    ),
                    if (details.ticket.status != 'resolved' && details.ticket.status != 'closed')
                      _buildInputArea(context),
                  ],
                ),
                if (_isActionLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Skeleton(height: context.scale(100), width: double.infinity, borderRadius: 16),
        ),
        Expanded(
          child: ListView.builder(
            padding: context.pagePadding,
            itemCount: 5,
            itemBuilder: (context, index) {
              final isMe = index % 2 == 0;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.spacing),
                  child: Skeleton(
                    height: context.scale(80),
                    width: context.scale(250),
                    borderRadius: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: context.scale(64), color: theme.colorScheme.error),
            SizedBox(height: context.scale(16)),
            Text(
              "Failed to Load Ticket Details",
              style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              "The server returned an error (500). This often happens if the ticket ID is not correctly encrypted.",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              "ID Used: ${widget.ticketId}",
              style: TextStyle(fontFamily: 'monospace', fontSize: context.font(12), color: theme.colorScheme.primary),
            ),
            SizedBox(height: context.scale(24)),
            ElevatedButton.icon(
              onPressed: () => setState(() => _updateStream()),
              icon: const Icon(Icons.refresh),
              label: const Text("RETRY"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("GO BACK"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.edit_note),
      onSelected: _updateStatus,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'open', child: Text('Open')),
        const PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
        const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
        const PopupMenuItem(value: 'closed', child: Text('Closed')),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TicketDetails details) {
    final theme = context.theme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.scale(1000)),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(16)),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          margin: EdgeInsets.all(context.spacing),
          child: Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.ticket.title, 
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))
                ),
                SizedBox(height: context.scale(12)),
                Row(
                  children: [
                    _buildTag(context, details.ticket.status.toUpperCase(), _getStatusColor(details.ticket.status)),
                    SizedBox(width: context.scale(8)),
                    _buildTag(context, details.ticket.priority.toUpperCase(), _getPriorityColor(details.ticket.priority)),
                    const Spacer(),
                    if (details.ticket.status != 'resolved' && details.ticket.status != 'closed')
                      TextButton.icon(
                        onPressed: () => _updateStatus('resolved'),
                        icon: Icon(Icons.check_circle_outline, size: context.scale(16)),
                        label: Text(
                          "CLOSE TICKET", 
                          style: TextStyle(fontSize: context.font(10), fontWeight: FontWeight.bold)
                        ),
                        style: TextButton.styleFrom(foregroundColor: Colors.green),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBubble(BuildContext context, TicketReply reply, bool isMe) {
    final theme = context.theme;
    final displayName = reply.userName ?? 'User';
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: context.spacing),
        padding: EdgeInsets.all(context.scale(12)),
        constraints: BoxConstraints(maxWidth: context.scale(MediaQuery.of(context).size.width * 0.75)),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
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
            Text(displayName, style: TextStyle(color: theme.hintColor, fontSize: context.font(10), fontWeight: FontWeight.bold)),
            SizedBox(height: context.scale(4)),
            Text(reply.message, style: TextStyle(fontSize: context.font(13))),
            if (reply.attachment != null)
              Padding(
                padding: EdgeInsets.only(top: context.scale(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: context.scale(14), color: theme.colorScheme.primary),
                    SizedBox(width: context.scale(4)),
                    Text(
                      "Attachment", 
                      style: TextStyle(fontSize: context.font(11), decoration: TextDecoration.underline)
                    ),
                  ],
                ),
              ),
            SizedBox(height: context.scale(4)),
            Text(reply.createdAt, style: TextStyle(color: theme.hintColor, fontSize: context.font(9))),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5))
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(1000)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _replyController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: "Type reply..."),
                ),
                SizedBox(height: context.scale(12)),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickFile,
                        child: Container(
                          height: context.scale(48),
                          padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(context.scale(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: context.scale(18), color: theme.hintColor),
                              SizedBox(width: context.scale(8)),
                              Flexible(
                                child: Text(
                                  _selectedFile?.path.split('/').last ?? "Choose File",
                                  style: TextStyle(color: theme.hintColor, fontSize: context.font(12)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.scale(12)),
                    SizedBox( 
                      height: context.scale(48),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(context.scale(80), context.scale(48)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        onPressed: _isActionLoading ? null : _sendReply,
                        child: const Text("SEND"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(context.scale(6)), 
        border: Border.all(color: color.withValues(alpha: 0.5))
      ),
      child: Text(
        text, 
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.font(10))
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }
}
