// import 'package:get_it/get_it.dart';
// import 'package:kemet/features/profile/data/repository/profile_repository_impl.dart';
// import 'package:kemet/features/profile/domain/usecases/profile_usecases.dart';
// import 'package:kemet/features/profile/domain/repositories/profile_repository.dart';
// import 'package:kemet/features/profile/presentation/cubit/profile_cubit.dart';

// final getIt = GetIt.instance;

// void setupServiceLocator() {
//   // Repository
//   getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());

//   // UseCases
//   getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
//   getIt.registerLazySingleton(() => GetRecentPlacesUseCase(getIt()));
//   getIt.registerLazySingleton(() => GetMyReviewsUseCase(getIt()));
//   getIt.registerLazySingleton(() => GetFavoritePlacesUseCase(getIt()));
//   getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

//   // Cubit
//   getIt.registerFactory(() => ProfileCubit(
//         getProfile: getIt(),
//         getRecentTrips: getIt(),
//         getMyReviews: getIt(),
//         getFavoritePlaces: getIt(),
//         logoutUseCase: getIt(),
//       ));
// }

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:kemet/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:kemet/features/profile/data/repository/profile_repository_impl.dart';
import 'package:kemet/features/profile/domain/repositories/profile_repository.dart';
import 'package:kemet/features/profile/domain/usecases/profile_usecases.dart';
import 'package:kemet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:http/http.dart'; // Client هنا
import 'package:http/http.dart' as http;


final getIt = GetIt.instance;


void setupProfileDi() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  
  // ── DataSource
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
  () => ProfileRemoteDataSourceImpl(
    firestore: getIt<FirebaseFirestore>(),
    client: getIt<http.Client>(),
  ),
);

  // ── Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: getIt()),
  );

  // ── Use Cases
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRecentPlacesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyReviewsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFavoritePlacesUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // ── Cubit  ← registerFactory عشان كل مرة بيتفتح الـ screen يبقى fresh instance
  getIt.registerFactory(
    () => ProfileCubit(
      getProfile: getIt(),
      getRecentTrips: getIt(),
      getMyReviews: getIt(),
      getFavoritePlaces: getIt(),
      logoutUseCase: getIt(),
    ),
  );
}