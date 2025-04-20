import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../../data/models/store.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/store_repository.dart';
import '../../auth/screens/login.dart';

class RegisterStoreScreen extends StatefulWidget {
  const RegisterStoreScreen({super.key});

  @override
  State<RegisterStoreScreen> createState() => _RegisterStoreScreenState();
}

class _RegisterStoreScreenState extends State<RegisterStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _storeNameController = TextEditingController();
  final _sloganController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  
  File? _bannerImage;
  String? _base64Banner;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _storeNameController.dispose();
    _sloganController.dispose();
    _adminNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _pickBanner() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final File file = File(image.path);
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      
      setState(() {
        _bannerImage = file;
        _base64Banner = base64;
      });
    }
  }
  
  Future<void> _saveStore() async {
    if (_formKey.currentState!.validate() && _base64Banner != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Criar modelos
        final admin = UserModel(
          name: _adminNameController.text,
          photo: '', 
          username: _adminNameController.text.toLowerCase().replaceAll(' ', '.'),
          password: _passwordController.text,
        );
        
        final store = StoreModel(
          id: 0, // O ID será atribuído pelo servidor
          name: _storeNameController.text,
          slogan: _sloganController.text,
          banner: _base64Banner!,
        );
        
        // Obter o repositório
        final storeRepository = RepositoryProvider.of<StoreRepository>(context);
        
        // Criar a loja
        final auth = await storeRepository.createStore(store, admin);
        
        // Navegar para a tela de login após o sucesso
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loja cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar loja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0xFF610BEF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      'Cadastrar loja',
                        style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14142B),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Logo e título
              Column(
                children: [
                  SvgPicture.asset(
                    'assets/icons/book_logo.svg',
                    height: 120,
                    color: const Color(0xFF610BEF),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Formulário
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nome da loja
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16), // Aumentado para bordas mais arredondadas
                        ),
                        child: TextFormField(
                          controller: _storeNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da loja',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, informe o nome da loja';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Slogan
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _sloganController,
                          decoration: const InputDecoration(
                            labelText: 'Slogan da loja',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, informe o slogan da loja';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Banner
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: _pickBanner,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _bannerImage != null 
                                      ? 'Imagem selecionada'
                                      : 'Banner da loja',
                                      
                                  style: TextStyle(
                                    color: _bannerImage != null 
                                        ? Colors.black 
                                        : Colors.grey[600],
                                        
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), 
                      ),
                      const SizedBox(height: 16),
                      
                      // Nome do administrador
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _adminNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do administrador',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, informe o nome do administrador';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                       Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario do administrador',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, informe o username do administrador';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Senha
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
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
                            if (value.length > 10) {
                             return 'A senha deve ter menos de 10 caracteres';
                            }
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                              return 'A senha deve conter pelo menos uma letra maiúscula';
                            }
                            if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                              return 'A senha deve conter pelo menos um caractere especial';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirmar senha
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Repetir senha',
                            labelStyle: TextStyle(color: Color(0xFF6E7191)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme a senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botão Salvar
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF610BEF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Salvar',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}