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
  final String? query;
  final bool isLastPage;

  const LandmarksLoaded({
    required this.landmarks,
    required this.currentPage,
    this.city,
    this.kind,
    this.query,
    this.isLastPage = false,
  });

  @override
  List<Object?> get props => [landmarks, currentPage, city, kind, query, isLastPage];
}

class LandmarksEmpty extends LandmarksState {
  final String? city;
  final String? kind;
  final String? query;

  const LandmarksEmpty({this.city, this.kind, this.query});

  @override
  List<Object?> get props => [city, kind, query];
}

class LandmarksError extends LandmarksState {
  final String message;
  const LandmarksError({required this.message});

  @override
  List<Object?> get props => [message];
}