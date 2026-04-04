import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/auth/domain/usecases/check_email_verified_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/delete_account_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/send_verification_email_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:kemet/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/presentation/screens/forgot_password_view.dart';
import 'package:kemet/features/auth/presentation/screens/verify_email_otp_view.dart';
import 'package:kemet/features/home/presentation/screens/home_screen.dart';
import 'package:kemet/features/onboarding/presentation/screens/onboarding_screen1_view.dart';
import 'package:kemet/features/onboarding/presentation/screens/onboarding_screen2_view.dart';
import 'package:kemet/features/onboarding/presentation/screens/onboarding_screen3_view.dart';
import 'package:kemet/features/onboarding/presentation/screens/onboarding_screen4_view.dart';
import 'package:kemet/features/splash/presentation/screens/splash_view.dart';
import 'package:kemet/features/auth/presentation/screens/login_view.dart';
import 'package:kemet/features/auth/presentation/screens/register_view.dart';
import 'package:kemet/features/main/presentation/screens/main_shell.dart';
//import 'package:kemet/features/landmarks/presentation/screens/home_screen.dart';
import 'package:kemet/features/landmarks/presentation/screens/landmark_details_screen.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
// import 'package:kemet/features/home/presentation/screens/home_screen.dart';
import 'package:kemet/features/settings/presentation/screens/settings_screen.dart';
import 'package:kemet/features/notifications/presentation/screens/notification_details_screen.dart';

//landmarks
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:kemet/features/landmarks/domain/usecases/get_all_landmarks.dart';
import 'package:kemet/features/landmarks/presentation/cubit/landmarks_cubit.dart';

class AppRouter {
  Route generateRoute(RouteSettings setting) {
    switch (setting.name) {
      // Splash Screen: Fade dominant
      case Routes.splashScreen:
        return _fadeDominantFromBottom(const SplashView(), setting);

      // Onboarding Screens: Fade dominant
      case Routes.onBoardingScreen1:
        return _fadeDominantFromRight(const OnboardingScreen1(), setting);

      case Routes.onBoardingScreen2:
        return _fadeDominantFromRight(const OnboardingScreen2(), setting);

      case Routes.onBoardingScreen3:
        return _fadeDominantFromRight(const OnboardingScreen3(), setting);

      case Routes.onBoardingScreen4:
        return _fadeDominantFromRight(const OnboardingScreen4(), setting);

      case Routes.HomeScreen:
        return _fadeDominantFromRight(
          BlocProvider(
            create: (context) => LandmarksCubit(
              getAllLandmarksUsecase: GetAllLandmarksUsecase(
                context.read<LandmarksRepository>(),
              ),
            ),
            child: const MainShell(child: HomeScreen()),
          ),
          setting,
        );

      case Routes.notificationsScreen:
        final args = setting.arguments is Map<String, dynamic>
            ? setting.arguments as Map<String, dynamic>
            : const <String, dynamic>{};
        return _fadeDominantFromRight(
          NotificationDetailsScreen(
            title: args['title'] as String?,
            body: args['body'] as String?,
          ),
          setting,
        );

      case Routes.mainShell:
        return _fadeDominantFromRight(
          const MainShell(child: HomeScreen()),
          setting,
        );

      case Routes.landmarkDetails:
        final landmarkArg = setting.arguments;
        if (landmarkArg is! Landmark) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid landmark data')),
            ),
          );
        }
        return _fadeDominantFromRight(
          LandmarkDetailsScreen(landmark: landmarkArg),
          setting,
        );
      case Routes.settingsScreen:
        return _fadeDominantFromRight(
          BlocProvider(create: _buildAuthCubit, child: const SettingsScreen()),
          setting,
        );

      case Routes.forgotPassword:
        return _fadeDominantFromRight(
          BlocProvider(
            create: _buildAuthCubit,
            child: const ForgotPasswordView(),
          ),
          setting,
        );

      case Routes.verifyEmailOtp:
        final emailArg = setting.arguments;
        return _fadeDominantFromRight(
          BlocProvider(
            create: _buildAuthCubit,
            child: VerifyEmailOtpView(
              initialEmail: emailArg is String ? emailArg : null,
            ),
          ),
          setting,
        );

      case Routes.LoginView:
        return _fadeDominantFromRight(
          BlocProvider(create: _buildAuthCubit, child: const LoginView()),
          setting,
        );

      case Routes.RegisterView:
        return _fadeDominantFromRight(
          BlocProvider(create: _buildAuthCubit, child: const RegisterView()),
          setting,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: Text(
                  context.tr(
                    'no_route_defined',
                    args: {'route': '${setting.name}'},
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  // --------------------- Fade Dominant Transitions ---------------------

  AuthCubit _buildAuthCubit(BuildContext context) {
  final repository = context.read<AuthRepository>();
  return AuthCubit(
    signIn: SignInUseCase(repository),
    signUp: SignUpUseCase(repository),
    signInWithGoogle: SignInWithGoogleUseCase(repository),
    sendPasswordReset: SendPasswordResetUseCase(repository),
    sendVerificationEmail: SendVerificationEmailUseCase(repository),
    checkEmailVerified: CheckEmailVerifiedUseCase(repository),
    signOut: SignOutUseCase(repository),
    deleteAccount: DeleteAccountUseCase(repository), // ← السطر الجديد
  );
}

  // Fade dominant + slight slide from right
  PageRouteBuilder _fadeDominantFromRight(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const beginOffset = Offset(0.2, 0.0); // Slide خفيف جدًا
        const endOffset = Offset.zero;
        final offsetTween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: Curves.easeOut));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
    );
  }

  // Fade dominant + slight slide from bottom
  PageRouteBuilder _fadeDominantFromBottom(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const beginOffset = Offset(0.0, 0.2); // Slide خفيف جدًا من تحت
        const endOffset = Offset.zero;
        final offsetTween = Tween(
          begin: beginOffset,
          end: endOffset,
        ).chain(CurveTween(curve: Curves.easeOut));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(offsetTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
