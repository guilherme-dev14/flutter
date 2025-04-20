// lib/feature/admin/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/data/models/book.dart';
import 'package:mybookstore/data/repositories/book_repository.dart';
import 'package:mybookstore/feature/auth/screens/book_detail_screen.dart';
import 'package:mybookstore/feature/auth/screens/employees_screen.dart';
import 'package:cached_network_image.dart';

class AdminHomeScreen extends StatefulWidget {
  final String userName;
  
  const AdminHomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final storeId = await RepositoryProvider.of<BookRepository>(context).getCurrentStoreId() ?? 1;
      final books = await RepositoryProvider.of<BookRepository>(context).searchBooks(storeId);
      
      setState(() {
        _books = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar livros: $e')),
      );
    }
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((book) => 
          book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              Row(
                children: [
                  const Icon(
                    Icons.book,
                    color: Color(0xFF610BEF),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${widget.userName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Filtrar busca',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Implementar filtro avançado
                      _showFilterOptions();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF610BEF)),
                  ),
                ),
                onChanged: _filterBooks,
              ),
              
              const SizedBox(height: 20),
              
              // Section title
              const Text(
                'Livros disponíveis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Grid of books
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBooks.isEmpty
                        ? const Center(child: Text('Nenhum livro encontrado'))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = _filteredBooks[index];
                              return _buildBookCard(book);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF610BEF),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmployeesScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Funcionários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF610BEF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Adicionar novo livro
        },
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: CachedNetworkImage(
                  imageUrl: book.cover,
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
            
            // Book info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < book.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filtrar busca',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Filtrar por ano'),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ano inicial',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ano final',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Text('Filtrar por autor'),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nome do autor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Filtrar por classificação'),
                  const SizedBox(height: 10),
                  Slider(
                    value: 3,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '3',
                    activeColor: const Color(0xFF610BEF),
                    onChanged: (value) {
                      // Implementar filtro por classificação
                    },
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: () {
                        Navigator.pop(context);
                        // Aplicar filtros
                      },
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}