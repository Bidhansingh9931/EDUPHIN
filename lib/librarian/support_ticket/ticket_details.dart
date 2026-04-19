import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../teacher/dashboard/ticket_details_models.dart';
import '../../teacher/dashboard/ticket_models.dart';
import '../../services/responsive_helper.dart';
import 'package:intl/intl.dart';

class LibrarianTicketDetailsPage extends StatefulWidget {
  final int ticketId;
  const LibrarianTicketDetailsPage({super.key, required this.ticketId});

  @override
  State<LibrarianTicketDetailsPage> createState() => _LibrarianTicketDetailsPageState();
}

class _LibrarianTicketDetailsPageState extends State<LibrarianTicketDetailsPage> {
  late Future<TicketDetails> _detailsFuture;
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = ApiService.getLibrarianTicketDetails(widget.ticketId.toString());
    });
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ApiService.replyLibrarianTicket(widget.ticketId.toString(), {'message': _replyController.text.trim()});
      _replyController.clear();
      _loadDetails();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reply sent successfully")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ticket #${widget.ticketId}"),
        centerTitle: false,
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details found"));
          }

          final ticket = snapshot.data!.ticket;
          final replies = snapshot.data!.replies;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTicketHeader(context, ticket, theme),
                          SizedBox(height: context.md),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.xs),
                            child: Text(
                              "Conversation",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(height: context.sm),
                          ...replies.map((reply) => _buildReplyCard(context, reply, theme)),
                          SizedBox(height: context.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildReplyInput(context, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketHeader(BuildContext context, SupportTicket ticket, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBadge(context, ticket.priority, isPriority: true),
                SizedBox(width: context.xs),
                _buildBadge(context, ticket.status),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: context.scale(14), color: colorScheme.onSurfaceVariant),
                SizedBox(width: context.xs),
                Text(
                  ticket.createdAt.isNotEmpty ? DateFormat('MMM dd, yyyy').format(DateTime.parse(ticket.createdAt)) : "N/A",
                  style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: context.md),
            Text(
              ticket.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              ticket.description ?? "No description provided",
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            Divider(height: context.lg, color: colorScheme.outlineVariant),
            Row(
              children: [
                Icon(Icons.category_outlined, size: context.scale(16), color: colorScheme.primary),
                SizedBox(width: context.xs),
                Text(
                  "Category: ${ticket.category ?? 'N/A'}",
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(BuildContext context, TicketReply reply, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final bool isMe = reply.userRole == "Librarian";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: context.xs),
        padding: EdgeInsets.all(context.md),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primaryContainer.withValues(alpha: 0.2) : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.scale(16)),
            topRight: Radius.circular(context.scale(16)),
            bottomLeft: Radius.circular(isMe ? context.scale(16) : context.scale(4)),
            bottomRight: Radius.circular(isMe ? context.scale(4) : context.scale(16)),
          ),
          border: Border.all(color: isMe ? colorScheme.primary.withValues(alpha: 0.2) : colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reply.userName ?? "Unknown",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMe ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: context.sm),
                Text(
                  reply.createdAt.isNotEmpty ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(reply.createdAt)) : "N/A",
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: context.xs),
            Text(
              reply.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                style: TextStyle(fontSize: context.font(14)),
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.scale(20)),
                    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.scale(20)),
                    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.scale(20)),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
                ),
                maxLines: 5,
                minLines: 1,
              ),
            ),
            SizedBox(width: context.sm),
            _isSubmitting
                ? SizedBox(
                    height: context.scale(24),
                    width: context.scale(24),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton.filled(
                    onPressed: _submitReply,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.all(context.sm),
                    ),
                    icon: const Icon(Icons.send),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, {bool isPriority = false}) {
    Color color = Colors.grey;
    String lowerText = text.toLowerCase();
    if (isPriority) {
      if (lowerText == 'high') {
        color = Colors.red;
      } else if (lowerText == 'medium') {
        color = Colors.orange;
      } else if (lowerText == 'low') {
        color = Colors.green;
      }
    } else {
      if (lowerText == 'closed') {
        color = Colors.red;
      } else if (lowerText == 'pending') {
        color = Colors.orange;
      } else if (lowerText == 'open') {
        color = Colors.green;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.xl),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: context.font(10),
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
