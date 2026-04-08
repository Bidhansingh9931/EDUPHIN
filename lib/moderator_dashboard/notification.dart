import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

import 'notification_model.dart';
import 'notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Message>> _messagesFuture;
  final NotificationProvider _provider = NotificationProvider();

  @override
  void initState() {
    super.initState();
    _messagesFuture = _provider.fetchMessages();
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _messagesFuture = _provider.fetchMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            onPressed: _refreshMessages,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessages,
        child: FutureBuilder<List<Message>>(
          future: _messagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load messages', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _refreshMessages, child: const Text("Retry")),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final messageList = snapshot.data!;
              if (messageList.isEmpty) {
                return _buildEmptyState(theme);
              }
              return ListView.builder(
                padding: context.pagePadding,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return MessageCard(messageList[index]);
                },
              );
            } else {
              return const Center(child: Text('No messages found.'));
            }
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
          Icon(Icons.mark_email_read_outlined, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("No messages yet", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Incoming messages will appear here", style: TextStyle(color: theme.hintColor)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      msg.name.isNotEmpty ? msg.name[0].toUpperCase() : '',
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          msg.title,
                          style: TextStyle(color: theme.hintColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    msg.time,
                    style: TextStyle(color: theme.hintColor, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
