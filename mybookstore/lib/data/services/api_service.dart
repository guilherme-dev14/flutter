import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api-flutter-prova.hml.sesisenai.org.br/';
  
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, String? token}) async {
    try {
      Map<String, dynamic> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, String? token}) async {
    try {
      Map<String, dynamic> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, String? token}) async {
    try {
      Map<String, dynamic> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path, {String? token}) async {
    try {
      Map<String, dynamic> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}