import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kemet/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_local_data_source.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_remote_data_source.dart';
import 'package:kemet/features/landmarks/data/repositories/landmarks_repository_impl.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/splash/presentation/screens/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KemetApp extends StatelessWidget {
  final AppRouter appRouter;
  final SharedPreferences sharedPreferences;

  const KemetApp({super.key, required this.appRouter, required this.sharedPreferences,});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(AuthRemoteDatasourceImpl()),
        ),

        RepositoryProvider<LandmarksRepository>(
          create: (context) => LandmarksRepositoryImpl(
            remoteDataSource: LandmarkRemoteDataSourceImpl(client: http.Client()),
            localDataSource: LandmarkLocalDataSourceImpl(sharedPreferences: sharedPreferences),
            networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashView(),
          onGenerateRoute: appRouter.generateRoute,
        ),
      ),
    );
  }
}
