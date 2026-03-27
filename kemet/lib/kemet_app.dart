import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kemet/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/splash/presentation/screens/splash_view.dart';

class KemetApp extends StatelessWidget {
  final AppRouter appRouter;

  const KemetApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(AuthRemoteDatasourceImpl()),
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
