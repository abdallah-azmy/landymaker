import 'package:equatable/equatable.dart';

abstract class LandingPagesState extends Equatable {
  const LandingPagesState();
  @override
  List<Object?> get props => [];
}

class LandingPagesInitial extends LandingPagesState {}

class LandingPagesLoading extends LandingPagesState {}

class LandingPagesLoaded extends LandingPagesState {
  final List<Map<String, dynamic>> pages;
  const LandingPagesLoaded({required this.pages});
  @override
  List<Object?> get props => [pages];
}

class LandingPagesFailure extends LandingPagesState {
  final String message;
  const LandingPagesFailure(this.message);
  @override
  List<Object?> get props => [message];
}
