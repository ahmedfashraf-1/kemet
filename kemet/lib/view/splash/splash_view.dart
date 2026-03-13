import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemet/core/helpers/extensions.dart';
import 'package:kemet/core/routing/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const AssetImage _splashImage = AssetImage('images/splash.gif');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      precacheImage(_splashImage, context);
    });
    _checkOnboarding();

    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!mounted) {
    //     return;
    //   }
    //   _navigateToOnboarding();
    // });
  }

  Future<void> _checkOnboarding() async {

    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!mounted) return;
    if (seenOnboarding) {
      context.pushReplacementNamed(Routes.onLoginScreen); // لما نضيف ال هوم
    } else {
      context.pushReplacementNamed(Routes.onBoardingScreen1);
    }
  }

  // void _navigateToOnboarding() {
  //   final MaterialApp? app = context
  //       .findAncestorWidgetOfExactType<MaterialApp>();
  //   final WidgetBuilder? homeBuilder = app?.routes?[Routes.onBoardingScreen1];

  //   if (homeBuilder == null) {
  //     return;
  //   }

  //   Navigator.pushReplacement<void, void>(
  //     context,
  //     PageRouteBuilder<void>(
  //       transitionDuration: const Duration(milliseconds: 400),
  //       reverseTransitionDuration: const Duration(milliseconds: 400),
  //       pageBuilder: (context, animation, secondaryAnimation) {
  //         return homeBuilder(context);
  //       },
  //     ),
  //   );
  // }

// void _navigateToOnboarding() {
//   if (mounted) {
//     context.pushReplacementNamed(Routes.onBoardingScreen1);
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image(image: _splashImage, width: 550)),
    );
  }
}
