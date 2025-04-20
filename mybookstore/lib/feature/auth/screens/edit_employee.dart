// lib/feature/admin/screens/edit_employee_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/data/models/user.dart';
import 'package:mybookstore/data/repositories/employee_repository.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditEmployeeScreen extends StatefulWidget {
  final UserModel employee;
  
  const EditEmployeeScreen({Key? key, required this.employee}) : super(key: key);

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  final _passwordController = TextEditingController(); // Opcional para atualização
  late String _photoBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _usernameController = TextEditingController(text: widget.employee.username);
    _photoBase64 = widget.employee.photo;
  }

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

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Verificar se uma foto está presente
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
      
      // Criar o modelo atualizado
      final updatedEmployee = UserModel(
        id: widget.employee.id,
        name: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        photo: _photoBase64,
        role: widget.employee.role,
      );
      
      await employeeRepo.updateEmployee(storeId, widget.employee.id!, updatedEmployee);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário atualizado com sucesso!')),
      );
      
      Navigator.pop(context); // Voltar para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar funcionário: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Editar Funcionário',
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _photoBase64.isNotEmpty
                          ? Image.memory(
                              base64Decode(_photoBase64),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 60,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
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
                
                // Campo de senha (opcional para atualização)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova senha (opcional)',
                    hintText: 'Deixe em branco para manter a senha atual',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
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
                    onPressed: _isLoading ? null : _updateEmployee,
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