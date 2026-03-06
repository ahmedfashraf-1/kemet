// import 'package:flutter/material.dart';
//
// class SplashView extends StatefulWidget {
//   const SplashView({super.key});
//
//   @override
//   State<SplashView> createState() => _SplashViewState();
// }
//
// class _SplashViewState extends State<SplashView> {
//   static const AssetImage _splashImage = AssetImage('images/splash.gif');
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) {
//         return;
//       }
//       precacheImage(_splashImage, context);
//     });
//
//     Future.delayed(const Duration(seconds: 3), () {
//       if (!mounted) {
//         return;
//       }
//       _navigateToHomeWithFade();
//     });
//   }
//
//   void _navigateToHomeWithFade() {
//     final MaterialApp? app = context
//         .findAncestorWidgetOfExactType<MaterialApp>();
//     final WidgetBuilder? homeBuilder = app?.routes?['/home'];
//
//     if (homeBuilder == null) {
//       return;
//     }
//
//     Navigator.pushReplacement<void, void>(
//       context,
//       PageRouteBuilder<void>(
//         transitionDuration: const Duration(milliseconds: 400),
//         reverseTransitionDuration: const Duration(milliseconds: 400),
//         pageBuilder: (context, animation, secondaryAnimation) {
//           return homeBuilder(context);
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(child: Image(image: _splashImage, width: 550)),
//     );
//   }
// }
