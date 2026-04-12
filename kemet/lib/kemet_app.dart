import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kemet/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_local_data_source.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_remote_data_source.dart';
import 'package:kemet/features/landmarks/data/repositories/landmarks_repository_impl.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:kemet/features/reviews/data/repositories/reviews_repository_impl.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:kemet/features/splash/presentation/screens/splash_view.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemet/features/favorite/data/datasources/favorites_local_data_source.dart';
import 'package:kemet/features/favorite/data/repositories/favorites_repository_impl.dart';
import 'package:kemet/features/favorite/domain/repositories/favorites_repository.dart';
import 'package:kemet/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:kemet/features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_cubit.dart';

class KemetApp extends StatelessWidget {
  final AppRouter appRouter;
  final SharedPreferences sharedPreferences;
  final GlobalKey<NavigatorState> navigatorKey;
  

  const KemetApp({
    super.key,
    required this.appRouter,
    required this.sharedPreferences,
    required this.navigatorKey,
  });

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC9A34E)),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC9A34E),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            AuthRemoteDatasourceImpl(sharedPreferences: sharedPreferences),
          ),
        ),

        RepositoryProvider<LandmarksRepository>(
          create: (context) => LandmarksRepositoryImpl(
            remoteDataSource: LandmarkRemoteDataSourceImpl(client: http.Client()),
            localDataSource: LandmarkLocalDataSourceImpl(sharedPreferences: sharedPreferences),
            networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
          ),
        ),
        RepositoryProvider<ReviewsRepository>(
          create: (_) => ReviewsRepositoryImpl(
            remoteDatasource: ReviewsRemoteDatasourceImpl(),
            networkInfo: NetworkInfoImpl(InternetConnectionChecker.instance),
          ),
        ),
        RepositoryProvider<FavoritesRepository>(
          create: (context) => FavoritesRepositoryImpl(
          localDataSource: FavoritesLocalDataSourceImpl(
            sharedPreferences: sharedPreferences,
          ),
          landmarksRepository: context.read<LandmarksRepository>(),
        ),
      ),
      ],
      child: MultiBlocProvider(
        providers: [
        BlocProvider(
          create: (_) => SettingsCubit(sharedPreferences: sharedPreferences),
        ),

        BlocProvider<FavoritesCubit>(
          create: (context) => FavoritesCubit(
            getFavorites: GetFavoritesUsecase(context.read<FavoritesRepository>()),
            toggleFavorite: ToggleFavoriteUsecase(context.read<FavoritesRepository>()),
          )..loadFavorites(),
        ),
      ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                home: const SplashView(),
                onGenerateRoute: appRouter.generateRoute,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: settingsState.darkModeEnabled
                    ? ThemeMode.dark
                    : ThemeMode.light,
                locale: Locale(settingsState.localeCode),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
