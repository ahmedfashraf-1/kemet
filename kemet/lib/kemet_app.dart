import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/core/routing/routes.dart';

class KemetApp extends StatelessWidget {
  final AppRouter appRouter;

  const KemetApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.onRegisterScreen,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
