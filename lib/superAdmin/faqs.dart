import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';
import 'cache_service.dart';
import 'super_admin_common_widgets.dart';

class FAQManagementScreen extends StatefulWidget {
  const FAQManagementScreen({super.key});

  @override
  State<FAQManagementScreen> createState() => _FAQManagementScreenState();
}

class _FAQManagementScreenState extends State<FAQManagementScreen> {
  List<dynamic> _faqs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await SuperAdminCacheService.load('faqs');
    if (cachedData != null && mounted) {
      setState(() {
        _faqs = cachedData;
        _isLoading = false;
      });
    }
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    if (!mounted) return;
    if (_faqs.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final faqs = await ApiService.getFaqs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoading = false;
        });
        await SuperAdminCacheService.save('faqs', faqs);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _deleteFaq(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete FAQ"),
        content: const Text("Are you sure you want to delete this FAQ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteFaq(id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("FAQ deleted successfully")));
        _fetchFaqs();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showFAQModal({Map<String, dynamic>? faq}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateFAQModal(
        faq: faq,
        onSuccess: _fetchFaqs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FAQ Management", style: TextStyle(fontSize: context.font(18))),
            Text("Manage frequently asked questions", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SuperAdminLoadingWrapper(
        isLoading: _isLoading,
        hasData: _faqs.isNotEmpty,
        skeleton: _buildSkeleton(context),
        child: _errorMessage != null
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(context.scale(24.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                      SizedBox(height: context.scale(16)),
                      ElevatedButton(onPressed: _fetchFaqs, child: const Text("Retry")),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchFaqs,
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: theme.colorScheme.secondaryContainer,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
                          child: Text("Total FAQs: ${_faqs.length}",
                            style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: context.font(14))),
                        ),
                      ),
                      SizedBox(height: context.scale(24)),
                      ..._faqs.map((faq) => _buildFAQCard(faq)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SuperAdminSkeleton(height: context.scale(60)),
        )),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    final theme = context.theme;
    String formattedDate = faq['updated_at'] ?? faq['created_at'] ?? 'N/A';
    try {
       DateTime dt = DateTime.parse(formattedDate);
       formattedDate = DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {}

    return Card(
      margin: EdgeInsets.only(bottom: context.scale(16)),
      child: ExpansionTile(
        title: Text(faq['question'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
        subtitle: Text("Updated: $formattedDate", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
        childrenPadding: EdgeInsets.all(context.scale(16)),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          SizedBox(height: context.scale(16)),
          Text(faq['answer'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: context.font(14))),
          SizedBox(height: context.scale(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showFAQModal(faq: faq),
                icon: Icon(Icons.edit_outlined, size: context.scale(18)),
                label: Text("EDIT", style: TextStyle(fontSize: context.font(12))),
              ),
              SizedBox(width: context.scale(8)),
              TextButton.icon(
                onPressed: () => _deleteFaq(faq['id'].toString()),
                icon: Icon(Icons.delete_outline, size: context.scale(18)),
                label: Text("DELETE", style: TextStyle(fontSize: context.font(12))),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateFAQModal extends StatefulWidget {
  final Map<String, dynamic>? faq;
  final VoidCallback onSuccess;

  const CreateFAQModal({super.key, this.faq, required this.onSuccess});

  @override
  State<CreateFAQModal> createState() => _CreateFAQModalState();
}

class _CreateFAQModalState extends State<CreateFAQModal> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.faq != null) {
      _questionController.text = widget.faq!['question'] ?? '';
      _answerController.text = widget.faq!['answer'] ?? '';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_questionController.text.trim().isEmpty || _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
      };

      if (widget.faq != null) {
        await ApiService.updateFaq(widget.faq!['id'].toString(), data);
      } else {
        await ApiService.storeFaq(data);
      }

      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("FAQ saved successfully")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(16)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(24))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.faq != null ? "Update FAQ" : "Create New FAQ",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.font(16))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.white, size: context.scale(20))),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.scale(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question *", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                  SizedBox(height: context.scale(8)),
                  TextField(
                    controller: _questionController,
                    style: TextStyle(fontSize: context.font(14)),
                    decoration: const InputDecoration(hintText: "Enter question"),
                  ),
                  SizedBox(height: context.scale(20)),
                  Text("Answer *", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                  SizedBox(height: context.scale(8)),
                  TextField(
                    controller: _answerController,
                    maxLines: 5,
                    style: TextStyle(fontSize: context.font(14)),
                    decoration: const InputDecoration(hintText: "Enter detailed answer"),
                  ),
                  SizedBox(height: context.scale(32)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, context.scale(54)),
                      ),
                      child: _isSaving
                          ? SizedBox(height: context.scale(20), width: context.scale(20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("SAVE FAQ", style: TextStyle(fontSize: context.font(16))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
