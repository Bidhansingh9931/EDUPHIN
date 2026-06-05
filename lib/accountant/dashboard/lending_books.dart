import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:intl/intl.dart';
import '../../services/error_handler.dart';

class LendingBooksPage extends StatefulWidget {
  const LendingBooksPage({super.key});

  @override
  State<LendingBooksPage> createState() => _LendingBooksPageState();
}

class _LendingBooksPageState extends State<LendingBooksPage> {
  int _currentPage = 1;
  late Stream<LendingPagination> _lendingStream;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _issuedFromController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _dueToController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    final filters = {
      'book_title': _titleController.text,
      'issued_from': _issuedFromController.text,
      'due_from': _dueFromController.text,
      'due_to': _dueToController.text,
      if (_selectedStatus != 'all') 'returned_status': _selectedStatus,
    };
    _lendingStream = ApiService.getAccountantLendingBooksStream(filters, _currentPage)..handleError((error) {
      if (mounted) ErrorHandler.showError(context, error);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuedFromController.dispose();
    _dueFromController.dispose();
    _dueToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text("Lending Records"),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<LendingPagination>(
        stream: _lendingStream,
        builder: (context, snapshot) {
          return LoadingWrapper<LendingPagination>(
            snapshot: snapshot,
            onRetry: _updateStream,
            skeleton: _buildSkeleton(context),
            builder: (data) {
              final issuedBooks = data.issuedBooks;
              final totalPages = data.lastPage;
              final isRefreshing = snapshot.connectionState == ConnectionState.waiting;

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(1000)),
                    child: Column(
                      children: [
                        _buildFilterCard(context),
                        SizedBox(height: context.spacing),
                        _buildLendingList(context, issuedBooks, isRefreshing),
                        SizedBox(height: context.spacing),
                        _buildPagination(context, totalPages),
                        SizedBox(height: context.spacing * 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            children: [
              Skeleton(height: context.scale(250), width: double.infinity, borderRadius: context.scale(16)),
              SizedBox(height: context.spacing),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
                  mainAxisExtent: context.scale(180),
                  crossAxisSpacing: context.spacing,
                  mainAxisSpacing: context.spacing,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => Skeleton(borderRadius: context.scale(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: theme.colorScheme.primary, size: context.scale(20)),
                  SizedBox(width: context.scale(8)),
                  Text("Search & Filter", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: context.spacing),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Search by book title", 
                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
              ),
            ),
            SizedBox(height: context.spacing),
            if (context.isTablet || context.isDesktop)
              Row(
                children: [
                  Expanded(child: _buildDateField(context, "Issued From", _issuedFromController)),
                  SizedBox(width: context.spacing),
                  Expanded(child: _buildStatusDropdown(context)),
                ],
              )
            else ...[
              _buildDateField(context, "Issued From", _issuedFromController),
              SizedBox(height: context.spacing),
              _buildStatusDropdown(context),
            ],
            SizedBox(height: context.spacing * 1.5),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _updateStream()),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: const Text("APPLY FILTERS"),
                  ),
                ),
                SizedBox(width: context.spacing),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _titleController.clear();
                      _issuedFromController.clear();
                      _dueFromController.clear();
                      _dueToController.clear();
                      setState(() {
                        _selectedStatus = 'all';
                        _updateStream();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: const Text("RESET"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today, size: context.scale(18)),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
        if (picked != null) controller.text = DateFormat('yyyy-MM-dd').format(picked);
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'all', child: Text("All Status")),
        DropdownMenuItem(value: 'returned', child: Text("Returned")),
        DropdownMenuItem(value: 'issued', child: Text("Issued")),
      ],
      onChanged: (val) => setState(() => _selectedStatus = val!),
      decoration: InputDecoration(
        labelText: "Return Status",
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
      ),
    );
  }

  Widget _buildLendingList(BuildContext context, List<IssuedBook> issuedBooks, bool isRefreshing) {
    final theme = context.theme;
    if (issuedBooks.isEmpty && !isRefreshing) {
      return Padding(
        padding: EdgeInsets.all(context.scale(40)), 
        child: Center(child: Text("No records found", style: TextStyle(color: theme.hintColor)))
      );
    }

    return Opacity(
      opacity: isRefreshing ? 0.6 : 1.0,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
          mainAxisExtent: context.scale(180),
          crossAxisSpacing: context.spacing,
          mainAxisSpacing: context.spacing,
        ),
        itemCount: issuedBooks.length,
        itemBuilder: (context, index) {
          final record = issuedBooks[index];
          final isReturned = record.returnedAt != null;

          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.book.title, 
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15)), 
                        ),
                        SizedBox(width: context.spacing),
                        _statusBadge(context, isReturned),
                      ],
                    ),
                  ),
                  Text("ISBN: ${record.book.isbn ?? 'N/A'}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Divider(color: theme.colorScheme.outlineVariant, height: context.spacing),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCol(context, "Issued", record.issuedAt),
                        SizedBox(width: context.scale(24)),
                        _infoCol(context, "Due", record.dueDate, isRed: (record.daysOverdue ?? 0) > 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(BuildContext context, bool isReturned) {
    final color = isReturned ? Colors.green : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(6)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isReturned ? "RETURNED" : "ISSUED", 
        style: TextStyle(color: color, fontSize: context.font(9), fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _infoCol(BuildContext context, String label, String value, {bool isRed = false}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: label == "Due" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.hintColor, fontSize: context.font(10), fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12), color: isRed ? Colors.red : theme.colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: _currentPage > 1 ? () {
            setState(() {
              _currentPage--;
              _updateStream();
            });
          } : null,
          icon: const Icon(Icons.chevron_left),
        ),
        SizedBox(width: context.spacing),
        Text("Page $_currentPage of $totalPages", style: context.theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(width: context.spacing),
        IconButton.filledTonal(
          onPressed: _currentPage < totalPages ? () {
            setState(() {
              _currentPage++;
              _updateStream();
            });
          } : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
