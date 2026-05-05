import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'notification_model.dart';
import 'notification_provider.dart';
import 'skeleton_widgets.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Message>> _messagesFuture;
  final NotificationProvider _provider = NotificationProvider();
  List<Message>? _cachedMessages;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cached = await _provider.getCachedMessages();
    if (mounted) {
      setState(() {
        _cachedMessages = cached;
        _messagesFuture = _provider.fetchMessages();
      });
    }
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _messagesFuture = _provider.fetchMessages(bypassCache: true);
    });
    try {
      await _messagesFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            onPressed: _refreshMessages,
            icon: Icon(Icons.refresh_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.scale(8)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: FutureBuilder<List<Message>>(
          future: _messagesFuture,
          builder: (context, snapshot) {
            return ModeratorLoadingWrapper<List<Message>>(
              snapshot: snapshot,
              cachedData: _cachedMessages,
              skeleton: const NotificationSkeleton(),
              onRefresh: _refreshMessages,
              builder: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyState(theme);
                }
                return ListView.builder(
                  padding: context.pagePadding,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageCard(messages[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: context.scale(64), color: theme.hintColor.withValues(alpha: 0.3)),
          SizedBox(height: context.scale(16)),
          Text("No messages yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16))),
          SizedBox(height: context.scale(8)),
          Text("Incoming messages will appear here", style: TextStyle(color: theme.hintColor, fontSize: context.font(14))),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final Message msg;

  const MessageCard(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: context.scale(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: Padding(
          padding: EdgeInsets.all(context.scale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: context.scale(24),
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      msg.name.isNotEmpty ? msg.name[0].toUpperCase() : '',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                    ),
                  ),
                  SizedBox(width: context.scale(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          msg.title,
                          style: TextStyle(color: theme.hintColor, fontSize: context.font(13)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(8)),
                  Text(
                    msg.time,
                    style: TextStyle(color: theme.hintColor, fontSize: context.font(11)),
                  ),
                ],
              ),
              SizedBox(height: context.scale(12)),
              const Divider(height: 1),
              SizedBox(height: context.scale(12)),
              Text(
                msg.preview,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
