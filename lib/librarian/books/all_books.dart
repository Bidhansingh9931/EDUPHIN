import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'add_new_books.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({super.key});

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  bool _isLoading = true;
  List<Book> _books = [];
  int _currentPage = 1;
  int _totalPages = 1;

  final Map<String, String> _filters = {
    'title': '',
    'author': '',
    'isbn': '',
    'category': 'All',
    'language': 'All',
    'format': 'All',
    'year': 'All',
    'availability': 'All',
  };

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final pagination = await ApiService.getLibrarianBooks(_filters, _currentPage);
      if (!mounted) return;
      setState(() {
        _books = pagination.books;
        _totalPages = pagination.lastPage;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteBook(int bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: const Text("Are you sure you want to delete this book? This action is permanent."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteLibrarianBook(bookId.toString());
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book deleted successfully")));
        _fetchBooks();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Books Collection"),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewBookPage()),
              );
              if (result == true) _fetchBooks();
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add Book",
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBooks,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        _buildFilterCard(context),
                        const SizedBox(height: 24),
                        if (_books.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text("No books found matching your criteria.", style: TextStyle(color: theme.hintColor)),
                              ],
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.isTablet ? 2 : 1,
                              mainAxisExtent: 220,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _books.length,
                            itemBuilder: (context, index) => _buildBookCard(context, _books[index]),
                          ),
                        const SizedBox(height: 24),
                        _buildPagination(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => _filters['title'] = val,
                    decoration: const InputDecoration(hintText: "Title", prefixIcon: Icon(Icons.book, size: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) => _filters['author'] = val,
                    decoration: const InputDecoration(hintText: "Author", prefixIcon: Icon(Icons.person, size: 18)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _fetchBooks, child: const Text("FILTER"))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filters.updateAll((k, v) => k == 'category' || k == 'language' || k == 'format' || k == 'year' || k == 'availability' ? 'All' : '');
                      _currentPage = 1;
                    });
                    _fetchBooks();
                  },
                  child: const Text("RESET"),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                _availabilityBadge(book.availableCopies),
              ],
            ),
            Text("by ${book.author}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            const Divider(height: 24),
            _infoRow(context, "ISBN", book.isbn ?? "N/A"),
            _infoRow(context, "Category", book.category ?? "N/A"),
            _infoRow(context, "Copies", "${book.availableCopies} of ${book.quantity}"),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddNewBookPage(book: book)),
                    );
                    if (result == true) _fetchBooks();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  onPressed: () => _deleteBook(book.id),
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _availabilityBadge(int count) {
    final isAvailable = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.5)),
      ),
      child: Text(isAvailable ? "AVAILABLE" : "OUT OF STOCK", 
        style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1 ? () {
            setState(() => _currentPage--);
            _fetchBooks();
          } : null,
        ),
        Text("Page $_currentPage of $_totalPages", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalPages ? () {
            setState(() => _currentPage++);
            _fetchBooks();
          } : null,
        ),
      ],
    );
  }
}
