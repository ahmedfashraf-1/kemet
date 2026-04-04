part of 'landmarks_cubit.dart';

abstract class LandmarksState extends Equatable {
  const LandmarksState();

  @override
  List<Object?> get props => [];
}

class LandmarksInitial extends LandmarksState {}

class LandmarksLoading extends LandmarksState {}

class LandmarksLoaded extends LandmarksState {
  final List<Landmark> landmarks;
  final int currentPage;
  final String? city;
  final String? kind;
  final bool isLastPage;
  final String? query;

  const LandmarksLoaded({
    required this.landmarks,
    required this.currentPage,
    this.city,
    this.kind,
    this.isLastPage = false,
    this.query
  });

  @override
  List<Object?> get props => [landmarks, currentPage, city, kind, isLastPage];
}

class LandmarksError extends LandmarksState {
  final String message;
  const LandmarksError({required this.message});

  @override
  List<Object?> get props => [message];
}