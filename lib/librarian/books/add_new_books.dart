import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';

class AddNewBookPage extends StatefulWidget {
  final Book? book;
  const AddNewBookPage({super.key, this.book});

  @override
  State<AddNewBookPage> createState() => _AddNewBookPageState();
}

class _AddNewBookPageState extends State<AddNewBookPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _editionController;
  late TextEditingController _volumeController;
  late TextEditingController _publisherController;
  late TextEditingController _yearController;
  late TextEditingController _isbnController;
  late TextEditingController _categoryController;
  late TextEditingController _languageController;
  late TextEditingController _quantityController;

  String selectedFormat = "Hardcover";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? "");
    _authorController = TextEditingController(text: widget.book?.author ?? "");
    _editionController = TextEditingController(text: ""); 
    _volumeController = TextEditingController(text: ""); 
    _publisherController = TextEditingController(text: ""); 
    _yearController = TextEditingController(text: widget.book?.publicationYear ?? "");
    _isbnController = TextEditingController(text: widget.book?.isbn ?? "");
    _categoryController = TextEditingController(text: widget.book?.category ?? "");
    _languageController = TextEditingController(text: widget.book?.language ?? "English");
    _quantityController = TextEditingController(text: widget.book?.quantity.toString() ?? "1");
    
    if (widget.book?.format != null) {
      selectedFormat = widget.book!.format!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _editionController.dispose();
    _volumeController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _categoryController.dispose();
    _languageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'author': _authorController.text,
      'publisher': _publisherController.text,
      'publication_year': _yearController.text,
      'edition': _editionController.text,
      'volume': _volumeController.text,
      'isbn': _isbnController.text,
      'category': _categoryController.text,
      'language': _languageController.text,
      'format': selectedFormat,
      'quantity': _quantityController.text,
    };

    try {
      if (widget.book == null) {
        await ApiService.createLibrarianBook(data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book added successfully")));
      } else {
        await ApiService.updateLibrarianBook(widget.book!.id.toString(), data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book updated successfully")));
      }
      if (mounted) Navigator.pop(context, true);
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
        title: Text(widget.book == null ? "Add New Book" : "Edit Book"),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      buildSectionContainer(
                        context,
                        icon: Icons.info_outline,
                        title: "Book Details",
                        subtitle: "Core information about the resource.",
                        children: [
                          _buildResponsiveRow(context, [
                            buildInputField(context, "Title *", _titleController, required: true),
                            buildInputField(context, "Author *", _authorController, required: true),
                          ]),
                          _buildResponsiveRow(context, [
                            buildInputField(context, "Edition", _editionController),
                            buildInputField(context, "Volume", _volumeController),
                          ]),
                          _buildResponsiveRow(context, [
                            buildInputField(context, "Publisher", _publisherController),
                            buildInputField(context, "Year", _yearController, isNumber: true),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 24),

                      buildSectionContainer(
                        context,
                        icon: Icons.sell_outlined,
                        title: "Catalog & Inventory",
                        children: [
                          _buildResponsiveRow(context, [
                            buildInputField(context, "ISBN", _isbnController),
                            buildInputField(context, "Category", _categoryController),
                          ]),
                          _buildResponsiveRow(context, [
                            buildInputField(context, "Language", _languageController),
                            buildDropdownField(context, "Format", selectedFormat, ["Hardcover", "Paperback", "eBook"], (val) {
                              setState(() => selectedFormat = val!);
                            }),
                          ]),
                          buildInputField(context, "Quantity *", _quantityController, isNumber: true, required: true),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              child: Text(widget.book == null ? "ADD BOOK" : "UPDATE BOOK"),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (widget.book == null)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () {
                                  _formKey.currentState?.reset();
                                  _titleController.clear();
                                  _authorController.clear();
                                  _editionController.clear();
                                  _volumeController.clear();
                                  _publisherController.clear();
                                  _yearController.clear();
                                  _isbnController.clear();
                                  _categoryController.clear();
                                  _languageController.text = "English";
                                  _quantityController.text = "1";
                                  setState(() => selectedFormat = "Hardcover");
                                },
                                child: const Text("RESET"),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
        ],
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

  Widget buildSectionContainer(BuildContext context, {required IconData icon, required String title, String? subtitle, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(BuildContext context, String label, TextEditingController controller, {bool required = false, bool isNumber = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: required ? (val) => val == null || val.isEmpty ? "Required" : null : null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
