import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kemet/core/routing/app_router.dart';
import 'package:kemet/kemet_app.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("🔥 Firebase Connected Successfully");

  runApp(
    KemetApp(
      appRouter: AppRouter(),
    ),
  );
}