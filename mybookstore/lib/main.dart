import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/data/repositories/auth_repository.dart';
import 'package:mybookstore/data/services/api_service.dart';
import 'package:mybookstore/feature/auth/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(
          create: (context) => ApiService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MyBookStore',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF610BEF),
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}