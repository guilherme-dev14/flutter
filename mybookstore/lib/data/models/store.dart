class StoreModel {
  final int id;
  final String name;
  final String slogan;
  final String banner;


  StoreModel({
    required this.id,
    required this.name,
    required this.slogan,
    required this.banner,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      slogan: json['slogan'],
      banner: json['banner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slogan': slogan,
      'banner': banner,
    };
  }
}