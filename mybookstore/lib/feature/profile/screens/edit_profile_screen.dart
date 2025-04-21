import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/store.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/store_repository.dart';
import '../../../data/repositories/employee_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storeNameController = TextEditingController();
  final _sloganController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late int storeId;
  late int userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getInt('storeId')!;
    userId = prefs.getInt('userId')!;

    final store = await StoreRepository().getStore(storeId);
    final userName = prefs.getString('userName') ?? '';

    setState(() {
      _storeNameController.text = store.name;
      _sloganController.text = store.slogan;
      _userNameController.text = userName;
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    final storeRepo = StoreRepository();
    final employeeRepo = EmployeeRepository();

    final store = StoreModel(
      id: storeId,
      name: _storeNameController.text,
      slogan: _sloganController.text,
      banner: '',
    );

    final user = UserModel(
      id: userId,
      name: _userNameController.text,
      photo: '',
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    await storeRepo.updateStore(storeId, store);
    await employeeRepo.updateEmployee(storeId, userId, user);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF610BEF),
                child: Text(
                  _getInitials(_userNameController.text),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(height: 24),
              _buildField('Nome da loja', _storeNameController),
              const SizedBox(height: 16),
              _buildField('Slogan da loja', _sloganController),
              const SizedBox(height: 16),
              _buildField('Nome do usuário', _userNameController),
              const SizedBox(height: 16),
              _buildPasswordField('Senha', _passwordController, true),
              const SizedBox(height: 16),
              _buildPasswordField('Repetir senha', _confirmPasswordController, false),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF610BEF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F2F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F2F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword ? (_obscurePassword ? Icons.visibility_off : Icons.visibility) :
                         (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts.first[0].toUpperCase();
  }
}
