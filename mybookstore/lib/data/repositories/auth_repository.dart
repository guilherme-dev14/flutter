import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../models/store.dart';

class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  // Login
 Future<AuthModel> login(String username, String password) async {
  try {
    final response = await _apiService.post(
      'v1/auth',
      data: {
        'user': username,
        'password': password,
      },
      requiresAuth: false,
    );
    
    if (response.statusCode == 200) {
      final authData = AuthModel.fromJson(response.data);
      
      // Salvar dados de autenticação
      await _saveAuthData(authData);
      
      return authData;
    } else {
      throw Exception('Falha no login. Código: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro de login: $e');
    throw Exception('Falha na autenticação: ${e.toString()}');
  }
}
  // Validar/renovar token
  Future<String> validateToken(String refreshToken) async {
    final response = await _apiService.post(
      'v1/auth/validateToken',
      data: {'refreshToken': refreshToken},
      requiresAuth: false,
    );
    
    final data = response.data;
    final newToken = data['token'];
    final newRefreshToken = data['refreshToken'];
    
    // Atualizar tokens no armazenamento
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    await prefs.setString('refreshToken', newRefreshToken);
    
    return newToken;
  }
  
  // Salvar dados de autenticação no SharedPreferences
  Future<void> _saveAuthData(AuthModel authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authData.token);
    await prefs.setString('refreshToken', authData.refreshToken);
    await prefs.setInt('userId', authData.user.id!);
    await prefs.setString('userRole', authData.user.role!);
    await prefs.setInt('storeId', authData.store.id);
  }
  
  // Verificar se está logado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('storeId');
  }
  
  // Obter ID da loja atual
  Future<int?> getCurrentStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('storeId');
  }
  
  // Verificar se é admin
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole');
    return userRole == 'Admin';
  }
}