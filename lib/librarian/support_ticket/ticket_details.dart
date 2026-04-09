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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Ticket #${widget.ticketId}")),
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
                          _buildTicketHeader(ticket, theme),
                          const SizedBox(height: 24),
                          Text("Conversation", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...replies.map((reply) => _buildReplyCard(reply, theme)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildReplyInput(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketHeader(SupportTicket ticket, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(ticket.priority, isPriority: true),
                _buildBadge(ticket.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(ticket.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ticket.description ?? "No description provided", style: theme.textTheme.bodyMedium),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Category: ${ticket.category ?? 'N/A'}", style: theme.textTheme.bodySmall),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    ticket.createdAt.isNotEmpty
                        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(ticket.createdAt))
                        : "N/A",
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(TicketReply reply, ThemeData theme) {
    final bool isMe = reply.userRole == "Librarian";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.dividerColor),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reply.userName ?? "Unknown", style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(width: 8),
                Text(
                    reply.createdAt.isNotEmpty
                        ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(reply.createdAt))
                        : "N/A",
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(reply.message, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 12),
            _isSubmitting
                ? const CircularProgressIndicator()
                : IconButton.filled(
                    onPressed: _submitReply,
                    icon: const Icon(Icons.send),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, {bool isPriority = false}) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
