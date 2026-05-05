import '../../../services/error_handler.dart';
import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../teacher/dashboard/app_drawer.dart';
import '../librarian_skeleton_widgets.dart';
import '../../services/common_widgets.dart';
import 'issue_list.dart';
import 'package:intl/intl.dart';

class IssueBookPage extends StatefulWidget {
  const IssueBookPage({super.key});

  @override
  State<IssueBookPage> createState() => _IssueBookPageState();
}

class _IssueBookPageState extends State<IssueBookPage> {
  late Stream<Map<String, dynamic>> _dataStream;
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
    _refreshData();
    _issuedDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _refreshData() {
    setState(() {
      _dataStream = ApiService.getIssueBookCreateDataStream().asBroadcastStream();
    });
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
      if (mounted) ErrorHandler.showError(context, e);
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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Issue New Book"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.scale(8)),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IssuedBooksListPage()),
                );
              },
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              label: const Text("VIEW LIST"),
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _dataStream,
        builder: (context, snapshot) {
          return LoadingWrapper<Map<String, dynamic>>(
            snapshot: snapshot,
            skeleton: const TicketSkeleton(), // Reusing TicketSkeleton as a generic form-ish skeleton or we could use ProfileSkeleton
            onRetry: _refreshData,
            builder: (data) {
              _books = data['books'] ?? [];
              _users = data['users'] ?? [];

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.md),
                            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(context.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(context.md),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.assignment_turned_in_rounded, size: context.scale(40), color: theme.colorScheme.onPrimaryContainer),
                                      ),
                                      SizedBox(height: context.md),
                                      Text(
                                        "Issue Book Details",
                                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(24)),
                                      ),
                                      SizedBox(height: context.sm),
                                      Text(
                                        "Assign a library resource to a registered user.",
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline, fontSize: context.font(14)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: context.xl),

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

                                SizedBox(height: context.md),

                                FilledButton.icon(
                                  onPressed: _isSubmitting ? null : _issueBook,
                                  icon: _isSubmitting 
                                    ? SizedBox(width: context.md, height: context.md, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2))
                                    : const Icon(Icons.check_circle_rounded),
                                  label: const Text("ISSUE BOOK"),
                                  style: FilledButton.styleFrom(
                                    minimumSize: Size(double.infinity, context.scale(56)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                  ),
                                ),
                                SizedBox(height: context.md),
                                FilledButton.tonal(
                                  onPressed: () => Navigator.pop(context),
                                  style: FilledButton.styleFrom(
                                    minimumSize: Size(double.infinity, context.scale(56)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                  ),
                                  child: const Text("CANCEL"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: context.xl),
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

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) return Column(children: children);
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.key != children.length - 1 ? context.md : 0,
                    ),
                    child: entry.value,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            hint: const Text("Select option"),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          InkWell(
            onTap: () => _selectDate(context, controller),
            borderRadius: BorderRadius.circular(context.sm),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sm),
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? "yyyy-mm-dd" : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: controller.text.isEmpty ? theme.colorScheme.outline : null,
                        fontSize: context.font(14),
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, size: context.scale(18), color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
