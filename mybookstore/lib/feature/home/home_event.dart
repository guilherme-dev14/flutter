import 'package:equatable/equatable.dart';
import '../../../data/models/book.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBooksEvent extends HomeEvent {}

class ToggleAvailabilityEvent extends HomeEvent {
  final BookModel book;

  ToggleAvailabilityEvent(this.book);

  @override
  List<Object?> get props => [book];
}
class FilterBooksEvent extends HomeEvent {
  final String? title;
  final String? author;
  final int? yearStart;
  final int? yearFinish;
  final int? rating;
  final bool? available;

  FilterBooksEvent({
    this.title,
    this.author,
    this.yearStart,
    this.yearFinish,
    this.rating,
    this.available,
  });

  @override
  List<Object?> get props => [title, author, yearStart, yearFinish, rating, available];
}