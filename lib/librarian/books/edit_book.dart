import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';

class EditBookPage extends StatefulWidget {
  final Book book;
  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
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
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _editionController = TextEditingController(text: widget.book.edition ?? "");
    _volumeController = TextEditingController(text: widget.book.volume ?? "");
    _publisherController = TextEditingController(text: widget.book.publisher ?? "");
    _yearController = TextEditingController(text: widget.book.publicationYear ?? "");
    _isbnController = TextEditingController(text: widget.book.isbn ?? "");
    _categoryController = TextEditingController(text: widget.book.category ?? "");
    _languageController = TextEditingController(text: widget.book.language ?? "English");
    _quantityController = TextEditingController(text: widget.book.quantity.toString());

    if (widget.book.format != null) {
      selectedFormat = widget.book.format!;
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

    // Prepare data map with all required fields
    final Map<String, dynamic> data = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'publisher': _publisherController.text.trim().isEmpty ? null : _publisherController.text.trim(),
      'publication_year': _yearController.text.trim(),
      'edition': _editionController.text.trim().isEmpty ? null : _editionController.text.trim(),
      'volume': _volumeController.text.trim().isEmpty ? null : _volumeController.text.trim(),
      'isbn': _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
      'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      'language': _languageController.text.trim().isEmpty ? "English" : _languageController.text.trim(),
      'format': selectedFormat,
      'quantity': int.tryParse(_quantityController.text.trim()) ?? widget.book.quantity,
    };

    try {
      await ApiService.updateLibrarianBook(widget.book.id.toString(), data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book updated successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating book: $e"), backgroundColor: Colors.red),
        );
      }
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
        title: const Text("Edit Book"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                        title: "Book Information",
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
                      SizedBox(height: context.md),
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
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text("UPDATE BOOK"),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: context.md),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          ),
                        ),
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
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.xs),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: required ? (val) => val == null || val.isEmpty ? "Required field" : null : null,
            style: TextStyle(fontSize: context.font(14)),
            decoration: InputDecoration(
              hintText: "Enter $label",
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.all(context.scale(12)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: colorScheme.primary, width: 1),
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: context.font(14))))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
