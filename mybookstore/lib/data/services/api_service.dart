import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://api-flutter-prova.hml.sesisenai.org.br/';
  
  final Dio _dio;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  Future<Options> _getOptions({Options? options}) async {
    final token = await _getToken();
    options ??= Options();
    
    if (token != null) {
      options.headers ??= {};
      options.headers!['Authorization'] = 'Bearer $token';
    }
    
    return options;
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = requiresAuth ? await _getOptions(options: options) : options;
      return await _dio.get<T>(path, queryParameters: queryParameters, options: opts);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

Future<Response<T>> post<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  bool requiresAuth = true,
}) async {
  try {
    print('Enviando requisição POST para: ${baseUrl + path}');
    print('Dados: $data');
    
    options ??= Options();
    options.headers ??= {};
    options.headers!['Content-Type'] = 'application/json';
    
    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        options.headers!['Authorization'] = 'Bearer $token';
      }
    }
    
    print('Headers da requisição: ${options.headers}');
    
    final response = await _dio.post<T>(
      path, 
      data: data, 
      queryParameters: queryParameters, 
      options: options
    );
    
    print('Resposta recebida: Código ${response.statusCode}');
    print('Resposta body: ${response.data}');
    
    return response;
  } catch (e) {
    print('Erro detalhado na requisição POST:');
    print('URL: ${baseUrl + path}');
    print('Dados: $data');
    if (e is DioException) {
      print('Tipo de erro: ${e.type}');
      print('Mensagem: ${e.message}');
      print('Código: ${e.response?.statusCode}');
      print('Resposta: ${e.response?.data}');
    } else {
      print('Erro não-Dio: $e');
    }
    _handleError(e);
    rethrow;
  }
}

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = requiresAuth ? await _getOptions(options: options) : options;
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: opts);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      final opts = requiresAuth ? await _getOptions(options: options) : options;
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: opts);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  void _handleError(dynamic error) {
    if (error is DioException) {
      print('Erro na API: ${error.message}');
      print('Status code: ${error.response?.statusCode}');
      print('Resposta: ${error.response?.data}');
    } else {
      print('Erro desconhecido: $error');
    }
  }
}