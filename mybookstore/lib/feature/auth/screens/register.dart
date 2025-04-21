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
import 'dart:math' as Math;
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
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 80,
  );

  if (image != null) {
    final File file = File(image.path);
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes); // ✅ sem prefixo MIME

    setState(() {
      _bannerImage = file;
      _base64Banner = base64;
    });

    print('Base64 válido: ${_base64Banner?.substring(0, 50)}...');
  }
}

  Future<void> _saveStore() async {

    if (!_formKey.currentState!.validate()) {
   
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {

      final adminName = _adminNameController.text.trim();
      final nameParts = adminName.split(' ');
      String username = '';
      
      if (nameParts.length >= 2) {

        username = '${nameParts[0].toLowerCase()}_${nameParts[nameParts.length - 1].toLowerCase()}';
      } else {

        username = nameParts[0].toLowerCase();
      }
      

      print('Username gerado: $username');
      
      final admin = UserModel(
        name: adminName,
       photo: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      username: username,
        password: _passwordController.text,
      );
      
      final bannerValue = _base64Banner ?? '';
      
      final store = StoreModel(
        id: 0, 
        name: _storeNameController.text,
        slogan: _sloganController.text,
        banner: bannerValue,
      );
      
      final storeRepository = StoreRepository();
      
      print('Enviando dados da loja: ${store.name}, ${store.slogan}');
      print('Enviando dados do admin: ${admin.name}, ${admin.username}');
      

      await storeRepository.createStore(store, admin);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loja cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, 
        );
      }
    } catch (e) {
      print('Erro ao cadastrar loja: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar loja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
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
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(16),
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
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: const TextStyle(color: Color(0xFF6E7191)),
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
                            labelStyle: const TextStyle(color: Color(0xFF6E7191)),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}