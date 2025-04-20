import '../services/api_service.dart';
import '../models/user.dart';

class EmployeeRepository {
  final ApiService _apiService;
  
  EmployeeRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  // Listar funcionários
  Future<List<UserModel>> getEmployees(int storeId) async {
    final response = await _apiService.get('v1/store/$storeId/employee');
    
    final List<dynamic> employeesData = response.data;
    return employeesData.map((data) => UserModel.fromJson(data)).toList();
  }
  
  // Adicionar funcionário
  Future<void> addEmployee(int storeId, UserModel employee) async {
    await _apiService.post(
      'v1/store/$storeId/employee',
      data: {
        'name': employee.name,
        'photo': employee.photo,
        'username': employee.username,
        'password': employee.password,
      },
    );
  }
  
  // Atualizar funcionário
  Future<void> updateEmployee(int storeId, int employeeId, UserModel employee) async {
    await _apiService.put(
      'v1/store/$storeId/employee/$employeeId',
      data: {
        'name': employee.name,
        'photo': employee.photo,
        'username': employee.username,
        'password': employee.password,
      },
    );
  }
  
  // Remover funcionário
  Future<void> deleteEmployee(int storeId, int employeeId) async {
    await _apiService.delete('v1/store/$storeId/employee/$employeeId');
  }
}