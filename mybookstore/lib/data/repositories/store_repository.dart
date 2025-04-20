import '../services/api_service.dart';
import '../models/store.dart';
import '../models/user.dart';
import '../models/auth.dart';

class StoreRepository {
  final ApiService _apiService;
  
  StoreRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  // Criar nova loja com admin
  Future<AuthModel> createStore(StoreModel store, UserModel admin) async {
    final response = await _apiService.post(
      'v1/store',
      data: {
        'name': store.name,
        'slogan': store.slogan,
        'banner': store.banner,
        'admin': {
          'name': admin.name,
          'photo': admin.photo,
          'username': admin.username,
          'password': admin.password,
        },
      },
      requiresAuth: false,
    );
    
    return AuthModel.fromJson(response.data);
  }
  
  // Obter detalhes da loja
  Future<StoreModel> getStore(int storeId) async {
    final response = await _apiService.get('v1/store/$storeId');
    return StoreModel.fromJson(response.data);
  }
  
  // Atualizar loja
  Future<void> updateStore(int storeId, StoreModel store) async {
    await _apiService.put(
      'v1/store/$storeId',
      data: {
        'name': store.name,
        'slogan': store.slogan,
        'banner': store.banner,
      },
    );
  }
}