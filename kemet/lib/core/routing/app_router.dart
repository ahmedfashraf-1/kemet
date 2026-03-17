import 'package:flutter/material.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/view/onboarding/onboarding_screen1_view.dart';
import 'package:kemet/view/onboarding/onboarding_screen2_view.dart';
import 'package:kemet/view/onboarding/onboarding_screen3_view.dart';
import 'package:kemet/view/onboarding/onboarding_screen4_view.dart';
import 'package:kemet/view/splash/splash_view.dart';
import 'package:kemet/view/auth/login_view.dart';
import 'package:kemet/view/auth/register_view.dart';
import 'package:kemet/view/home/home_screen.dart';
import 'package:kemet/view/common/main_shell.dart';

class AppRouter {
  Route generateRoute(RouteSettings setting) {
    switch (setting.name) {

      case Routes.splashScreen:
        return _fadeDominantFromBottom(const SplashView(), setting);

      case Routes.onBoardingScreen1:
        return _fadeDominantFromRight(const OnboardingScreen1(), setting);

      case Routes.onBoardingScreen2:
        return _fadeDominantFromRight(const OnboardingScreen2(), setting);

      case Routes.onBoardingScreen3:
        return _fadeDominantFromRight(const OnboardingScreen3(), setting);

      case Routes.onBoardingScreen4:
        return _fadeDominantFromRight(const OnboardingScreen4(), setting);

      case Routes.onLoginScreen:
        return _fadeDominantFromRight(const onLoginScreen(), setting);

      case Routes.onRegisterScreen:
        return _fadeDominantFromRight(const onRegisterScreen(), setting);

      case Routes.HomeScreen:
        return _fadeDominantFromRight(
          const MainShell(child: HomeScreen()), setting
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${setting.name}'),
            ),
          ),
        );
    }
  }

  PageRouteBuilder _fadeDominantFromRight(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const beginOffset = Offset(0.2, 0.0);
        const endOffset = Offset.zero;
        final offsetTween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.easeOut));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn));
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

  PageRouteBuilder _fadeDominantFromBottom(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const beginOffset = Offset(0.0, 0.2);
        const endOffset = Offset.zero;
        final offsetTween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.easeOut));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn));
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