import 'package:flutter/material.dart';
import '../../../data/models/book.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<BookModel> _books = [];
  bool _loading = true;
  String _error = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final storeId = await AuthRepository().getCurrentStoreId();
      final isAdmin = await AuthRepository().isAdmin();
      final books = await BookRepository().searchBooks(storeId!);
      setState(() {
        _books = books;
        _isAdmin = isAdmin;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _navigateToAddBook() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (result == true) {
      _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livros', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: _books.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: _books[index],
                        isAdmin: _isAdmin,
                        onTap: () {

                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToAddBook,
              backgroundColor: const Color(0xFF610BEF),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}