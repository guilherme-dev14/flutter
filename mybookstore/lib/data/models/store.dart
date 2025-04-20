import 'package:mybookstore/data/models/user.dart';
class StoreModel {
  final int id;
  final String name;
  final String slogan;
  final String banner; // Base64 da imagem

  StoreModel({
    required this.id,
    required this.name,
    required this.slogan,
    required this.banner,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? json['idStore'],
      name: json['name'],
      slogan: json['slogan'],
      banner: json['banner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slogan': slogan,
      'banner': banner,
    };
  }

  Map<String, dynamic> toJsonWithAdmin(UserModel admin) {
    return {
      'name': name,
      'slogan': slogan,
      'banner': banner,
      'admin': admin.toJsonForCreation(),
    };
  }
}