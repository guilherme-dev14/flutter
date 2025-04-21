import '../services/api_service.dart';
import '../models/book.dart';

class BookRepository {
  final ApiService _apiService;
  
  BookRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
Future<List<BookModel>> searchBooks(
    int storeId, {
    int limit = 20,
    int offset = 0,
    String? title,
    String? author,
    int? yearStart,
    int? yearFinish,
    int? rating,
    bool? available,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (yearStart != null) 'year-start': yearStart,
      if (yearFinish != null) 'year-finish': yearFinish,
      if (rating != null) 'rating': rating,
      if (available != null) 'available': available,
    };

    final response = await _apiService.get('v1/store/$storeId/book', queryParameters: queryParams);
    final data = response.data as List;
    return data.map((item) => BookModel.fromJson(item)).toList();
  }
  
  Future<BookModel> getBook(int storeId, int bookId) async {
    final response = await _apiService.get('v1/store/$storeId/book/$bookId');
    return BookModel.fromJson(response.data);
  }
  
  Future<void> addBook(int storeId, BookModel book) async {
    await _apiService.post(
      'v1/store/$storeId/book',
      data: {
        'cover': book.cover,
        'title': book.title,
        'author': book.author,
        'synopsis': book.synopsis,
        'year': book.year,
        'rating': book.rating,
        'available': book.available,
      },
    );
  }
  
  Future<void> updateBook(int storeId, int bookId, BookModel book) async {
    await _apiService.put(
      'v1/store/$storeId/book/$bookId',
      data: {
        'cover': book.cover,
        'title': book.title,
        'author': book.author,
        'synopsis': book.synopsis,
        'year': book.year,
        'rating': book.rating,
        'available': book.available,
      },
    );
  }
  
  Future<void> deleteBook(int storeId, int bookId) async {
    await _apiService.delete('v1/store/$storeId/book/$bookId');
  }
}