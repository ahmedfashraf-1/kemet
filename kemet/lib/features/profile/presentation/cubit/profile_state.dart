part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final List<Landmark> recentTrips;
  final List<Review> reviews;
  final List<Favorite> favoritePlaces;

  ProfileLoaded({
    required this.profile,
    required this.recentTrips,
    required this.reviews,
    required this.favoritePlaces,
  });
}

class ProfileError extends ProfileState {
  String? get message => null;
  // final String message;
  // ProfileError(this.message);
}

class ProfileLoggedOut extends ProfileState {}