import 'dart:convert';
import 'package:eduphin/teacher/dashboard/ticket_details_page.dart';
import 'package:eduphin/teacher/dashboard/create_new_support_ticket.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/ticket_models.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart' as teacher_common;

class YourSupportTicketPage extends StatefulWidget {
  const YourSupportTicketPage({super.key});

  @override
  State<YourSupportTicketPage> createState() => _YourSupportTicketPageState();
}

class _YourSupportTicketPageState extends State<YourSupportTicketPage> {
  final Map<String, String?> _filters = {'priority': null, 'status': null};
  final TextEditingController _searchController = TextEditingController();
  List<SupportTicket>? _tickets;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final filterKey = 'tickets_${jsonEncode(_getCleanFilters())}';

    try {
      // Load from cache first
      final cachedData = await TeacherCacheService.load(filterKey);
      if (cachedData != null && cachedData is List) {
        setState(() {
          _tickets = cachedData.map((e) => SupportTicket.fromJson(e)).toList();
          _isLoading = false;
        });
      }

      // Fetch fresh data
      final freshData = await ApiService.getMyTickets(_getCleanFilters());
      await TeacherCacheService.save(filterKey, freshData.map((e) => e.toJson()).toList());

      if (mounted) {
        setState(() {
          _tickets = freshData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_tickets == null) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update tickets: $e")),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Your Support Tickets", style: theme.appBarTheme.titleTextStyle?.copyWith(fontWeight: FontWeight.bold) ?? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTickets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Ticket List", Icons.list_alt_outlined),
                  const SizedBox(height: 16),
                  teacher_common.TeacherLoadingWrapper(
                    isLoading: _isLoading,
                    hasData: _tickets != null,
                    skeleton: _buildSkeleton(),
                    child: _error != null
                        ? _buildErrorState(_error!)
                        : (_tickets == null || _tickets!.isEmpty)
                            ? _buildEmptyState()
                            : _buildTicketsList(_tickets!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSupportTicketPage())).then((_) => _fetchTickets()),
                      icon: Icon(Icons.add, size: context.scale(20)),
                      label: Text("CREATE NEW TICKET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), letterSpacing: 1.1)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: EdgeInsets.only(bottom: context.scale(16)),
        child: teacher_common.TeacherSkeleton(
          height: context.scale(100),
          borderRadius: BorderRadius.circular(context.scale(20)),
        ),
      )),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: context.scale(20)),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text("Failed to load tickets", style: theme.textTheme.titleMedium),
            Text(error, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchTickets,
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.confirmation_number_outlined, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text("No tickets found", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),
            Text("You haven't created any support tickets yet.", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getCleanFilters() {
    final clean = <String, String>{};
    if (_searchController.text.isNotEmpty) clean['search'] = _searchController.text;
    if (_filters['priority'] != null) clean['priority'] = _filters['priority']!;
    if (_filters['status'] != null) clean['status'] = _filters['status']!;
    return clean;
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filters", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
            SizedBox(height: context.scale(16)),
            if (context.isMobile) ...[
              teacher_common.buildTextField(context, _searchController, "Search by Title...", prefixIcon: Icons.search),
              SizedBox(height: context.scale(12)),
              teacher_common.buildDropdown(
                context,
                ['low', 'medium', 'high'],
                _filters['priority'],
                (val) => setState(() => _filters['priority'] = val),
                hint: "All Priorities",
              ),
              SizedBox(height: context.scale(12)),
              teacher_common.buildDropdown(
                context,
                ['open', 'in_progress', 'resolved', 'closed'],
                _filters['status'],
                (val) => setState(() => _filters['status'] = val),
                hint: "All Statuses",
              ),
            ] else
              teacher_common.buildResponsiveRow(context, [
                teacher_common.buildTextField(context, _searchController, "Search by Title...", prefixIcon: Icons.search),
                teacher_common.buildDropdown(
                  context,
                  ['low', 'medium', 'high'],
                  _filters['priority'],
                  (val) => setState(() => _filters['priority'] = val),
                  hint: "All Priorities",
                ),
                teacher_common.buildDropdown(
                  context,
                  ['open', 'in_progress', 'resolved', 'closed'],
                  _filters['status'],
                  (val) => setState(() => _filters['status'] = val),
                  hint: "All Statuses",
                ),
              ]),
            SizedBox(height: context.scale(16)),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.scale(8),
              runSpacing: context.scale(8),
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filters['priority'] = null;
                      _filters['status'] = null;
                      _fetchTickets();
                    });
                  },
                  icon: Icon(Icons.clear_all, size: context.scale(18)),
                  label: Text("Reset Filters", style: TextStyle(fontSize: context.font(12))),
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurfaceVariant),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchTickets,
                  icon: Icon(Icons.search, size: context.scale(18)),
                  label: Text("Apply Search", style: TextStyle(fontSize: context.font(12))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.primary,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          showCheckboxColumn: false,
          columnSpacing: context.scale(24),
          horizontalMargin: context.scale(16),
          headingRowHeight: context.scale(56),
          dataRowMinHeight: context.scale(56),
          dataRowMaxHeight: context.scale(56),
          columns: [
            DataColumn(label: Text("#ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("PRIORITY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("CREATED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
          rows: tickets.map((ticket) {
            return DataRow(
              onSelectChanged: (_) => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailsPage(ticketId: ticket.id))),
              cells: [
                DataCell(Text(ticket.id.toString(), style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurface))),
                DataCell(
                  Container(
                    constraints: BoxConstraints(maxWidth: context.scale(250)),
                    child: Text(ticket.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(13), color: theme.colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                  )
                ),
                DataCell(_buildPriorityChip(ticket.priority)),
                DataCell(_buildStatusChip(ticket.status ?? 'open')),
                DataCell(Text(ticket.createdAt ?? "N/A", style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurface))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final theme = context.theme;
    Color color = theme.colorScheme.outline;
    if (priority.toLowerCase() == 'high') color = const Color(0xFFEF4444);
    else if (priority.toLowerCase() == 'medium') color = const Color(0xFFF59E0B);
    else if (priority.toLowerCase() == 'low') color = const Color(0xFF3B82F6);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final theme = context.theme;
    Color color = const Color(0xFF3B82F6); // Info/Open
    if (status.toLowerCase() == 'closed' || status.toLowerCase() == 'resolved') color = const Color(0xFF10B981); // Emerald
    else if (status.toLowerCase() == 'in_progress' || status.toLowerCase() == 'pending') color = const Color(0xFFF59E0B); // Amber

    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: context.font(10), fontWeight: FontWeight.bold),
      ),
    );
  }
}
