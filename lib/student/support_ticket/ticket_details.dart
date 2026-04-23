import 'dart:io';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  TicketDetails? _details;
  bool _isLoading = true;
  final TextEditingController _replyController = TextEditingController();
  File? _selectedFile;
  bool _isSending = false;

  String get _cacheKey => 'student_support_ticket_${widget.ticketId}';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchDetails();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _details = TicketDetails.fromJson(cachedData as Map<String, dynamic>);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDetails() async {
    if (_details == null) {
      setState(() => _isLoading = true);
    }
    try {
      final details = await ApiService.getStudentTicketDetails(widget.ticketId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
        await CacheService.saveData(_cacheKey, details.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (_details == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error fetching ticket details: $e"),
              backgroundColor: context.theme.colorScheme.error,
            ),
          );
        }
      }
    }
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
      _fetchDetails();
    } catch (e) {
      setState(() => _isSending = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send reply: $e"),
          backgroundColor: context.theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ticket Details",
          style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: context.scale(24), color: colorScheme.onSurface),
            onPressed: _fetchDetails,
          ),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _details != null,
        skeleton: const _TicketDetailsSkeleton(),
        onRefresh: _fetchDetails,
        child: _details == null
            ? const SizedBox.shrink()
            : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: context.pagePadding,
                          children: [
                            _buildTicketInfo(_details!.ticket),
                            SizedBox(height: context.xl),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: context.xs),
                              child: Row(
                                children: [
                                  Icon(Icons.forum_outlined, color: colorScheme.primary, size: context.scale(20)),
                                  SizedBox(width: context.sm),
                                  Text(
                                    "Conversation (${_details!.replies.length})",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.lg),
                            ..._details!.replies.map((reply) => _buildReplyBubble(reply)),
                            SizedBox(height: context.md),
                          ],
                        ),
                      ),
                      if (_details!.ticket.status.toLowerCase() != 'closed') _buildInputArea(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTicketInfo(SupportTicket ticket) {
    final dynamic ticketData = ticket;
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final priorityColor = _getPriorityColor(ticket.priority);
    final statusColor = _getStatusColor(ticket.status);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(context.isMobile ? 20 : 32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID: #${ticket.id}",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(12),
                  ),
                ),
                Text(
                  _formatFullDate(ticket.createdAt),
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                ),
              ],
            ),
            SizedBox(height: context.md),
            Text(
              ticket.title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: context.font(20),
              ),
            ),
            SizedBox(height: context.sm),
            Text(
              (ticketData.description as String?) ?? "No description provided.",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: context.font(14),
                height: 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.lg),
              child: Divider(color: colorScheme.outlineVariant, height: 1),
            ),
            Wrap(
              spacing: context.sm,
              runSpacing: context.sm,
              children: [
                _infoChip(Icons.priority_high, "Priority", ticket.priority.toUpperCase(), priorityColor),
                _infoChip(Icons.category_outlined, "Category", ticket.category ?? "General", colorScheme.primary),
                _infoChip(Icons.info_outline, "Status", ticket.status.toUpperCase(), statusColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.scale(8)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.scale(14), color: color),
          SizedBox(width: context.sm),
          Text(
            "$label: ",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11)),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.font(11)),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBubble(TicketReply reply) {
    bool isSupport = reply.userRole?.toLowerCase() != 'student';
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: context.md),
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(context.md),
        constraints: BoxConstraints(maxWidth: context.screenWidth * 0.75),
        decoration: BoxDecoration(
          color: isSupport ? colorScheme.surfaceContainerLow : primaryColor,
          borderRadius: BorderRadius.circular(context.scale(16)).copyWith(
            bottomLeft: isSupport ? Radius.circular(0) : Radius.circular(context.scale(16)),
            bottomRight: isSupport ? Radius.circular(context.scale(16)) : Radius.circular(0),
          ),
          border: isSupport ? Border.all(color: colorScheme.outlineVariant) : null,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: context.scale(10),
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
                    color: isSupport ? primaryColor : colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(12),
                  ),
                ),
                SizedBox(width: context.md),
                Text(
                  _formatDate(reply.createdAt),
                  style: TextStyle(
                    color: isSupport ? colorScheme.onSurfaceVariant : colorScheme.onPrimary.withValues(alpha: 0.7),
                    fontSize: context.font(10),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sm),
            Text(
              reply.message,
              style: TextStyle(
                color: isSupport ? colorScheme.onSurface : colorScheme.onPrimary,
                fontSize: context.font(14),
                height: 1.5,
              ),
            ),
            if (reply.attachment != null) ...[
              SizedBox(height: context.md),
              InkWell(
                onTap: () {
                  // Handle attachment download/view
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(6)),
                  decoration: BoxDecoration(
                    color: isSupport ? colorScheme.primary.withValues(alpha: 0.1) : Colors.black12,
                    borderRadius: BorderRadius.circular(context.scale(6)),
                    border: Border.all(color: isSupport ? colorScheme.primary.withValues(alpha: 0.2) : Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_file, color: isSupport ? colorScheme.primary : colorScheme.onPrimary.withValues(alpha: 0.7), size: context.scale(14)),
                      SizedBox(width: context.sm),
                      Text(
                        "Attachment",
                        style: TextStyle(
                          color: isSupport ? colorScheme.primary : colorScheme.onPrimary,
                          fontSize: context.font(11),
                          decoration: TextDecoration.underline,
                          decorationColor: isSupport ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.onPrimary.withValues(alpha: 0.3),
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
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    return Container(
      padding: EdgeInsets.fromLTRB(context.md, context.md, context.md, context.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              if (_selectedFile != null)
                Container(
                  margin: EdgeInsets.only(bottom: context.md),
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(10)),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: primaryColor, size: context.scale(20)),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Text(
                          _selectedFile!.path.split('/').last,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(13)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: colorScheme.error, size: context.scale(20)),
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
                    icon: Icon(Icons.add_circle_outline, color: primaryColor, size: context.scale(24)),
                    onPressed: _pickFile,
                    tooltip: "Attach file",
                  ),
                  SizedBox(width: context.xs),
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Write a reply...",
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: context.md),
                  _isSending
                      ? SizedBox(width: context.scale(48), height: context.scale(48), child: Padding(padding: EdgeInsets.all(context.scale(12)), child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3)))
                      : FloatingActionButton.small(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          foregroundColor: colorScheme.onPrimary,
                          onPressed: _sendReply,
                          child: Icon(Icons.send_rounded, size: context.scale(18)),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Red
      case 'medium':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF3B82F6); // Blue
      case 'closed':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF3B82F6); // Blue
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

class _TicketDetailsSkeleton extends StatelessWidget {
  const _TicketDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(context.scale(20)),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: context.scale(60), height: context.scale(12)),
                        SkeletonBox(width: context.scale(100), height: context.scale(12)),
                      ],
                    ),
                    SizedBox(height: context.scale(16)),
                    SkeletonBox(width: context.scale(200), height: context.scale(24)),
                    SizedBox(height: context.scale(12)),
                    SkeletonBox(width: double.infinity, height: context.scale(16)),
                    SkeletonBox(width: double.infinity, height: context.scale(16)),
                    SizedBox(height: context.scale(20)),
                    Wrap(
                      spacing: context.scale(8),
                      runSpacing: context.scale(8),
                      children: List.generate(3, (index) => SkeletonBox(width: context.scale(80), height: context.scale(32))),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.scale(24)),
              SkeletonBox(width: context.scale(150), height: context.scale(20)),
              SizedBox(height: context.scale(16)),
              ...List.generate(3, (index) => Padding(
                padding: EdgeInsets.only(bottom: context.scale(16)),
                child: Align(
                  alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: SkeletonBox(
                    width: context.screenWidth * 0.6,
                    height: context.scale(80),
                    borderRadius: BorderRadius.circular(context.scale(16)),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
