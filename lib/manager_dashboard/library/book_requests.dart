import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class BookRequestsScreen extends StatefulWidget {
  const BookRequestsScreen({super.key});

  @override
  State<BookRequestsScreen> createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  bool _isLoading = true;
  Object? _error;
  List<BookRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchRequests());
  }

  Future<void> _loadCachedData() async {
    final cache = await CacheService.getCache('book_requests');
    if (cache != null && mounted) {
      final List<dynamic> data = cache;
      setState(() {
        _requests = data.map((json) => BookRequest.fromJson(json)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = _requests.isEmpty;
      _error = null;
    });
    try {
      final response = await ApiService.get('manager/books/requests');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final List<dynamic> data = body['data'] is List ? body['data'] : (body['data']['data'] ?? []);
          await CacheService.setCache('book_requests', data);
          if (mounted) {
            setState(() {
              _requests = data.map((json) => BookRequest.fromJson(json)).toList();
              _isLoading = false;
            });
          }
        } else {
          throw Exception(body['message'] ?? 'Failed to load requests');
        }
      } else {
        throw Exception('Failed to load requests. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(int requestId, String status) async {
    try {
      final response = await ApiService.post('manager/books/requests/$requestId/status', {
        'status': status,
      });
      final body = json.decode(response.body);
      if (body['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request $status successfully")));
          _fetchRequests();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? "Failed to update status")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Book Requests", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Manage student book reservations", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchRequests,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
          SizedBox(width: context.xs),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _requests.isNotEmpty,
        error: _error,
        onRetry: _fetchRequests,
        skeleton: _buildSkeleton(context),
        child: _requests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_added_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    SizedBox(height: context.scale(16)),
                    Text("No pending book requests.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchRequests,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: context.responsive(
                      _buildListView(),
                      tablet: _buildGridView(2),
                      desktop: _buildGridView(3),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        margin: EdgeInsets.only(bottom: context.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(20)),
                  SkeletonBox(width: context.scale(60), height: context.scale(20)),
                ],
              ),
              SizedBox(height: context.scale(8)),
              SkeletonBox(width: context.scale(100), height: context.scale(14)),
              SizedBox(height: context.scale(16)),
              Row(
                children: [
                  SkeletonBox(width: context.scale(100), height: context.scale(30)),
                  SizedBox(width: context.scale(16)),
                  SkeletonBox(width: context.scale(100), height: context.scale(30)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: _requests.length,
      itemBuilder: (context, index) => _RequestCard(
        request: _requests[index],
        onApprove: () => _updateStatus(_requests[index].id, 'approved'),
        onReject: () => _updateStatus(_requests[index].id, 'rejected'),
      ),
    );
  }

  Widget _buildGridView(int crossAxisCount) {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: _requests.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) => _RequestCard(
        request: _requests[index],
        onApprove: () => _updateStatus(_requests[index].id, 'approved'),
        onReject: () => _updateStatus(_requests[index].id, 'rejected'),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BookRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({required this.request, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.bookTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                      Text("By ${request.bookAuthor}", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                _InfoItem(icon: Icons.person_outline, label: "Student", value: request.studentName),
                SizedBox(width: context.lg),
                _InfoItem(icon: Icons.calendar_today_outlined, label: "Requested On", value: request.requestedDate),
              ],
            ),
            const Spacer(),
            if (request.status.toLowerCase() == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      ),
                      child: const Text("REJECT"),
                    ),
                  ),
                  SizedBox(width: context.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: onApprove,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                      ),
                      child: const Text("APPROVE"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = theme.colorScheme.error;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: context.font(10)),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(16), color: theme.colorScheme.primary),
        SizedBox(width: context.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(9), color: theme.hintColor)),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(12))),
          ],
        ),
      ],
    );
  }
}

class BookRequest {
  final int id;
  final String bookTitle;
  final String bookAuthor;
  final String studentName;
  final String requestedDate;
  final String status;

  BookRequest({
    required this.id,
    required this.bookTitle,
    required this.bookAuthor,
    required this.studentName,
    required this.requestedDate,
    required this.status,
  });

  factory BookRequest.fromJson(Map<String, dynamic> json) {
    return BookRequest(
      id: json['id'] ?? 0,
      bookTitle: json['book']?['title'] ?? 'N/A',
      bookAuthor: json['book']?['author'] ?? 'N/A',
      studentName: json['student']?['name'] ?? 'N/A',
      requestedDate: json['created_at']?.toString().substring(0, 10) ?? 'N/A',
      status: json['status'] ?? 'Pending',
    );
  }
}

