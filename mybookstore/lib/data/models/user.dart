class User {
  final int id;
  final String name;
  final String photo;
  final String? username;
  final String role;
  
User({
    required this.id,
    required this.name,
    required this.photo,
    required this.role,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      role: json['role'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'role': role,
      'username': username,
    };
  }
}