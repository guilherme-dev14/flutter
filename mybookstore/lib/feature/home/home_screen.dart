// lib/features/home/screens/home_tab_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/book.dart';
import './home_bloc.dart';
import './home_event.dart';
import './home_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = '';

  final _tabs = const [
    _HomeView(),
    Center(child: Text('Funcionários')),
    Center(child: Text('Livros')),
    Center(child: Text('Meu perfil')),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await AuthRepository().getCurrentUserName();
    setState(() => _userName = name);
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _tabs[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF610BEF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Funcionários'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Livros'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Meu perfil'),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(bookRepository: BookRepository())..add(LoadBooksEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                     SvgPicture.asset(
                        'assets/icons/book_logo.svg',
                        height: 120,
                        color: const Color(0xFF610BEF),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Olá, ',
                        style: TextStyle(fontSize: 20),
                      ),
                      FutureBuilder<String>(
                        future: AuthRepository().getCurrentUserName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            final name = snapshot.data ?? 'Usuário';
                            return Text(
                              '$name 👋',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Campo de busca
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar',
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Todos os livros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                      children: state.books.map((book) => _BookCard(book: book)).toList(),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is HomeError) {
            return Center(child: Text('Erro: ${state.message}'));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // navegar para detalhes do livro
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF2F2F7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.memory(
                base64Decode(book.cover),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(book.author, style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(book.rating.toString()),
                    ],
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
