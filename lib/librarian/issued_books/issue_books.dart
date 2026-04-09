import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'issue_list.dart';
import 'package:intl/intl.dart';

class IssueBookPage extends StatefulWidget {
  const IssueBookPage({super.key});

  @override
  State<IssueBookPage> createState() => _IssueBookPageState();
}

class _IssueBookPageState extends State<IssueBookPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<dynamic> _books = [];
  List<dynamic> _users = [];

  String? selectedBookId;
  String? selectedUserId;

  final TextEditingController _issuedDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitData();
    _issuedDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _fetchInitData() async {
    try {
      final data = await ApiService.getIssueBookCreateData();
      setState(() {
        _books = data['books'] ?? [];
        _users = data['users'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
  }

  Future<void> _issueBook() async {
    if (selectedBookId == null || selectedUserId == null || _issuedDateController.text.isEmpty || _dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'book_id': selectedBookId,
        'issued_to': selectedUserId,
        'issued_at': _issuedDateController.text,
        'due_date': _dueDateController.text,
      };
      await ApiService.createIssuedBook(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book issued successfully")));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Issue New Book"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IssuedBooksListPage()),
                );
              },
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text("View List"),
            ),
          )
        ],
      ),
      body: _isLoading 
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
                                Icon(Icons.assignment_turned_in_outlined, size: 48, color: theme.colorScheme.primary),
                                const SizedBox(height: 16),
                                Text("Issue Book Details", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text("Select the resource and the user to assign it to.", style: TextStyle(color: theme.hintColor)),
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
                                child: Text("${u['name']} (${u['role']?['name'] ?? 'User'})"),
                              )).toList(), 
                              (val) => setState(() => selectedUserId = val)
                            ),
                          ]),

                          _buildResponsiveRow(context, [
                            _buildDateField(context, "Issued Date", _issuedDateController),
                            _buildDateField(context, "Due Date", _dueDateController),
                          ]),

                          const SizedBox(height: 32),

                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _issueBook,
                            child: _isSubmitting 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("ISSUE BOOK"),
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
}
