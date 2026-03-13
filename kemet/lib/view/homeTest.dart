import 'package:flutter/material.dart';
import 'package:kemet/core/services/auth_service.dart';
import 'package:kemet/core/helpers/extensions.dart';
import 'package:kemet/core/routing/routes.dart';

class OnHomeScreen extends StatelessWidget {
  const OnHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 64, 59, 59),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "HOME",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  context.pushReplacementNamed(Routes.onLoginScreen);
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}