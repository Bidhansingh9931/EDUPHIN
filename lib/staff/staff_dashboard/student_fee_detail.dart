import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/common_widgets.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';

class StaffStudentFeeDetailPage extends StatefulWidget {
  const StaffStudentFeeDetailPage({super.key});

  @override
  State<StaffStudentFeeDetailPage> createState() => _StaffStudentFeeDetailPageState();
}

class _StaffStudentFeeDetailPageState extends State<StaffStudentFeeDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<StudentFeeDetail>? _feeStream;

  void _fetchDetail() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _feeStream = ApiService.getStaffStudentFeeDetailStream(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Student Fee Detail"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildSearchBox(context),
                SizedBox(height: context.scale(24)),
                if (_feeStream != null)
                  StreamBuilder<StudentFeeDetail>(
                    stream: _feeStream,
                    builder: (context, snapshot) {
                      return LoadingWrapper<StudentFeeDetail>(
                        snapshot: snapshot,
                        skeleton: _buildSkeleton(context),
                        builder: (detail) => Column(
                          children: [
                            _buildStudentInfo(context, detail),
                            SizedBox(height: context.scale(24)),
                            _buildFeeSummary(context, detail),
                          ],
                        ),
                      );
                    },
                  )
                else
                  _buildEmptyState(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              children: [
                Skeleton(width: context.scale(56), height: context.scale(56), borderRadius: context.scale(28)),
                SizedBox(width: context.scale(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: context.scale(150), height: context.scale(20)),
                      SizedBox(height: context.scale(8)),
                      Skeleton(width: context.scale(200), height: context.scale(14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.scale(24)),
        Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(20)),
          ),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.all(context.scale(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: context.scale(120), height: context.scale(16)),
                        SizedBox(height: context.scale(8)),
                        Skeleton(width: context.scale(60), height: context.scale(14)),
                      ],
                    ),
                    Skeleton(width: context.scale(80), height: context.scale(28), borderRadius: context.scale(12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Query Fee Status",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
            SizedBox(height: context.scale(16)),
            TextField(
              controller: _searchController,
              style: TextStyle(fontSize: context.font(14)),
              onSubmitted: (_) => _fetchDetail(),
              decoration: InputDecoration(
                hintText: "Enter Student ID...",
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                  onPressed: _fetchDetail,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.person_search_outlined, color: context.theme.colorScheme.primary.withValues(alpha: 0.2), size: context.scale(64)),
        SizedBox(height: context.scale(16)),
        Text("Search by Student ID to view detailed fee reports", 
          style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14))),
      ],
    );
  }

  Widget _buildStudentInfo(BuildContext context, StudentFeeDetail detail) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Row(
          children: [
            CircleAvatar(
              radius: context.scale(28),
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: context.scale(28)),
            ),
            SizedBox(width: context.scale(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.studentName, 
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(18),
                    ),
                  ),
                  SizedBox(height: context.scale(4)),
                  Text("Roll No: ${detail.rollNo} • Class: ${detail.className}", 
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummary(BuildContext context, StudentFeeDetail detail) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(20)),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(12)),
                Text("Payment Records",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(14),
                  ),
                ),
              ],
            ),
          ),
          ...detail.fees.map((fee) => _buildFeeItem(context, fee)),
        ],
      ),
    );
  }

  Widget _buildFeeItem(BuildContext context, StudentFeeItem fee) {
    final theme = context.theme;
    bool isPaid = fee.status.toLowerCase() == 'paid';
    // Semantic Colors: Emerald (Paid/Success) 0xFF10B981, Amber (Pending/Warning) 0xFFF59E0B
    Color statusColor = isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(16)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fee.title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.bold)),
                  SizedBox(height: context.scale(4)),
                  Text("₹${fee.amount}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(13))),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(12)),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                fee.status.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: context.font(11), letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
