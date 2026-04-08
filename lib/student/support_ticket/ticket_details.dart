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
  final Color bgColor = const Color(0xFF0B1026);
  final Color cardColor = const Color(0xFF2F3757);
  final Color fieldColor = const Color(0xFF4A5568);
  final Color buttonBlue = const Color(0xFF3F5BD9);

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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ticket Details", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<TicketDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
          }

          final details = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTicketInfo(details.ticket),
                    const SizedBox(height: 24),
                    const Text(
                      "Conversation",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...details.replies.map((reply) => _buildReplyBubble(reply)),
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
    // Note: If SupportTicket model is missing 'description', access it dynamically from json if possible
    // or update the model. For now, using dynamic access for description if it might be missing from the model class definition.
    final dynamic ticketData = ticket; 
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ID: #${ticket.id}", style: const TextStyle(color: Colors.white70)),
              _buildBadge(ticket.status, _getStatusColor(ticket.status)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            (ticketData.description as String?) ?? "No description",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            children: [
              _infoItem("Priority", ticket.priority.toUpperCase()),
              const SizedBox(width: 20),
              _infoItem("Category", ticket.category ?? "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    bool isSupport = reply.userRole?.toLowerCase() != 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isSupport ? fieldColor : buttonBlue,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomLeft: isSupport ? const Radius.circular(0) : const Radius.circular(12),
            bottomRight: isSupport ? const Radius.circular(12) : const Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reply.userName ?? "User",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(reply.createdAt),
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(reply.message, style: const TextStyle(color: Colors.white)),
            if (reply.attachment != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Handle attachment download/view
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("Attachment", style: TextStyle(color: Colors.white, fontSize: 12)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                onPressed: _pickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const CircularProgressIndicator()
                  : CircleAvatar(
                      backgroundColor: buttonBlue,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendReply,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blueAccent;
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
}
