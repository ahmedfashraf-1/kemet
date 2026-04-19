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
  final String message;

  ProfileError([this.message = 'Failed to load profile data']);
}

class ProfileLoggedOut extends ProfileState {}