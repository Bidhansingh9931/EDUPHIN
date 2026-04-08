import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../librarian_models.dart';
import 'package:intl/intl.dart';

class EditIssuePage extends StatefulWidget {
  final IssuedBook issuedBook;
  const EditIssuePage({super.key, required this.issuedBook});

  @override
  State<EditIssuePage> createState() => _EditIssuePageState();
}

class _EditIssuePageState extends State<EditIssuePage> {
  late TextEditingController _issuedDateController;
  late TextEditingController _dueDateController;
  final TextEditingController _notesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInitialLoading = true;
  
  List<dynamic> _books = [];
  List<dynamic> _users = [];
  String? selectedBookId;
  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    _issuedDateController = TextEditingController(text: widget.issuedBook.issuedAt ?? "");
    _dueDateController = TextEditingController(text: widget.issuedBook.dueDate ?? "");
    selectedBookId = widget.issuedBook.bookId.toString();
    selectedUserId = widget.issuedBook.issuedToId?.toString();
    _fetchEditData();
  }

  Future<void> _fetchEditData() async {
    try {
      final data = await ApiService.getEditIssueData(widget.issuedBook.id.toString());
      setState(() {
        _books = data['books'] ?? [];
        _users = data['users'] ?? [];
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() => _isInitialLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
  }

  @override
  void dispose() {
    _issuedDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateIssue() async {
    if (selectedBookId == null || selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select book and user")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'book_id': selectedBookId,
        'issued_to': selectedUserId,
        'issued_at': _issuedDateController.text,
        'due_date': _dueDateController.text,
        'notes': _notesController.text,
      };
      await ApiService.updateIssuedBook(widget.issuedBook.id.toString(), data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Issue details updated successfully")));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Issue (ID: ${widget.issuedBook.id})"),
      ),
      body: _isInitialLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.edit_calendar_outlined, size: 48, color: theme.colorScheme.primary),
                              const SizedBox(height: 16),
                              Text("Update Issue Details", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("Modify dates or reassignment notes below.", style: TextStyle(color: theme.hintColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildResponsiveRow(context, [
                          _buildDropdownField(
                            context,
                            "Select Book",
                            selectedBookId, 
                            _books.map((b) => DropdownMenuItem<String>(
                              value: b['id'].toString(),
                              child: Text(b['title'] ?? "N/A"),
                            )).toList(), 
                            (val) => setState(() => selectedBookId = val)
                          ),
                          _buildDropdownField(
                            context,
                            "Issue To (User)",
                            selectedUserId, 
                            _users.map((u) => DropdownMenuItem<String>(
                              value: u['id'].toString(),
                              child: Text(u['name'] ?? "N/A"),
                            )).toList(), 
                            (val) => setState(() => selectedUserId = val)
                          ),
                        ]),

                        _buildResponsiveRow(context, [
                          _buildDateField(context, "Issued Date", _issuedDateController),
                          _buildDateField(context, "Due Date", _dueDateController),
                        ]),
                        
                        _buildInputField(context, "Notes / Remarks", "e.g. extension requested", _notesController, maxLines: 3),
                        
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateIssue,
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("UPDATE"),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            hint: const Text("Select option"),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, controller),
            child: IgnorePointer(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "yyyy-mm-dd",
                  suffixIcon: Icon(Icons.calendar_month, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
