import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:intl/intl.dart';

class LendingBooksPage extends StatefulWidget {
  const LendingBooksPage({super.key});

  @override
  State<LendingBooksPage> createState() => _LendingBooksPageState();
}

class _LendingBooksPageState extends State<LendingBooksPage> {
  bool _isLoading = false;
  List<IssuedBook> _issuedBooks = [];
  int _currentPage = 1;
  int _totalPages = 1;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _issuedFromController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _dueToController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchLending();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuedFromController.dispose();
    _dueFromController.dispose();
    _dueToController.dispose();
    super.dispose();
  }

  Future<void> _fetchLending({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final filters = {
        'book_title': _titleController.text,
        'issued_from': _issuedFromController.text,
        'due_from': _dueFromController.text,
        'due_to': _dueToController.text,
        if (_selectedStatus != 'all') 'returned_status': _selectedStatus,
      };
      final result = await ApiService.getAccountantLendingBooks(filters, page);
      if (mounted) {
        setState(() {
          _issuedBooks = result.issuedBooks;
          _currentPage = result.currentPage;
          _totalPages = result.lastPage;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lending Records"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildFilterCard(context),
                    const SizedBox(height: 24),
                    _buildLendingList(context),
                    const SizedBox(height: 24),
                    _buildPagination(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Search & Filter", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Search by book title", prefixIcon: Icon(Icons.search)),
            ),
            const SizedBox(height: 16),
            if (context.isTablet)
              Row(
                children: [
                  Expanded(child: _buildDateField(context, "Issued From", _issuedFromController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatusDropdown(context)),
                ],
              )
            else ...[
              _buildDateField(context, "Issued From", _issuedFromController),
              const SizedBox(height: 12),
              _buildStatusDropdown(context),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _fetchLending(),
                    child: const Text("APPLY FILTERS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _titleController.clear();
                      _issuedFromController.clear();
                      _dueFromController.clear();
                      _dueToController.clear();
                      setState(() => _selectedStatus = 'all');
                      _fetchLending();
                    },
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
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
        if (picked != null) controller.text = DateFormat('yyyy-MM-dd').format(picked);
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'all', child: Text("All Status")),
        DropdownMenuItem(value: 'returned', child: Text("Returned")),
        DropdownMenuItem(value: 'issued', child: Text("Issued")),
      ],
      onChanged: (val) => setState(() => _selectedStatus = val!),
      decoration: const InputDecoration(labelText: "Return Status"),
    );
  }

  Widget _buildLendingList(BuildContext context) {
    if (_issuedBooks.isEmpty && !_isLoading) {
      return Padding(padding: const EdgeInsets.all(40), child: Center(child: Text("No records found", style: TextStyle(color: Theme.of(context).hintColor))));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 2 : 1,
        mainAxisExtent: 180,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _issuedBooks.length,
      itemBuilder: (context, index) {
        final record = _issuedBooks[index];
        final isReturned = record.returnedAt != null;
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(record.book.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    _statusBadge(isReturned),
                  ],
                ),
                Text("ISBN: ${record.book.isbn ?? 'N/A'}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCol(context, "Issued", record.issuedAt),
                    _infoCol(context, "Due", record.dueDate, isRed: (record.daysOverdue ?? 0) > 0),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(bool isReturned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isReturned ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (isReturned ? Colors.green : Colors.orange).withValues(alpha: 0.5)),
      ),
      child: Text(isReturned ? "RETURNED" : "ISSUED", 
        style: TextStyle(color: isReturned ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoCol(BuildContext context, String label, String value, {bool isRed = false}) {
    return Column(
      crossAxisAlignment: label == "Due" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isRed ? Colors.red : null)),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1 ? () => _fetchLending(page: _currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text("Page $_currentPage of $_totalPages", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: _currentPage < _totalPages ? () => _fetchLending(page: _currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
