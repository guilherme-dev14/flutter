import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import './register.dart'; // Importe a tela para onde irá após o login
import '../../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navegar para a tela principal após login bem-sucedido
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          } else if (state is AuthError) {
            // Mostrar mensagem de erro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo SVG
                      SvgPicture.asset(
                        'assets/icons/book_logo.svg',
                        height: 120,
                        color: const Color(0xFF610BEF),
                      ),
                      const SizedBox(height: 46),

                      // Campo de Email/Usuário
                      TextFormField(
                        controller: _userController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Usuário',
                          hintText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _userController.clear();
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu usuário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: '********',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          // Validar regras de senha
                          if (value.length < 6) {
                            return 'A senha deve ter mais de 6 caracteres';
                          }
                       //   if (value.length > 10) {
                        //    return 'A senha deve ter menos de 10 caracteres';
                        //  }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'A senha deve conter pelo menos uma letra maiúscula';
                          }
                          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'A senha deve conter pelo menos um caractere especial';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 48),

                      // Botão de Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null // Desabilitar enquanto carrega
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final usuario = _userController.text;
                                    final senha = _passwordController.text;
                                    
                                    // Disparar evento de login
                                    context.read<AuthBloc>().add(
                                      LoginEvent(
                                        username: usuario,
                                        password: senha,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF610BEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link para cadastro
                      TextButton(
                        onPressed: state is AuthLoading
                            ? null // Desabilitar enquanto carrega
                            : () {
                                // Navegar para tela de criar loja
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(builder: (_) => const CreateStoreScreen()),
                                // );
                              },
                        child: const Text(
                          'Cadastre sua loja',
                          style: TextStyle(
                            color: Color(0xFF610BEF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}