import 'package:equatable/equatable.dart';
import '../../../data/models/book.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BookModel> books;
  final bool isAdmin;

  HomeLoaded({required this.books, required this.isAdmin});

  @override
  List<Object?> get props => [books, isAdmin];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}