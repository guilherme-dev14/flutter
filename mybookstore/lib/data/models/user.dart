class UserModel {
  final int? id;
  final String name;
  final String? photo; 
  final String? role; 
  final String? username;
  final String? password; 

  UserModel({
    this.id,
    required this.name,
    this.photo,
    this.role,
    this.username,
    this.password,
  });

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    name: json['name'],
    photo: json['photo'] ?? 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    role: json['role'],
    username: json['username'] ?? '', 
  );
}

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'photo': photo,
      'username': username,
    };
    
  
    if (role != null) {
      map['role'] = role!;
    }
    
    return map;
  }

  Map<String, dynamic> toJsonForCreation() {
    return {
      'name': name,
      'photo': photo,
      'username': username,
      'password': password,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    final map = toJson();
    
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    
    return map;
  }
}