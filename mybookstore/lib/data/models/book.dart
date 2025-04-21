class BookModel {
  final int? id;
  final String cover; 
  final String title;
  final String author;
  final String synopsis;
  final int year;
  final int rating;
  final bool available;

  BookModel({
    this.id,
    required this.cover,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.year,
    required this.rating,
    required this.available,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      cover: json['cover'],
      title: json['title'],
      author: json['author'],
      synopsis: json['synopsis'],
      year: json['year'],
      rating: json['rating'],
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'cover': cover,
      'title': title,
      'author': author,
      'synopsis': synopsis,
      'year': year,
      'rating': rating,
      'available': available,
    };
    

    if (id != null) {
      map['id'] = id!;
    }
    
    return map;
  }

  BookModel copyWith({
    int? id,
    String? cover,
    String? title,
    String? author,
    String? synopsis,
    int? year,
    int? rating,
    bool? available,
  }) {
    return BookModel(
      id: id ?? this.id,
      cover: cover ?? this.cover,
      title: title ?? this.title,
      author: author ?? this.author,
      synopsis: synopsis ?? this.synopsis,
      year: year ?? this.year,
      rating: rating ?? this.rating,
      available: available ?? this.available,
    );
  }
}

class BookSearchParams {
  final int? limit;
  final int? offset;
  final String? author;
  final String? title;
  final int? yearStart;
  final int? yearFinish;
  final int? rating;
  final bool? available;

  BookSearchParams({
    this.limit,
    this.offset,
    this.author,
    this.title,
    this.yearStart,
    this.yearFinish,
    this.rating,
    this.available,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    
    if (limit != null) map['limit'] = limit;
    if (offset != null) map['offset'] = offset;
    if (author != null) map['author'] = author;
    if (title != null) map['title'] = title;
    if (yearStart != null) map['year-start'] = yearStart;
    if (yearFinish != null) map['year-finish'] = yearFinish;
    if (rating != null) map['rating'] = rating;
    if (available != null) map['available'] = available;
    
    return map;
  }
}