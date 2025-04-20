// lib/feature/admin/screens/book_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:mybookstore/data/models/book.dart';
import 'package:mybookstore/data/repositories/book_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image.dart';

class BookDetailScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late BookModel _book;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _isAvailable = widget.book.available;
  }

  Future<void> _updateBook() async {
    try {
      final storeId = await RepositoryProvider.of<BookRepository>(context).getCurrentStoreId() ?? 1;
      
      // Crie uma cópia do livro com a disponibilidade atualizada
      final updatedBook = _book.copyWith(available: _isAvailable);
      
      await RepositoryProvider.of<BookRepository>(context).updateBook(
        storeId,
        _book.id!,
        updatedBook,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro atualizado com sucesso!')),
      );
      
      setState(() {
        _book = updatedBook;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar livro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Implementar edição do livro
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Book cover
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _book.cover,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Book title
              Text(
                _book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Author
              Text(
                _book.author,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < _book.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${_book.rating}/5',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Year
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Publicado em ${_book.year}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Synopsis
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sinopse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _book.synopsis,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Availability toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Disponível para empréstimo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _isAvailable,
                    activeColor: const Color(0xFF610BEF),
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF610BEF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _updateBook,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}