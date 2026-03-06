import 'package:flutter/material.dart';
import 'view/splash_view.dart';

void main() {
  runApp(const KemetApp());
}

class KemetApp extends StatelessWidget {
  const KemetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kemet',
      theme: ThemeData.dark(),
      home: const SplashView(),
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Kemet App'), centerTitle: true),
      body: const Center(
        child: Text('Welcome to Kemet', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
