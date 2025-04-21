import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/book.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BookRepository bookRepository;
  final AuthRepository authRepository = AuthRepository();

  HomeBloc({required this.bookRepository}) : super(HomeLoading()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<ToggleAvailabilityEvent>(_onToggleAvailability);
    on<FilterBooksEvent>(_onFilterBooks); 
  }

  Future<void> _onLoadBooks(LoadBooksEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final storeId = await authRepository.getCurrentStoreId();
      final isAdmin = await authRepository.isAdmin();
      if (storeId == null) throw Exception('Loja não encontrada');
      final books = await bookRepository.searchBooks(storeId);
      emit(HomeLoaded(books: books, isAdmin: isAdmin));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onToggleAvailability(ToggleAvailabilityEvent event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      try {
        final storeId = await authRepository.getCurrentStoreId();
        if (storeId == null) throw Exception('Loja não encontrada');

        final updatedBook = event.book.copyWith(available: !event.book.available);
        await bookRepository.updateBook(storeId, event.book.id!, updatedBook);

        final updatedBooks = currentState.books.map((b) =>
          b.id == event.book.id ? updatedBook : b
        ).toList();

        emit(HomeLoaded(books: updatedBooks, isAdmin: currentState.isAdmin));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }
  Future<void> _onFilterBooks(
  FilterBooksEvent event,
  Emitter<HomeState> emit,
) async {
  emit(HomeLoading());

  try {
    final storeId = await authRepository.getCurrentStoreId();
    final isAdmin = await authRepository.isAdmin();

    final books = await bookRepository.searchBooks(
      storeId!,
      title: event.title,
      author: event.author,
      yearStart: event.yearStart,
      yearFinish: event.yearFinish,
      rating: event.rating,
      available: event.available,
    );

    emit(HomeLoaded(books: books, isAdmin: isAdmin));
  } catch (e) {
    emit(HomeError('Erro ao buscar livros com filtros: $e'));
  }
}
}
  
