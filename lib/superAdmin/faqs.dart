import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

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
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final faqs = await ApiService.getFaqs();
      if (mounted) {
        setState(() {
          _faqs = faqs;
          _isLoading = false;
        });
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("FAQ Management"),
            Text("Manage frequently asked questions", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showFAQModal(),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Create New FAQ",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text("Total FAQs: ${_faqs.length}", 
                              style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ..._faqs.map((faq) => _buildFAQCard(faq)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    final theme = Theme.of(context);
    String formattedDate = faq['updated_at'] ?? faq['created_at'] ?? 'N/A';
    try {
       DateTime dt = DateTime.parse(formattedDate);
       formattedDate = DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(faq['question'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Updated: $formattedDate", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(faq['answer'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showFAQModal(faq: faq),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("EDIT"),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteFaq(faq['id'].toString()),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text("DELETE"),
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
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.faq != null ? "Update FAQ" : "Create New FAQ", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question *", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(hintText: "Enter question"),
                  ),
                  const SizedBox(height: 20),
                  Text("Answer *", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _answerController,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: "Enter detailed answer"),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("SAVE FAQ"),
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
