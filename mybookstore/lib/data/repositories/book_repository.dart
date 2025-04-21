import '../services/api_service.dart';
import '../models/book.dart';

class BookRepository {
  final ApiService _apiService;
  
  BookRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  

  Future<List<BookModel>> searchBooks(
    int storeId, {
    int? limit,
    int? offset,
    String? author,
    String? title,
    int? yearStart,
    int? yearFinish,
    int? rating,
    bool? available,
  }) async {
    final Map<String, dynamic> queryParams = {};
    
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (author != null) queryParams['author'] = author;
    if (title != null) queryParams['title'] = title;
    if (yearStart != null) queryParams['year-start'] = yearStart.toString();
    if (yearFinish != null) queryParams['year-finish'] = yearFinish.toString();
    if (rating != null) queryParams['rating'] = rating.toString();
    if (available != null) queryParams['available'] = available.toString();
    
    final response = await _apiService.get(
      'v1/store/$storeId/book',
      queryParameters: queryParams,
    );
    
    final List<dynamic> booksData = response.data;
    return booksData.map((data) => BookModel.fromJson(data)).toList();
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