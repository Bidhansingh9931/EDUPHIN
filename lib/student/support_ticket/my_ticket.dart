import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/student/support_ticket/create_tickets.dart';
import 'package:eduphin/student/support_ticket/ticket_details.dart';
import 'package:intl/intl.dart';

class YourSupportTicket extends StatelessWidget {
  const YourSupportTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return const SupportTicketsPage();
  }
}

class _TicketSkeleton extends StatelessWidget {
  const _TicketSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSkeleton(context),
              SizedBox(height: context.scale(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(24)),
                  SkeletonBox(width: context.scale(80), height: context.scale(24)),
                ],
              ),
              SizedBox(height: context.scale(16)),
              LayoutBuilder(builder: (context, constraints) {
                final int crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: context.scale(16),
                    mainAxisSpacing: context.scale(16),
                    mainAxisExtent: context.scale(180),
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildCardSkeleton(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSkeleton(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SkeletonBox(width: context.scale(24), height: context.scale(24)),
              SizedBox(width: context.scale(8)),
              SkeletonBox(width: context.scale(120), height: context.scale(20)),
            ],
          ),
          SizedBox(height: context.scale(20)),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: context.scale(40))),
              SizedBox(width: context.scale(16)),
              Expanded(child: SkeletonBox(height: context.scale(40))),
              SizedBox(width: context.scale(16)),
              Expanded(child: SkeletonBox(height: context.scale(40))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
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
              SkeletonBox(width: context.scale(40), height: context.scale(12)),
              SkeletonBox(width: context.scale(60), height: context.scale(12)),
            ],
          ),
          SizedBox(height: context.scale(12)),
          SkeletonBox(width: double.infinity, height: context.scale(16)),
          SizedBox(height: context.scale(8)),
          SkeletonBox(width: context.scale(100), height: context.scale(12)),
          SizedBox(height: context.scale(4)),
          SkeletonBox(width: context.scale(120), height: context.scale(12)),
          const Spacer(),
          Row(
            children: [
              SkeletonBox(width: context.scale(60), height: context.scale(20)),
              SizedBox(width: context.scale(8)),
              SkeletonBox(width: context.scale(60), height: context.scale(20)),
            ],
          ),
        ],
      ),
    );
  }
}

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedPriority = "all";
  String _selectedStatus = "all";
  static const String _cacheKey = 'student_support_tickets';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _tickets = (cachedData as List).map((e) => SupportTicket.fromJson(e)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTickets() async {
    if (_tickets.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final filters = {
        'search': _searchQuery,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      };
      final tickets = await ApiService.getStudentTickets(filters);
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
        await CacheService.saveData(_cacheKey, tickets.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
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
          "Support Tickets",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: _fetchTickets,
          ),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _tickets.isNotEmpty,
        skeleton: const _TicketSkeleton(),
        onRefresh: _fetchTickets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterCard(),
                  SizedBox(height: context.scale(24)),
                  _buildTicketSection(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSupportTicketPage()),
          );
          if (result == true) {
            _fetchTickets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterCard() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(8)),
                Text(
                  "Filter Tickets",
                  style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
              ],
            ),
            SizedBox(height: context.scale(20)),
            LayoutBuilder(
              builder: (context, constraints) {
                final double spacing = context.scale(16);
                final int crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
                final double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: context.scale(8)),
                            child: Text("Search Query", style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.w500)),
                          ),
                          TextField(
                            controller: _searchController,
                            style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14)),
                            decoration: InputDecoration(
                              hintText: "Search by title...",
                              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              prefixIcon: Icon(Icons.search, size: context.scale(20), color: colorScheme.onSurfaceVariant),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
                            ),
                            onChanged: (val) => _searchQuery = val,
                            onSubmitted: (val) => _fetchTickets(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: context.scale(8)),
                            child: Text("Priority", style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.w500)),
                          ),
                          _buildDropdown(_selectedPriority, ["all", "low", "medium", "high"], (val) {
                            setState(() => _selectedPriority = val!);
                            _fetchTickets();
                          }),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: context.scale(8)),
                            child: Text("Status", style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.w500)),
                          ),
                          _buildDropdown(_selectedStatus, ["all", "open", "closed"], (val) {
                            setState(() => _selectedStatus = val!);
                            _fetchTickets();
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: context.scale(24)),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 0,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                        _selectedPriority = "all";
                        _selectedStatus = "all";
                      });
                      _fetchTickets();
                    },
                    child: Text("RESET", style: TextStyle(fontSize: context.font(14))),
                  ),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                    ),
                    onPressed: _fetchTickets,
                    child: Text("APPLY", style: TextStyle(fontSize: context.font(14))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSection() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scale(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ticket History",
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Text(
                  "${_tickets.length} tickets",
                  style: TextStyle(color: colorScheme.primary, fontSize: context.font(12), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.scale(16)),
        if (_tickets.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.scale(60)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.scale(16)),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.confirmation_number_outlined, color: colorScheme.outlineVariant, size: context.scale(64)),
                SizedBox(height: context.scale(16)),
                Text("No tickets found", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(16))),
              ],
            ),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            final int crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: context.scale(16),
                mainAxisSpacing: context.scale(16),
                mainAxisExtent: context.scale(180),
              ),
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(_tickets[index]);
              },
            );
          }),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildTicketCard(SupportTicket ticket) {
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentTicketDetailsPage(
                ticketId: ticket.id.toString(),
              ),
            ),
          ).then((_) => _fetchTickets());
        },
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: Padding(
          padding: EdgeInsets.all(context.scale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "#${ticket.id}",
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(11)),
                  ),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                  ),
                ],
              ),
              SizedBox(height: context.scale(12)),
              Text(
                ticket.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(14)),
              ),
              SizedBox(height: context.scale(8)),
              Row(
                children: [
                  Icon(Icons.category_outlined, color: colorScheme.onSurfaceVariant, size: context.scale(14)),
                  SizedBox(width: context.scale(4)),
                  Expanded(
                    child: Text(
                      ticket.category ?? "General",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.scale(4)),
              Row(
                children: [
                  Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant, size: context.scale(14)),
                  SizedBox(width: context.scale(4)),
                  Expanded(
                    child: Text(
                      ticket.assignedTo ?? "Unassigned",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _statusBadge(ticket.priority, priorityColor),
                  SizedBox(width: context.scale(8)),
                  _statusBadge(ticket.status, statusColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(4)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: colorScheme.surfaceContainerHighest,
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.toUpperCase(),
            style: TextStyle(color: colorScheme.onSurface, fontSize: context.font(14)),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
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
}
