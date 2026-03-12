import 'package:flutter/material.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/view/onboarding_screen1.dart';
import 'package:kemet/view/onboarding_screen2.dart';
import 'package:kemet/view/onboarding_screen3.dart';
import 'package:kemet/view/onboarding_screen4.dart';
import 'package:kemet/view/splash_view.dart';

class AppRouter {
  Route generateRoute(RouteSettings setting) {
    switch (setting.name) {

      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case Routes.onBoardingScreen1:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen1());
      case Routes.onBoardingScreen2:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen2());
      case Routes.onBoardingScreen3:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen3());
      case Routes.onBoardingScreen4:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen4());
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
}
