import 'package:mybookstore/data/models/store.dart';
import 'package:mybookstore/data/models/user.dart';

class AuthModel {
  final String token;
  final String refreshToken;
  final UserModel user;
  final StoreModel store;

  AuthModel({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.store,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['user']),
      store: StoreModel.fromJson(json['store']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'store': store.toJson(),
    };
  }
}

// Modelo para login
class LoginRequest {
  final String user;
  final String password;

  LoginRequest({
    required this.user,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'password': password,
    };
  }
}
class ValidateTokenRequest {
  final String refreshToken;

  ValidateTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class ValidateTokenResponse {
  final String token;
  final String refreshToken;

  ValidateTokenResponse({
    required this.token,
    required this.refreshToken,
  });

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) {
    return ValidateTokenResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}