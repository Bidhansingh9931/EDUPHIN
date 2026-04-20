import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
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
    _editionController = TextEditingController(text: widget.book?.edition ?? "");
    _volumeController = TextEditingController(text: widget.book?.volume ?? "");
    _publisherController = TextEditingController(text: widget.book?.publisher ?? "");
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
        // Using librarian endpoints as manager usually has same or similar access for library management
        await ApiService.post('manager/books', data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book added successfully")));
      } else {
        await ApiService.post('manager/books/${widget.book!.id}/update', data);
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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.book == null ? "Add New Book" : "Edit Book"),
        centerTitle: false,
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
                      _buildSectionContainer(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: "Book Details",
                        children: [
                          _buildResponsiveRow(context, [
                            _buildInputField(context, "Title *", _titleController, required: true),
                            _buildInputField(context, "Author *", _authorController, required: true),
                          ]),
                          _buildResponsiveRow(context, [
                            _buildInputField(context, "Edition", _editionController),
                            _buildInputField(context, "Volume", _volumeController),
                          ]),
                          _buildResponsiveRow(context, [
                            _buildInputField(context, "Publisher", _publisherController),
                            _buildInputField(context, "Publication Year", _yearController, isNumber: true),
                          ]),
                        ],
                      ),
                      SizedBox(height: context.lg),
                      _buildSectionContainer(
                        context,
                        icon: Icons.inventory_2_outlined,
                        title: "Catalog & Inventory",
                        children: [
                          _buildResponsiveRow(context, [
                            _buildInputField(context, "ISBN", _isbnController),
                            _buildInputField(context, "Category", _categoryController),
                          ]),
                          _buildResponsiveRow(context, [
                            _buildInputField(context, "Language", _languageController),
                            _buildDropdownField(context, "Format", selectedFormat, ["Hardcover", "Paperback", "eBook"], (val) {
                              setState(() => selectedFormat = val!);
                            }),
                          ]),
                          _buildInputField(context, "Quantity *", _quantityController, isNumber: true, required: true),
                        ],
                      ),
                      SizedBox(height: context.xl),
                      Row(
                        children: [
                          if (widget.book == null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : () {
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
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text("RESET"),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(0, context.scale(48)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                                ),
                              ),
                            ),
                            SizedBox(width: context.md),
                          ],
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              icon: Icon(widget.book == null ? Icons.add_rounded : Icons.save_rounded),
                              label: Text(widget.book == null ? "ADD BOOK" : "UPDATE BOOK"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                minimumSize: Size(0, context.scale(48)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) return Column(children: children);
    return Row(
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
    );
  }

  Widget _buildSectionContainer(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.xs),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller, {bool required = false, bool isNumber = false}) {
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
            ),
          ),
          SizedBox(height: context.xs),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: required ? (val) => val == null || val.isEmpty ? "Required field" : null : null,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              hintText: "Enter $label",
              contentPadding: EdgeInsets.all(context.spacing),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
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
            ),
          ),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: context.spacing),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sm),
                borderSide: BorderSide.none,
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
