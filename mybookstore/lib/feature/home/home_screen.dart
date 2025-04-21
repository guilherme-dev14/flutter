import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/feature/employees/screens/employees_screen.dart';
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
    EmployeesScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Funcionários'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Livros'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Meu perfil'),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _showFilterDialog(BuildContext context) {
    String? titleFilter;
    String? authorFilter;
    RangeValues yearRange = RangeValues(1950, 2025);
    int selectedRating = 0;
    bool availableOnly = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtrar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Filtrar por título',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          titleFilter = value.isNotEmpty ? value : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Filtrar por autor',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          authorFilter = value.isNotEmpty ? value : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text('Ano de publicação', style: TextStyle(color: Colors.grey[700])),
                    RangeSlider(
                      values: yearRange,
                      min: 1900,
                      max: 2025,
                      divisions: 125,
                      labels: RangeLabels(
                        yearRange.start.round().toString(),
                        yearRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          yearRange = values;
                        });
                      },
                      activeColor: const Color(0xFF610BEF),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text('Avaliação', style: TextStyle(color: Colors.grey[700])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: index < selectedRating ? const Color(0xFF610BEF) : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: TextStyle(color: Colors.grey[700])),
                        Row(
                          children: [
                            Switch(
                              value: availableOnly,
                              onChanged: (value) {
                                setState(() {
                                  availableOnly = value;
                                });
                              },
                              activeColor: const Color(0xFF610BEF),
                            ),
                            const Text('Estoque'),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
  Navigator.pop(context);
  Future.microtask(() {
    final bloc = context.read<HomeBloc>();
    bloc.add(FilterBooksEvent(
      title: titleFilter,
      author: authorFilter,
      yearStart: yearRange.start.round(),
      yearFinish: yearRange.end.round(),
      rating: selectedRating > 0 ? selectedRating : null,
      available: availableOnly ? true : null,
    ));
  });
},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF610BEF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Filtrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/bool-semtext.svg',
                        height: 30,
                        color: const Color(0xFF610BEF),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
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
                    ],
                  ),
                  const SizedBox(height: 24),
                    Row(
                    children: [
                      Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Buscar',
                            ),
                          ),
                          ),
                        ],
                        ),
                      ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                      ),
                    ],
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