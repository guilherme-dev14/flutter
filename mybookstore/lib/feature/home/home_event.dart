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
