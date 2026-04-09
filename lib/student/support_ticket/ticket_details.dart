import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_details_models.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:intl/intl.dart';

class StudentTicketDetailsPage extends StatefulWidget {
  final String ticketId;

  const StudentTicketDetailsPage({super.key, required this.ticketId});

  @override
  State<StudentTicketDetailsPage> createState() => _StudentTicketDetailsPageState();
}

class _StudentTicketDetailsPageState extends State<StudentTicketDetailsPage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

  late Future<TicketDetails> _detailsFuture;
  final TextEditingController _replyController = TextEditingController();
  File? _selectedFile;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _refreshDetails();
  }

  void _refreshDetails() {
    setState(() {
      _detailsFuture = ApiService.getStudentTicketDetails(widget.ticketId);
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ApiService.addStudentTicketReply(
        widget.ticketId,
        _replyController.text.trim(),
        attachment: _selectedFile,
      );
      _replyController.clear();
      setState(() {
        _selectedFile = null;
        _isSending = false;
      });
      _refreshDetails();
    } catch (e) {
      setState(() => _isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reply: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ticket Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
            onPressed: _refreshDetails,
          ),
        ],
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primary));
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _refreshDetails, child: const Text("RETRY"))
              ],
            ));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
          }

          final details = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildTicketInfo(details.ticket),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Conversation (${details.replies.length})",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...details.replies.map((reply) => _buildReplyBubble(reply)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (details.ticket.status.toLowerCase() != 'closed') _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfo(SupportTicket ticket) {
    final dynamic ticketData = ticket;
    final priorityColor = _getPriorityColor(ticket.priority);
    final statusColor = _getStatusColor(ticket.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ID: #${ticket.id}",
                style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                _formatFullDate(ticket.createdAt),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            (ticketData.description as String?) ?? "No description provided.",
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white12, height: 1),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _infoChip(Icons.priority_high, "Priority", ticket.priority.toUpperCase(), priorityColor),
              _infoChip(Icons.category_outlined, "Category", ticket.category ?? "General", _primary),
              _infoChip(Icons.info_outline, "Status", ticket.status.toUpperCase(), statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    bool isSupport = reply.userRole?.toLowerCase() != 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isSupport ? _surface : _primary,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomLeft: isSupport ? const Radius.circular(0) : const Radius.circular(12),
            bottomRight: isSupport ? const Radius.circular(12) : const Radius.circular(0),
          ),
          border: isSupport ? Border.all(color: Colors.white10) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reply.userName ?? "User",
                  style: TextStyle(
                    color: isSupport ? _primary.withValues(alpha: 0.8) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(reply.createdAt),
                  style: TextStyle(
                    color: isSupport ? Colors.white38 : Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reply.message,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            if (reply.attachment != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  // Handle attachment download/view
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Attachment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white30,
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
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: _card,
        border: const Border(top: BorderSide(color: Colors.white12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        children: [
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _selectedFile = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                onPressed: _pickFile,
                tooltip: "Attach file",
              ),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Write a reply...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: _secondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? SizedBox(width: 48, height: 48, child: Padding(padding: const EdgeInsets.all(12), child: CircularProgressIndicator(color: _primary, strokeWidth: 3)))
                  : Container(
                      decoration: BoxDecoration(color: _primary, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _sendReply,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.redAccent;
      case 'medium': return Colors.orangeAccent;
      default: return Colors.greenAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return _primary;
      case 'closed': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatFullDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
