// lib/feature/admin/screens/add_employee_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/data/models/user.dart';
import 'package:mybookstore/data/repositories/employee_repository.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _photoBase64 = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _photoBase64 = base64Encode(imageBytes);
      });
    }
  }

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verificar se uma foto foi selecionada
    if (_photoBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma foto')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final employeeRepo = RepositoryProvider.of<EmployeeRepository>(context);
      final storeId = await employeeRepo.getCurrentStoreId() ?? 1;
      
      final newEmployee = UserModel(
        name: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        photo: _photoBase64,
        role: 'Employee', // Role padrão para novos funcionários
      );
      
      await employeeRepo.addEmployee(storeId, newEmployee);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário adicionado com sucesso!')),
      );
      
      Navigator.pop(context); // Voltar para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar funcionário: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 // Continuação da classe _AddEmployeeScreenState em add_employee_screen.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Novo Funcionário',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto do funcionário
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF610BEF),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: _photoBase64.isEmpty
                        ? const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 40,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.memory(
                              base64Decode(_photoBase64),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campo de nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o nome completo';
                    }
                    if (value.trim().length < 3) {
                      return 'O nome deve ter pelo menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Campo de usuário
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nome de usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o nome de usuário';
                    }
                    if (value.trim().length < 4) {
                      return 'O nome de usuário deve ter pelo menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Campo de senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe uma senha';
                    }
                    if (value.trim().length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Botão de salvar
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
                    onPressed: _isLoading ? null : _addEmployee,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}